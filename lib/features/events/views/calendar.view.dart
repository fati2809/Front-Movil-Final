import 'dart:async';
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
  final ApiService _apiService = ApiService();
  Timer? _timer;

  List<Evento> _eventos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEventos();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _verificarNuevosEventos();
    });
  }

  Future<void> _cargarEventos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final eventos = await _apiService.getEventos();
      setState(() {
        _eventos = eventos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _verificarNuevosEventos() async {
    try {
      final nuevosEventos = await _apiService.getEventos();
      final idsActuales = _eventos
          .where((e) => e.statusEvent == 1)
          .map((e) => e.id)
          .toSet();

      final idsNuevos = nuevosEventos.map((e) => e.id).toSet();

      final hayNuevos = !idsNuevos.every((id) => idsActuales.contains(id));
      final hayEliminados = !idsActuales.every((id) => idsNuevos.contains(id));

      if (hayNuevos || hayEliminados) {
        setState(() {
          _eventos = nuevosEventos;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: const [
              Text(
                'Edificios con eventos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Spacer(),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargarEventos,
            child: _buildBody(),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey,
          child: const Text(
            'Los horarios pueden sufrir cambios sin previo aviso',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No se pudieron cargar los eventos\n$_error',
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

    if (_eventos.isEmpty) {
      return const Center(child: Text('No hay eventos disponibles'));
    }

    final eventosActivos = _eventos.where((e) => e.statusEvent == 1).toList();

    if (eventosActivos.isEmpty) {
      return const Center(child: Text('No hay eventos disponibles'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: eventosActivos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final evento = eventosActivos[index];

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
              : Icon(Icons.event, size: 40, color: GlobalColors.mainColor),
          title: Text(
            evento.nameEvent,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    const Icon(Icons.location_on, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      evento.edificio!.nameBuilding!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                builder: (context) => EventDetailView(evento: evento),
              ),
            );
          },
        );
      },
    );
  }
}
