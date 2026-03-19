import 'package:flutter/material.dart';
import 'package:flutter_front/features/professors/views/building.professors.view.dart';
import 'package:get/get.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/professors/views/search.professor.view.dart';
import 'package:flutter_front/features/professors/views/search.building.view.dart';
import 'package:flutter_front/features/auth/controllers/auth_controller.dart';
import 'package:flutter_front/features/map/views/map_guide.view.dart';
import 'package:flutter_front/features/auth/views/login.view.dart';
import 'package:flutter_front/features/events/views/qr_scanner.view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: GlobalColors.mainColor),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'MAPPOSTING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (authController.isLoggedIn.value)
                    Text(
                      authController.user.value?['email'] ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    )
                  else
                    const Text(
                      'Sin sesión iniciada',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Buscar profesores'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchAllProfessorsView(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.business, color: GlobalColors.mainColor),
            title: const Text('Buscar edificios'),
            subtitle: const Text('Ver edificios del campus'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchBuildingView(),
                ),
              );
            },
          ),

          // ✅ NUEVO - Escanear QR (siempre visible)
          ListTile(
            leading: Icon(Icons.qr_code_scanner, color: GlobalColors.mainColor),
            title: const Text('Escanear QR'),
            subtitle: const Text('Validar asistencia'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScannerView()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.help_outline, color: GlobalColors.mainColor),
            title: const Text('Cómo usar el mapa'),
            subtitle: const Text('Guía de rutas y colores'),
            onTap: () {
              Navigator.pop(context); // cierra el drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapGuideView(),
                ),
              );
            },
          ),

          const Divider(),

          // Mostrar login o logout según el estado
          Obx(() {
            if (authController.isLoggedIn.value) {
              return ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  authController.logout();
                },
              );
            } else {
              return ListTile(
                leading: Icon(Icons.login, color: GlobalColors.mainColor),
                title: Text(
                  'Iniciar sesión',
                  style: TextStyle(color: GlobalColors.mainColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
                  );
                },
              );
            }
          }),
        ],
      ),
    );
  }
}
