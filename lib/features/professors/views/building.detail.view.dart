import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/map/views/map.view.dart';
import 'package:flutter_front/features/home/views/home.view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_front/features/auth/views/login.view.dart';     // ← importa tu pantalla de login
import 'package:flutter_front/features//auth/views/register.view.dart'; // ← opcional, si quieres mostrar registro

class BuildingDetailView extends StatefulWidget {
  final int idBuilding;
  final String nameBuilding;
  final String? codeBuilding;
  final String? imagenUrl;
  final double? latBuilding;
  final double? lonBuilding;
  final String? descriptionBuilding;

  const BuildingDetailView({
    Key? key,
    required this.idBuilding,
    required this.nameBuilding,
    this.codeBuilding,
    this.imagenUrl,
    this.latBuilding,
    this.lonBuilding,
    this.descriptionBuilding,
  }) : super(key: key);

  @override
  State<BuildingDetailView> createState() => _BuildingDetailViewState();
}

class _BuildingDetailViewState extends State<BuildingDetailView> {
  List<Map<String, dynamic>> profesores = [];
  bool isLoadingProfes = false;
  bool isLoggedIn = false; // ← importante: inicia en false para testing

  @override
  void initState() {
    super.initState();
    _checkLoginAndFetch();
  }

  Future<void> _checkLoginAndFetch() async {
    // Aquí va tu lógica real de verificación de sesión
    // Ejemplos:
    // 1. Supabase:    isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    // 2. SharedPreferences:
    //    final prefs = await SharedPreferences.getInstance();
    //    isLoggedIn = prefs.getString('auth_token') != null;

    // Por ahora usamos valor fijo para pruebas rápidas
    // → cámbialo a true cuando quieras ver los nombres sin login
    isLoggedIn = false; // ← CAMBIA AQUÍ PARA PROBAR AMBOS CASOS

    if (isLoggedIn) {
      await _fetchProfesoresEnEdificio();
    } else {
      setState(() => isLoadingProfes = false);
    }
  }

  Future<void> _fetchProfesoresEnEdificio() async {
    setState(() => isLoadingProfes = true);
    try {
      final url = Uri.parse(
        'https://maposting-backend.onrender.com/profesoresf/edificio/${widget.idBuilding}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        setState(() {
          profesores = data.cast<Map<String, dynamic>>();
          isLoadingProfes = false;
        });
      } else {
        setState(() => isLoadingProfes = false);
        _showError('Error al cargar profesores (${response.statusCode})');
      }
    } catch (e) {
      setState(() => isLoadingProfes = false);
      _showError('Error de conexión: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GlobalColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Edificio',
          style: TextStyle(
            color: GlobalColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (imagen + nombre) → sin cambios
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: GlobalColors.mainColor.withOpacity(0.08),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.imagenUrl != null &&
                            widget.imagenUrl!.isNotEmpty &&
                            widget.imagenUrl != 'NULL'
                        ? Image.network(
                            widget.imagenUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.nameBuilding,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.codeBuilding != null &&
                      widget.codeBuilding!.isNotEmpty &&
                      widget.codeBuilding != 'NULL')
                    Text(
                      'Código: ${widget.codeBuilding}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción → sin cambios
                  if (widget.descriptionBuilding != null &&
                      widget.descriptionBuilding!.isNotEmpty &&
                      widget.descriptionBuilding != 'NULL') ...[
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.descriptionBuilding!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Sección Profesores
                  Row(
                    children: [
                      const Text(
                        'Profesores asignados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.school_outlined,
                        color: GlobalColors.mainColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isLoadingProfes)
                    const Center(child: CircularProgressIndicator())
                  else if (!isLoggedIn)
                    _buildLoginRequired()
                  else if (profesores.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'No hay profesores registrados en este edificio',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...profesores.map(
                      (profe) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 36,
                              decoration: BoxDecoration(
                                color: GlobalColors.mainColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                profe['nombre_profe'] ?? 'Profesor sin nombre',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Botón mapa → sin cambios
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.offAll(
                          () => const HomeView(),
                          arguments: {"destination": widget.nameBuilding},
                        );
                      },
                      icon: const Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                      label: const Text(
                        'Ver ubicación en el mapa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Inicia sesión para ver los profesores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Solo usuarios registrados pueden ver la lista de profesores asignados a este edificio',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginView(),
                  ),
                );

                if (result == true && mounted) {
                  setState(() {
                    isLoggedIn = true;
                  });
                  await _fetchProfesoresEnEdificio();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalColors.mainColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterView()),
              );
            },
            child: Text(
              '¿No tienes cuenta? Regístrate',
              style: TextStyle(
                color: GlobalColors.mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: GlobalColors.mainColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.apartment_rounded,
        size: 70,
        color: GlobalColors.mainColor.withOpacity(0.5),
      ),
    );
  }
}