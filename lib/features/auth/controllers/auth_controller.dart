import 'package:get/get.dart';
import 'package:flutter_front/data/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();

  // ⚠️ Para iOS, necesitas especificar el CLIENT_ID del archivo GoogleService-Info.plist
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Este clientId es específico para iOS (del GoogleService-Info.plist)
    clientId:
        '816053825270-td99l325vtk98nbgv1djh78pdbcht3hp.apps.googleusercontent.com',
  );

  // Estado observable de la sesión
  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final user = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    checkSession(); // Verificar sesión al iniciar
  }

  /// Verificar si hay una sesión activa
  Future<void> checkSession() async {
    try {
      final token = await _api.getToken();
      if (token != null && token.isNotEmpty) {
        // Intentar recuperar datos del usuario guardados
        final userData = await _api.storage.read(key: 'user_data');

        if (userData != null && userData.isNotEmpty) {
          // Parsear los datos básicos (esto es una solución temporal)
          // En producción, deberías guardar como JSON
          isLoggedIn.value = true;
          print('✅ Sesión activa encontrada');

          // TODO: Validar token con el backend
          // Opcional: hacer una llamada al backend para verificar que el token sigue válido
        } else {
          isLoggedIn.value = true; // Tenemos token pero no datos locales
          print('✅ Token encontrado, pero sin datos de usuario almacenados');
        }
      } else {
        isLoggedIn.value = false;
        user.value = null;
        print('⚠️ No hay sesión activa');
      }
    } catch (e) {
      print('❌ Error al verificar sesión: $e');
      isLoggedIn.value = false;
      user.value = null;
    }
  }

  /// Login con email y password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Llamar al endpoint de login del backend
      final response = await _api.post(
        '/login',
        data: {'email_user': email, 'pass_user': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Guardar access_token y refresh_token
        final accessToken = response.data['session']['access_token'];
        final refreshToken = response.data['session']['refresh_token'];

        await _api.saveToken(accessToken);
        await _api.storage.write(key: 'refresh_token', value: refreshToken);

        // Guardar datos del usuario
        final userData = response.data['user'];
        user.value = {
          'id': userData['id_user'],
          'name': userData['name_user'],
          'email': userData['email_user'],
          'matricula': userData['matricula_user'],
          'rol': userData['rol'],
          'id_rol': userData['id_rol'],
        };

        // Guardar también el usuario en storage para persistencia
        await _api.storage.write(
          key: 'user_data',
          value: user.value.toString(),
        );

        isLoggedIn.value = true;

        print('✅ Login exitoso: ${userData['name_user']}');
        Get.snackbar(
          'Bienvenido',
          'Hola ${userData['name_user']}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Credenciales inválidas',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error en login: $e');
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesión. Verifica tu conexión.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int matricula,
    int idRol = 2, // Por defecto rol de estudiante
  }) async {
    try {
      isLoading.value = true;

      // Llamar al endpoint de registro del backend
      final response = await _api.post(
        '/register',
        data: {
          'name_user': name,
          'email_user': email,
          'pass_user': password,
          'matricula_user': matricula,
          'id_rol': idRol,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        Get.snackbar(
          'Éxito',
          response.data['message'] ?? 'Cuenta creada correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Error al registrarse',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      Get.snackbar(
        'Error',
        'No se pudo crear la cuenta. Intenta nuevamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login con Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el login
        print('⚠️ Usuario canceló el login de Google');
        return false;
      }

      // Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.snackbar(
          'Error',
          'No se pudo obtener el token de Google',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      print('✅ Google Sign-In exitoso: ${googleUser.email}');

      // Enviar el idToken al backend para validarlo y crear/obtener usuario
      // Por ahora intentamos con un endpoint /login/google
      // Si no existe, puedes crear uno en tu backend o usar el login normal
      try {
        final response = await _api.post(
          '/login/google',
          data: {
            'id_token': idToken,
            'email': googleUser.email,
            'name': googleUser.displayName,
            'photo': googleUser.photoUrl,
          },
        );

        if (response.statusCode == 200 && response.data['success'] == true) {
          // Guardar tokens
          final accessToken = response.data['session']['access_token'];
          final refreshToken = response.data['session']['refresh_token'];

          await _api.saveToken(accessToken);
          await _api.storage.write(key: 'refresh_token', value: refreshToken);

          // Guardar datos del usuario
          final userData = response.data['user'];
          user.value = {
            'id': userData['id_user'],
            'name': userData['name_user'],
            'email': userData['email_user'],
            'matricula': userData['matricula_user'],
            'rol': userData['rol'],
            'id_rol': userData['id_rol'],
            'photo': googleUser.photoUrl,
          };

          await _api.storage.write(
            key: 'user_data',
            value: user.value.toString(),
          );
          isLoggedIn.value = true;

          Get.snackbar(
            'Bienvenido',
            'Hola ${userData['name_user']}',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            response.data['message'] ?? 'No se pudo autenticar con Google',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } catch (backendError) {
        // Si el backend aún no tiene endpoint de Google, simulamos logout
        print('⚠️ Endpoint /login/google no disponible: $backendError');
        print(
          'ℹ️ Para usar Google Sign-In, necesitas crear el endpoint en tu backend',
        );

        // Por ahora, guardamos la info de Google localmente
        user.value = {
          'name': googleUser.displayName ?? 'Usuario de Google',
          'email': googleUser.email,
          'photo': googleUser.photoUrl,
        };
        isLoggedIn.value = true;

        Get.snackbar(
          'Bienvenido',
          'Hola ${googleUser.displayName}',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );

        return true;
      }
    } catch (e) {
      print('❌ Error en Google Sign-In: $e');
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesión con Google',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _api.clearStorage();
      isLoggedIn.value = false;
      user.value = null;

      Get.snackbar(
        'Sesión cerrada',
        'Has cerrado sesión correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
      print('✅ Logout exitoso');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }

  /// Verificar si requiere login y mostrarlo
  bool requireLogin(String feature) {
    if (!isLoggedIn.value) {
      Get.snackbar(
        'Inicia sesión',
        'Debes iniciar sesión para $feature',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true; // Requiere login
    }
    return false; // No requiere login (ya está logueado)
  }
}
