import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_front/data/models/evento.dart';

class ApiService {
  // 🔧 Cambia esta URL según tu entorno
  static const String baseUrl = 'http://localhost:8000'; // Backend local
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'https://tu-api-produccion.com'; // Producción

  final Dio _dio = Dio();
  final storage = const FlutterSecureStorage();

  // Modo debug para logs
  static const bool debugMode = true;

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 🔐 Interceptor para agregar tokens JWT automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (debugMode) {
            print('🌐 REQUEST: ${options.method} ${options.uri}');
            if (options.data != null) print('📤 Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (debugMode) {
            print(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print(
              '📥 Data: ${response.data.toString().substring(0, response.data.toString().length.clamp(0, 300))}...',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (debugMode) {
            print(
              '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
            );
            print('💥 Message: ${error.message}');
            if (error.response?.data != null) {
              print('📛 Error Data: ${error.response?.data}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== MÉTODOS GENÉRICOS ====================

  /// GET request genérico
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request genérico
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request genérico
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request genérico
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== MANEJO DE ERRORES ====================

  Exception _handleError(DioException error) {
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Tiempo de espera agotado. Verifica tu conexión.';
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'Solicitud inválida: ${error.response?.data}';
            break;
          case 401:
            errorMessage = 'No autorizado. Inicia sesión nuevamente.';
            _clearToken(); // Limpiar token inválido
            break;
          case 403:
            errorMessage = 'Acceso prohibido.';
            break;
          case 404:
            errorMessage = 'Recurso no encontrado.';
            break;
          case 500:
            errorMessage = 'Error del servidor. Intenta más tarde.';
            break;
          default:
            errorMessage = 'Error del servidor: ${error.response?.statusCode}';
        }
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Solicitud cancelada.';
        break;

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          errorMessage = 'Sin conexión a internet. Verifica tu red.';
        } else {
          errorMessage = 'Error desconocido: ${error.message}';
        }
        break;

      default:
        errorMessage = 'Error de conexión: ${error.message}';
    }

    return Exception(errorMessage);
  }

  // ==================== AUTENTICACIÓN ====================

  /// Guardar token JWT
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
    if (debugMode) print('🔑 Token guardado');
  }

  /// Obtener token JWT
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  /// Limpiar token (logout)
  Future<void> _clearToken() async {
    await storage.delete(key: 'auth_token');
    if (debugMode) print('🗑️ Token eliminado');
  }

  /// Limpiar todo el storage
  Future<void> clearStorage() async {
    await storage.deleteAll();
    if (debugMode) print('🗑️ Storage limpiado');
  }

  // ==================== EVENTOS ====================
  // TODO: Refactorizar esto a un EventRepository separado
  // En el futuro, cada dominio (eventos, profesores, edificios) debería
  // tener su propio repository que use ApiService internamente

  /// Obtener lista de eventos
  Future<List<Evento>> getEventos() async {
    try {
      final response = await get('/eventos');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Evento.fromJson(json))
            .toList();
      }

      throw Exception('Respuesta inválida del servidor');
    } catch (e) {
      if (debugMode) print('❌ Error obteniendo eventos: $e');
      rethrow;
    }
  }
}
