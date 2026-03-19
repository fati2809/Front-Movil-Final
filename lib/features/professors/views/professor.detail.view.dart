import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/home/views/home.view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfessorDetailView extends StatefulWidget {
  final int idProfe;
  final String professorName;
  final String office;
  final String building;

  const ProfessorDetailView({
    Key? key,
    required this.idProfe,
    required this.professorName,
    required this.office,
    required this.building,
  }) : super(key: key);

  @override
  State<ProfessorDetailView> createState() => _ProfessorDetailViewState();
}

class _ProfessorDetailViewState extends State<ProfessorDetailView> {
  List<Map<String, dynamic>> _horario = [];
  bool _isLoading = true;

  static const _ordenDias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

  final Map<String, String> _diasMap = {
    'Lun': 'Lunes',
    'Mar': 'Martes',
    'Mie': 'Miércoles',
    'Jue': 'Jueves',
    'Vie': 'Viernes',
  };

  final Map<String, String> _horasMap = {
    '17': '17:00 - 18:00',
    '18': '18:00 - 19:00',
    '19': '19:00 - 20:00',
    '20': '20:00 - 21:00',
    '21': '21:00 - 22:00',
  };

  @override
  void initState() {
    super.initState();
    _fetchHorario();
  }

  Future<void> _fetchHorario() async {
    try {
      final url = Uri.parse(
        'https://maposting-backend.onrender.com/profesoresf/${widget.idProfe}/horario',
      );
      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final clases = List<Map<String, dynamic>>.from(data['horario'] ?? []);
        setState(() {
          _horario = clases;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('Error cargando horario: $e');
    }
  }

  String _parseDia(String start) {
    final dia = start.substring(0, 3);
    return _diasMap[dia] ?? dia;
  }

  String _parseHora(String start) {
    final periodo = start.substring(3);
    return _horasMap[periodo] ?? 'Período $periodo';
  }

  List<Widget> _buildHorarioAgrupado() {
    final Map<String, List<Map<String, dynamic>>> porDia = {};
    for (final clase in _horario) {
      final dia = _parseDia(clase['horario'] as String);
      porDia.putIfAbsent(dia, () => []).add(clase);
    }

    for (final clases in porDia.values) {
      clases.sort((a, b) {
        final horaA = int.tryParse((a['horario'] as String).substring(3)) ?? 0;
        final horaB = int.tryParse((b['horario'] as String).substring(3)) ?? 0;
        return horaA.compareTo(horaB);
      });
    }

    return _ordenDias
        .where((dia) => porDia.containsKey(dia))
        .map((dia) {
          final clases = porDia[dia]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.only(bottom: 8),
                leading: Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GlobalColors.mainColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  dia,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${clases.length} clase${clases.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                children: clases.map((clase) {
                  final start = clase['horario'] as String;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3,
                          height: 50,
                          decoration: BoxDecoration(
                            color: GlobalColors.mainColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _parseHora(start),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: GlobalColors.mainColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${clase['materia']} • ${clase['grupo']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                clase['salon'] ?? '',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        })
        .toList();
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
          'Información del Profesor',
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              color: GlobalColors.mainColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: GlobalColors.mainColor.withOpacity(0.3),
                    child: Icon(Icons.person, size: 60, color: GlobalColors.mainColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.professorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ubicación
                  const Text(
                    'Ubicación',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.business, 'Edificio', widget.building),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.door_front_door, 'Cubículo', widget.office),

                  const SizedBox(height: 30),

                  // Horario
                  Row(
                    children: [
                      const Text(
                        'Horario de clases',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(Icons.schedule, color: GlobalColors.mainColor),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_horario.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No hay horario registrado para este profesor',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._buildHorarioAgrupado(),

                  const SizedBox(height: 30),

                  // Botón ver en mapa
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.offAll(
                          () => const HomeView(),
                          arguments: {"destination": widget.building},
                        );
                      },
                      icon: Icon(Icons.map, color: GlobalColors.mainColor),
                      label: Text(
                        'Ver en mapa',
                        style: TextStyle(
                          color: GlobalColors.mainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: GlobalColors.mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: GlobalColors.mainColor, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}