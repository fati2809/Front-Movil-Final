import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/events/views/event.confirmation.view.dart';
import 'package:flutter_front/data/models/evento.dart';
import 'package:flutter_front/features/home/views/home.view.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventDetailView extends StatefulWidget {
  final Evento evento;

  const EventDetailView({Key? key, required this.evento}) : super(key: key);

  @override
  State<EventDetailView> createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  String? _buildingName;
  bool _isLoadingBuilding = true;

  @override
  void initState() {
    super.initState();
    _fetchBuilding();
  }

  // ✅ Petición al backend para obtener el edificio
  Future<void> _fetchBuilding() async {
    try {
      final idBuilding = widget.evento.idBuilding;

      if (idBuilding == null) {
        setState(() => _isLoadingBuilding = false);
        return;
      }

      final url = Uri.parse(
        'https://maposting-backend.onrender.com/edificios/$idBuilding',
      );

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _buildingName = data['name_building'];
          _isLoadingBuilding = false;
        });
      } else {
        setState(() => _isLoadingBuilding = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingBuilding = false);
      print("Error obteniendo edificio: $e");
    }
  }

  // ✅ Generar código de confirmación
  String _generateConfirmationCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'EVT-${widget.evento.nameEvent.substring(0, 3).toUpperCase()}-$timestamp';
  }

  @override
  Widget build(BuildContext context) {
    final evento = widget.evento;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GlobalColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          evento.nameEvent,
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
            // Imagen del evento
            evento.imgEvent != null
                ? Image.network(
                    evento.imgEvent!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultImage(),
                  )
                : _defaultImage(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    evento.nameEvent,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Días
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: GlobalColors.mainColor),
                      const SizedBox(width: 12),
                      Text(
                        evento.dias ?? 'Sin fecha',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Horario
                  Row(
                    children: [
                      Icon(Icons.access_time, color: GlobalColors.mainColor),
                      const SizedBox(width: 12),
                      Text(
                        evento.horario ?? 'Sin horario',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ubicación (dinámica)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: GlobalColors.mainColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isLoadingBuilding
                              ? 'Cargando ubicación...'
                              : (_buildingName ?? 'Ubicación no disponible'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    evento.descripEvent ??
                        'Evento académico y cultural.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón registrarse
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final confirmationCode = _generateConfirmationCode();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventConfirmationView(
                              eventName: evento.nameEvent,
                              days: evento.dias ?? 'Sin fecha',
                              schedule: evento.horario ?? 'Sin horario',
                              confirmationCode: confirmationCode,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrarme al evento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ BOTÓN VER EN MAPA FUNCIONAL
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final destino = _buildingName?.trim();

                        if (destino == null || destino.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "No se pudo obtener el edificio",
                              ),
                            ),
                          );
                          return;
                        }

                        Get.offAll(
                          () => const HomeView(),
                          arguments: {"destination": destino},
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

  Widget _defaultImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: GlobalColors.mainColor.withOpacity(0.2),
      child: Icon(
        Icons.event,
        size: 80,
        color: GlobalColors.mainColor,
      ),
    );
  }
}