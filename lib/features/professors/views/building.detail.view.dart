import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/map/views/map.view.dart';
import 'package:flutter_front/features/home/views/home.view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BuildingDetailView extends StatefulWidget {
  final int idBuilding;
  final String nameBuilding;
  final String? codeBuilding;
  final String? imagenUrl;
  final double? latBuilding;
  final double? lonBuilding;
  final String? descriptionBuilding; // ← Nuevo: descrip_building

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
  bool isLoadingProfes = true;

  @override
  void initState() {
    super.initState();
    _fetchProfesoresEnEdificio();
  }

  Future<void> _fetchProfesoresEnEdificio() async {
    try {
      // Cambia 'https://tu-api-url' por tu URL real del backend
      final url = Uri.parse(
        'http://localhost:8000/profesoresf/edificio/${widget.idBuilding}',
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar profesores (${response.statusCode})',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoadingProfes = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    }
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
            // Header con imagen o placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: GlobalColors.mainColor.withOpacity(0.08),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        widget.imagenUrl != null &&
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
                  // Descripción del edificio (nuevo campo importante)
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

                  // Profesores en este edificio
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

                  // Botón para ver en el mapa
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
