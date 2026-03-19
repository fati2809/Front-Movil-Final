import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/events/views/event.confirmation.view.dart';
import 'package:flutter_front/data/models/evento.dart';

class EventDetailView extends StatelessWidget {
  final Evento evento;

  const EventDetailView({Key? key, required this.evento}) : super(key: key);

  // ✅ Generar código único de confirmación
  String _generateConfirmationCode() {
    // TODO: En producción, esto vendría del backend
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'EVT-${evento.nameEvent.substring(0, 3).toUpperCase()}-$timestamp';
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
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 200,
                      color: GlobalColors.mainColor.withOpacity(0.2),
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: GlobalColors.mainColor,
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 200,
                    color: GlobalColors.mainColor.withOpacity(0.2),
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: GlobalColors.mainColor,
                    ),
                  ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del evento
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

                  // Ubicación
                  Row(
                    children: [
                      Icon(Icons.location_on, color: GlobalColors.mainColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          evento.edificio?.nameBuilding ??
                              'UTEQ - Universidad Tecnológica de Querétaro',
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
                        'Evento de programa educativo embajadores. Los estudiantes podrán participar en diversas actividades académicas y culturales.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón de registrarse
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Generar código y navegar a confirmación
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

                  // Botón de ver en mapa
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: GlobalColors.mainColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Ver en mapa',
                        style: TextStyle(
                          color: GlobalColors.mainColor,
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
        ),
      ),
    );
  }
}
