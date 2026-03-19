import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/events/views/event.detail.view.dart';
import 'package:flutter_front/data/services/api_service.dart';
import 'package:flutter_front/data/models/evento.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late Future<List<Evento>> _eventosFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() {
      _eventosFuture = _apiService.getEventos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Edificios con eventos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarEventos,
            child: FutureBuilder<List<Evento>>(
              future: _eventosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No se pudieron cargar los eventos\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _cargarEventos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No hay eventos disponibles'),
                  );
                }

                final eventos = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: eventos.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final evento = eventos[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      leading: evento.imgEvent != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                evento.imgEvent!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.event,
                                  size: 40,
                                  color: GlobalColors.mainColor,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.event,
                              size: 40,
                              color: GlobalColors.mainColor,
                            ),
                      title: Text(
                        evento.nameEvent,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 13,
                                color: GlobalColors.mainColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                evento.dias ?? 'Sin fecha',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.access_time,
                                size: 13,
                                color: GlobalColors.mainColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                evento.horario ?? 'Sin horario',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          if (evento.edificio?.nameBuilding != null) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 13,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  evento.edificio!.nameBuilding!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: GlobalColors.mainColor,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailView(evento: evento),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: const Text(
            'Los horarios pueden sufrir cambios sin previo aviso',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
