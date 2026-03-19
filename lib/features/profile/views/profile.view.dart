import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/auth/controllers/auth_controller.dart';
import 'package:flutter_front/features/auth/views/login.view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Obx(() {
      final isLoggedIn = authController.isLoggedIn.value;
      final user = authController.user.value;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: isLoggedIn
                    ? GlobalColors.mainColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.person_outline,
                  size: 60,
                  color: isLoggedIn ? GlobalColors.mainColor : Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Nombre/Estado
              Text(
                isLoggedIn
                    ? (user?['name'] ?? 'Usuario')
                    : 'Invitado',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email/Matrícula
              if (isLoggedIn)
                Text(
                  user?['email'] ?? user?['matricula'] ?? 'usuario@uteq.edu.mx',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                )
              else
                Text(
                  'Sin sesión activa',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),

              const SizedBox(height: 40),

              // Información adicional o botón de login
              if (isLoggedIn) ...[
                // Usuario logueado: mostrar info adicional
                _buildInfoCard(
                  icon: Icons.school,
                  title: 'Facultad',
                  subtitle: user?['facultad'] ?? 'Ingeniería',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.badge,
                  title: 'Matrícula',
                  subtitle: user?['matricula'] ?? 'No disponible',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Correo',
                  subtitle: user?['email'] ?? 'No disponible',
                ),
              ] else ...[
                // Usuario NO logueado: mostrar mensaje y botón
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Inicia sesión para ver tu perfil completo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: GlobalColors.mainColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
