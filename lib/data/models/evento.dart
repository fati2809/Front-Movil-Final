class Edificio {
  final int idBuilding;
  final String? nameBuilding;
  final double? lat;
  final double? lon;
  final String? codeBuilding;

  Edificio({
    required this.idBuilding,
    this.nameBuilding,
    this.lat,
    this.lon,
    this.codeBuilding,
  });

  factory Edificio.fromJson(Map<String, dynamic> json) {
    return Edificio(
      idBuilding: json['id_building'] as int,
      nameBuilding: json['name_building'] as String?,
      lat: (json['lat_building'] as num?)?.toDouble(),
      lon: (json['lon_building'] as num?)?.toDouble(),
      codeBuilding: json['code_building'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_building': idBuilding,
      'name_building': nameBuilding,
      'lat_building': lat,
      'lon_building': lon,
      'code_building': codeBuilding,
    };
  }
}

class Evento {
  final int id;
  final String nameEvent;
  final String? dias;
  final String? horario;
  final DateTime? timedateEvent;
  final int? statusEvent;
  final int? idProfe;
  final String? idUser;
  final String? descripEvent;
  final String? imgEvent;
  final Edificio? edificio;

  Evento({
    required this.id,
    required this.nameEvent,
    this.dias,
    this.horario,
    this.timedateEvent,
    this.statusEvent,
    this.idProfe,
    this.idUser,
    this.descripEvent,
    this.imgEvent,
    this.edificio,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    final dt = json['timedate_event'] != null
        ? DateTime.parse(json['timedate_event']).toLocal()
        : null;

    final edificioJson = json['edificios'];

    return Evento(
      id: json['id_event'] as int,
      nameEvent: json['name_event'] as String,
      timedateEvent: dt,
      statusEvent: json['status_event'] as int?,
      idProfe: json['id_profe'] as int?,
      idUser: json['id_user'] as String?,
      descripEvent: json['descrip_event'] as String?,
      imgEvent: json['img_event'] as String?,
      edificio: edificioJson != null ? Edificio.fromJson(edificioJson) : null,
      dias: dt != null
          ? '${_diaSemana(dt.weekday)} ${dt.day} ${_mes(dt.month)}'
          : 'Sin fecha',
      horario: dt != null
          ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
          : 'Sin horario',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_event': id,
      'name_event': nameEvent,
      'timedate_event': timedateEvent?.toIso8601String(),
      'status_event': statusEvent,
      'id_profe': idProfe,
      'id_user': idUser,
      'descrip_event': descripEvent,
      'img_event': imgEvent,
      'edificios': edificio?.toJson(),
    };
  }

  static String _diaSemana(int d) =>
      ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][d - 1];

  static String _mes(int m) => [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ][m - 1];
}
