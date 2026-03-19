import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapView extends StatefulWidget {
  final String? initialDestinationId;
  const MapView({super.key, this.initialDestinationId});

  @override
  State<MapView> createState() => _MapViewState();
}

class CampusNode {
  final String id;
  final LatLng position;
  final List<String> neighbors;

  CampusNode({
    required this.id,
    required this.position,
    required this.neighbors,
  });
}

class _MapViewState extends State<MapView> {
  bool debugUseNodeA = false;

  final MapController _mapController = MapController();
  LatLng? _userPosition;
  Stream<Position>? _positionStream;

  List<String> _currentPathIds = [];
  List<LatLng> _routePoints = [];

  List<List<String>> _alternativePathIds = [];
  List<List<LatLng>> _alternativeRoutePoints = [];

  List<double> _routeDistancesMeters = [];
  String? _currentDestinationId;
  bool _isUserInsideCampus = true;

  final LatLngBounds campusBounds = LatLngBounds(
    const LatLng(20.6536983, -100.4074377),
    const LatLng(20.6590521, -100.4027016),
  );

  final Map<String, LatLngBounds> buildingBounds = {
    "Edificio Rectoria": LatLngBounds(
      LatLng(20.6541044, -100.4055756),
      LatLng(20.6545684, -100.4052765),
    ),
    "Edificio C": LatLngBounds(
      LatLng(20.6535139, -100.4054200),
      LatLng(20.6538444, -100.4049915),
    ),
    "Edificio K": LatLngBounds(
      LatLng(20.6542819, -100.4049312),
      LatLng(20.6545935, -100.4045201),
    ),
    "Laboratorio I": LatLngBounds(
      LatLng(20.6548339, -100.4048078),
      LatLng(20.6551356, -100.4043364),
    ),
    "Laboratorio J": LatLngBounds(
      LatLng(20.6550855, -100.4058485),
      LatLng(20.6554174, -100.4053999),
    ),
    

  };

  String? _currentBuildingInside;

  String? _detectBuilding(LatLng position) {
    for (final entry in buildingBounds.entries) {
      final bounds = entry.value;
      if (bounds.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }

  final Map<String, LatLng> nodeCoordinates = {
    "A": const LatLng(20.653198, -100.404034),
    "B": const LatLng(20.6536129, -100.4041278),
    "C": const LatLng(20.6536601, -100.4041372),
    "C1": const LatLng(20.6537071, -100.4038831),
    "C2": const LatLng(20.6537117, -100.4038449),
    "C3": const LatLng(20.6536801, -100.4037939),
    "C4": const LatLng(20.6536374, -100.4037644),
    "C5": const LatLng(20.6536462, -100.4036759),
    "C6": const LatLng(20.6535307, -100.4036866),
    "C7": const LatLng(20.6534505, -100.4036357),
    "C8": const LatLng(20.6537265, -100.4036611),
    "C9": const LatLng(20.6538068, -100.4035740),
    "Laboratorio E": const LatLng(20.6538432, -100.4039106),
    "EDF-EE": const LatLng(20.6538952, -100.4041037),
    "D": const LatLng(20.6535332, -100.4045556),
    "E": const LatLng(20.6536166, -100.4045724),
    "F": const LatLng(20.6536668, -100.4044343),
    "G": const LatLng(20.6537879, -100.4044604),
    "Laboratorio D": const LatLng(20.6539429, -100.4044987),
    "G2": const LatLng(20.6538337, -100.4041741),
    "G3": const LatLng(20.6538877, -100.4041855),
    "G4": const LatLng(20.6541247, -100.4042345),
    "G5": const LatLng(20.6541933, -100.4043256),
    "G6": const LatLng(20.6542654, -100.4043431),
    "G61": const LatLng(20.6541984, -100.4046267),
    "Edificio K": const LatLng(20.6543364, -100.4046629),
    "G7": const LatLng(20.6545396, -100.4044068),
    "G8": const LatLng(20.6545523, -100.4043572),
    "Edificio F": const LatLng(20.6545321, -100.4042043),
    "G9": const LatLng(20.6545748, -100.4042190),
    "G10": const LatLng(20.6545911, -100.4041372),
    "D2": const LatLng(20.6536004, -100.4046885),
    "D3": const LatLng(20.6536110, -100.4047126),
    "D4": const LatLng(20.6536200, -100.4047300),
    "D5": const LatLng(20.6536411, -100.4047434),
    "D6": const LatLng(20.6537264, -100.4047602),
    "H": const LatLng(20.6537164, -100.4048581),
    "I": const LatLng(20.6539624, -100.4049245),
    "J": const LatLng(20.6539229, -100.4051840),
    "Edificio C": const LatLng(20.6538124, -100.4051638),
    "K": const LatLng(20.6539918, -100.4052544),
    "K1": const LatLng(20.6540483, -100.4052705),
    "K2": const LatLng(20.6541017, -100.4049647),
    "L": const LatLng(20.6539887, -100.4055870),
    "L1": const LatLng(20.6540032, -100.4056346),
    "M": const LatLng(20.6542547, -100.4056855),
    "N": const LatLng(20.6541833, -100.4061180),
    "Edificio Vinculaciones": const LatLng(20.6540797, -100.4060972),
    "Edificio Rectoria": const LatLng(20.6542686, -100.4056178),
    "M1": const LatLng(20.6545359, -100.4057419),
    "M2": const LatLng(20.6545710, -100.4057419),
    "M3": const LatLng(20.6545955, -100.4057097),
    "M4": const LatLng(20.6546024, -100.4056701),
    "BH1": const LatLng(20.6548472, -100.4062776),
    "BH2": const LatLng(20.6549262, -100.4058498),
    "BH3": const LatLng(20.6549475, -100.4057492),
    "BH4": const LatLng(20.6550177, -100.4054361),
    "Laboratorio J": const LatLng(20.6551821, -100.4054736),
    "BH5": const LatLng(20.6550541, -100.4052644),
    "BH6": const LatLng(20.6550705, -100.4051840),
    "Enfermeria": const LatLng(20.6552009, -100.4051464),
    "BH7": const LatLng(20.6550855, -100.4051196),
    "BH8": const LatLng(20.6551269, -100.4049265),
    "Edificio H": const LatLng(20.6553233, -100.4046106),
    "BH9": const LatLng(20.6551928, -100.4045670),
    "BH10": const LatLng(20.6552405, -100.4042935),
    "BH11": const LatLng(20.6552638, -100.4041694),
    "O": const LatLng(20.6546714, -100.4053187),
    "P": const LatLng(20.6547159, -100.4051055),
    "Q": const LatLng(20.6545704, -100.4050720),
    "Q1": const LatLng(20.6545905, -100.4049694),
    "Q2": const LatLng(20.6546532, -100.4046730),
    "Q3": const LatLng(20.6547116, -100.4043907),
    "Q4": const LatLng(20.6547567, -100.4041761),
    "Laboratorio I": const LatLng(20.6548935, -100.4044323),
    "Cafeteria": const LatLng(20.6547210, -100.4050787),
    "CFF": const LatLng(20.6546714, -100.4049888),
    "CF1": const LatLng(20.6549763, -100.4053771),
    "CF2": const LatLng(20.6549926, -100.4053617),
    "CF3": const LatLng(20.6550228, -100.4051739),
    "CF4": const LatLng(20.6550666, -100.4049761),
    "CF5": const LatLng(20.6549300, -100.4049258),
    "CF6": const LatLng(20.6547895, -100.4048601),
    "CF7": const LatLng(20.6546539, -100.4046696),
    "BB1": const LatLng(20.6546557, -100.4039361),
    "BB2": const LatLng(20.6548012, -100.4037463),
    "BB3": const LatLng(20.6548213, -100.4037356),
    "BB4": const LatLng(20.6548822, -100.4037443),
    "Edificio de Idiomas": const LatLng(20.6549889, -100.4063152),
    "AUD1": const LatLng(20.6553591, -100.4059464),
    "AUD2": const LatLng(20.6554952, -100.4059142),
    "AUD3": const LatLng(20.6555348, -100.4057305),
    "AUD4": const LatLng(20.6557393, -100.4058042),
    "AUD5": const LatLng(20.6557996, -100.4055776),
    "Auditorio": const LatLng(20.6557933, -100.4059558),
    "Auditorio2": const LatLng(20.6558133, -100.4058304),
    "NA1": const LatLng(20.6555147, -100.4053724),
    "NA2": const LatLng(20.6556452, -100.4052544),
    "NANO1": const LatLng(20.6556791, -100.4050586),
    "NA3": const LatLng(20.6558002, -100.4052061),
    "NA4": const LatLng(20.6560059, -100.4052322),
    "NA5": const LatLng(20.6560662, -100.4050820),
    "NA6": const LatLng(20.6561107, -100.4048312),
    "Edificio Nanotecnologia": const LatLng(20.6559250, -100.4047930),
    "GP1": const LatLng(20.6556339, -100.4042619),
    "GP2": const LatLng(20.6556998, -100.4039662),
    "Edificio G": const LatLng(20.6556145, -100.4039468),
    "GP3": const LatLng(20.6561836, -100.4043947),
    "OUT1": const LatLng(20.6562770, -100.4051317),
    "OUT2": const LatLng(20.6562231, -100.4053925),
    "OUT3": const LatLng(20.6568750, -100.4052705),
    "OUT4": const LatLng(20.6571729, -100.4053295),
    "Cancha de Basquetball": const LatLng(20.6563041, -100.4054193),
    "Cancha de Futbol Rapido": const LatLng(20.6568349, -100.4055105),
    "Campo de Futbol": const LatLng(20.657201, -100.405160),
    "STE1": const LatLng(20.6562401, -100.4041332),
    "STEWC": const LatLng(20.6562300, -100.4041781),
    "STE2": const LatLng(20.6563611, -100.4035371),
    "Edificio Stellantis": const LatLng(20.6564427, -100.4035585),
    "INTEL1": const LatLng(20.6562865, -100.4040460),
    "INTEL2": const LatLng(20.6564527, -100.4039126),
    "INTEL3": const LatLng(20.6564885, -100.4039133),
    "INTEL4": const LatLng(20.6566980, -100.4039555),
    "INTEL5": const LatLng(20.6567288, -100.4039025),
    "INTEL6": const LatLng(20.6567395, -100.4038469),
    "INTEL7": const LatLng(20.6567595, -100.4038006),
    "INTEL8": const LatLng(20.6567997, -100.4037677),
    "INTEL9": const LatLng(20.6568737, -100.4037684),
    "INTEL10": const LatLng(20.6569089, -100.4037208),
    "INTEL11": const LatLng(20.6569365, -100.4036987),
    "INTEL12": const LatLng(20.6569917, -100.4037087),
    "INTEL13": const LatLng(20.6570507, -100.4037040),
    "INTEL14": const LatLng(20.6571015, -100.4036772),
    "INTEL15": const LatLng(20.6571404, -100.4036330),
    "INTEL16": const LatLng(20.6571611, -100.4035807),
    "INTEL17": const LatLng(20.6571655, -100.4035223),
    "INTEL18": const LatLng(20.6571611, -100.4034948),
    "INTEL19": const LatLng(20.6571561, -100.4034620),
    "INTEL20": const LatLng(20.6571216, -100.4034150),
    "INTEL21": const LatLng(20.6570758, -100.4033761),
    "INTEL22": const LatLng(20.6570231, -100.4033614),
    "INTEL23": const LatLng(20.6569559, -100.4036826),
    "Edificio Intel": const LatLng(20.6572621, -100.4035163),
    "CISCO1": const LatLng(20.6567439, -100.4039280),
    "CISCO2": const LatLng(20.6567784, -100.4039495),
    "CISCO3": const LatLng(20.6568191, -100.4039609),
    "CISCO4": const LatLng(20.6568593, -100.4039555),
    "CISCO5": const LatLng(20.6568944, -100.4039287),
    "CISCO6": const LatLng(20.6569195, -100.4038811),
    "CISCOA": const LatLng(20.6569245, -100.4038422),
    "CISCO7": const LatLng(20.6569942, -100.4038851),
    "CISCO8": const LatLng(20.6571667, -100.4038697),
    "CISCO9": const LatLng(20.6572759, -100.4037738),
    "CISCO10": const LatLng(20.6573305, -100.4038154),
    "CISCO11": const LatLng(20.6574196, -100.4038536),
    "CISCO12": const LatLng(20.6574717, -100.4038643),
    "CISCO13": const LatLng(20.6575118, -100.4036450),
    "CISCO14": const LatLng(20.6575915, -100.4036283),
    "CISCO14-1": const LatLng(20.6575633, -100.4035867),
    "CISCO14-2": const LatLng(20.6575376, -100.4035257),
    "CISCO14-3": const LatLng(20.6575325, -100.4034734),
    "CISCO14-4": const LatLng(20.6575426, -100.4034291),
    "CISCO14-5": const LatLng(20.6575683, -100.4033929),
    "CISCO15": const LatLng(20.6576129, -100.4036175),
    "CISCO16": const LatLng(20.6576781, -100.4035465),
    "CISCO17": const LatLng(20.6576875, -100.4034928),
    "CISCO18": const LatLng(20.6576875, -100.4034519),
    "CISCO19": const LatLng(20.6576618, -100.4033252),
    "CISCO20": const LatLng(20.6576474, -100.4032682),
    "CISCO21": const LatLng(20.6576323, -100.4032360),
    "CISCO22": const LatLng(20.6575809, -100.4031978),
    "CISCO23": const LatLng(20.6575382, -100.4031408),
    "CISCO24": const LatLng(20.6575131, -100.4031301),
    "CISCO25": const LatLng(20.6573111, -100.4031730),
    "CISCO26": const LatLng(20.6572609, -100.4031944),
    "CISCO27": const LatLng(20.6572207, -100.4032481),
    "Edificio CISCO": const LatLng(20.6577528, -100.4034566),
    "Baño1": const LatLng(20.6541387, -100.4041493),
    "Baño2": const LatLng(20.6562124, -100.4041754),
  };

  final Map<String, List<String>> nodeConnections = {
    "A": ["B"],
    "B": ["A", "C", "D"],
    "C": ["B", "G2", "C1"],
    "C1": ["C", "C2", "Laboratorio E"],
    "C2": ["C1", "C3"],
    "C3": ["C2", "C4"],
    "C4": ["C3", "C5"],
    "C5": ["C4", "C6", "C8"],
    "C6": ["C7", "C5"],
    "C7": ["C6"],
    "C8": ["C5", "C9"],
    "C9": ["C8"],
    "Laboratorio E": ["C1"],
    "EDF-EE": ["G3"],
    "D": ["B", "E"],
    "E": ["D", "F", "D2"],
    "F": ["E", "G"],
    "G": ["F", "Laboratorio D", "G2", "D6"],
    "Laboratorio D": ["G"],
    "G2": ["G", "C", "G3"],
    "G3": ["G2", "EDF-EE", "G4"],
    "G4": ["G3", "G5", "Baño1"],
    'Baño1': ["G4"],
    "G5": ["G4", "G6"],
    "G6": ["G5", "G7", "G61"],
    "G61": ["G6", "Edificio K", "K2"],
    "Edificio K": ["G61"],
    "G7": ["G6", "G8"],
    "G8": ["G7", "G9", "Q3"],
    "G9": ["G8", "G10", "Edificio F"],
    "Edificio F": ["G8"],
    "G10": ["G9", "Q4", "BB1"],
    "D2": ["E", "D3"],
    "D3": ["D2", "D4"],
    "D4": ["D3", "D5"],
    "D5": ["D4", "D6"],
    "D6": ["D5", "G", "H"],
    "H": ["D6", "I"],
    "I": ["H", "J", "K2"],
    "J": ["I", "Edificio C", "K"],
    "Edificio C": ["J"],
    "K": ["J", "K1"],
    "K1": ["K", "K2", "L"],
    "K2": ["K1", "I", "Q", "G61"],
    "L": ["K1", "L1"],
    "L1": ["L", "M"],
    "M": ["L1", "N", "Edificio Rectoria", "M1"],
    "N": ["M", "Edificio Vinculaciones"],
    "Edificio Vinculaciones": ["N"],
    "Edificio Rectoria": ["M"],
    "M1": ["M", "M2"],
    "M2": ["M1", "M3"],
    "M3": ["M2", "M4"],
    "M4": ["M3", "O", "BH3"],
    "Edificio de Idiomas": ["BH1"],
    "BH1": ["Edificio de Idiomas", "BH2"],
    "BH2": ["BH1", "BH3", "AUD1"],
    "BH3": ["M4", "BH2", "BH4"],
    "BH4": ["BH3", "BH5", "Laboratorio J"],
    "Laboratorio J": ["BH4"],
    "BH5": ["BH4", "BH6", "NA1"],
    "BH6": ["BH5", "BH7", "CF3"],
    "BH7": ["BH6", "BH8", "Enfermeria"],
    "Enfermeria": ["BH7"],
    "BH8": ["BH7", "BH9"],
    "BH9": ["BH8", "BH10", "Edificio H"],
    "Edificio H": ["BH9"],
    "BH10": ["BH9", "BH11", "Q4"],
    "BH11": ["BH10", "GP1"],
    "O": ["M4", "P", "CF1"],
    "P": ["O", "Q", "CF3", "Cafeteria"],
    "Q": ["P", "K2", "Q1"],
    "Q1": ["Q", "CFF", "Q2"],
    "Q2": ["Q1", "Q3", "CF7"],
    "Q3": ["Q2", "Q4", "Laboratorio I"],
    "Q4": ["Q3", "G10", "BH10"],
    "Laboratorio I": ["Q3"],
    "Cafeteria": ["P"],
    "CFF": ["Q1"],
    "CF1": ["O", "CF2"],
    "CF2": ["CF1", "CF3"],
    "CF3": ["CF2", "P", "CF4", "BH6"],
    "CF4": ["CF3", "CF5"],
    "CF5": ["CF4", "CF6"],
    "CF6": ["CF5", "CF7"],
    "CF7": ["CF6", "Q2"],
    "BB1": ["BB2", "G10"],
    "BB2": ["BB1", "BB3"],
    "BB3": ["BB2", "BB4"],
    "BB4": ["BB3"],
    "AUD1": ["AUD2", "BH2"],
    "AUD2": ["AUD1", "AUD3", "Auditorio"],
    "Auditorio": ["AUD2"],
    "AUD3": ["AUD2", "AUD4", "NA1"],
    "AUD4": ["AUD3", "Auditorio2"],
    "AUD5": ["AUD4", "NA4"],
    "Auditorio2": ["AUD4"],
    "NA1": ["NA2", "BH5", "AUD3"],
    "NA2": ["NA1", "NANO1", "NA3"],
    "NANO1": ["NA2"],
    "NA3": ["NA2", "NA4"],
    "NA4": ["NA3", "NA5", "AUD5"],
    "NA5": ["NA4", "NA6", "OUT1"],
    "NA6": ["NA5", "Edificio Nanotecnologia"],
    "Edificio Nanotecnologia": ["NA6"],
    "GP1": ["BH11", "GP2", "GP3"],
    "GP2": ["GP1", "Edificio G"],
    "Edificio G": ["GP2"],
    "GP3": ["GP1", "NA6", "STEWC"],
    "OUT1": ["NA5", "OUT2", "OUT3"],
    "OUT2": ["OUT1", "Cancha de Basquetball"],
    "OUT3": ["OUT1", "Cancha de Futbol Rapido", "OUT4"],
    "OUT4": ["OUT3", "Campo de Futbol"],
    "Cancha de Basquetball": ["OUT2"],
    "Cancha de Futbol Rapido": ["OUT3"],
    "Campo de Futbol": ["OUT4"],
    "STEWC": ["STE1", "Baño2", "GP3"],
    "Baño2": ["STEWC"],
    "STE1": ["STE2", "INTEL1", "STEWC"],
    "STE2": ["STE1", "Edificio Stellantis"],
    "Edificio Stellantis": ["STE2"],
    "INTEL1": ["INTEL2", "STE1"],
    "INTEL2": ["INTEL1", "INTEL3"],
    "INTEL3": ["INTEL2", "INTEL4"],
    "INTEL4": ["INTEL3", "INTEL5"],
    "INTEL5": ["INTEL4", "INTEL6", "CISCO1"],
    "INTEL6": ["INTEL5", "INTEL7"],
    "INTEL7": ["INTEL6", "INTEL8"],
    "INTEL8": ["INTEL7", "INTEL9"],
    "INTEL9": ["INTEL8", "INTEL10", "CISCOA"],
    "INTEL10": ["INTEL9", "INTEL11"],
    "INTEL11": ["INTEL10", "INTEL12", "INTEL23"],
    "INTEL12": ["INTEL11", "INTEL13"],
    "INTEL13": ["INTEL12", "INTEL14"],
    "INTEL14": ["INTEL13", "INTEL15"],
    "INTEL15": ["INTEL14", "INTEL16"],
    "INTEL16": ["INTEL15", "INTEL17"],
    "INTEL17": ["INTEL16", "INTEL18"],
    "INTEL18": ["INTEL17", "Edificio Intel", "INTEL19"],
    "INTEL19": ["INTEL18", "CISCO28", "INTEL20"],
    "INTEL20": ["INTEL19", "INTEL21"],
    "INTEL21": ["INTEL20", "INTEL22"],
    "INTEL22": ["INTEL21", "INTEL23"],
    "INTEL23": ["INTEL22", "INTEL11"],
    "Edificio Intel": ["INTEL18"],
    "CISCO1": ["INTEL5", "CISCO2"],
    "CISCO2": ["CISCO1", "CISCO3"],
    "CISCO3": ["CISCO2", "CISCO4"],
    "CISCO4": ["CISCO3", "CISCO5"],
    "CISCO5": ["CISCO4", "CISCO6"],
    "CISCO6": ["CISCO5", "CISCO7", "CISCOA"],
    "CISCOA": ["CISCO6", "INTEL9"],
    "CISCO7": ["CISCO6", "CISCO8"],
    "CISCO8": ["CISCO7", "CISCO9"],
    "CISCO9": ["CISCO8", "CISCO10"],
    "CISCO10": ["CISCO9", "CISCO11"],
    "CISCO11": ["CISCO10", "CISCO12"],
    "CISCO12": ["CISCO11", "CISCO13"],
    "CISCO13": ["CISCO12", "CISCO14"],
    "CISCO14": ["CISCO13", "CISCO15", "CISCO14-1"],
    "CISCO14-1": ["CISCO14", "CISCO14-2"],
    "CISCO14-2": ["CISCO14-1", "CISCO14-2"],
    "CISCO14-3": ["CISCO14-2", "CISCO14-3"],
    "CISCO14-4": ["CISCO14-3", "CISCO14-4"],
    "CISCO14-5": ["CISCO14-4", "CISCO19"],
    "CISCO15": ["CISCO14", "CISCO16"],
    "CISCO16": ["CISCO15", "CISCO17"],
    "CISCO17": ["CISCO16", "CISCO18"],
    "CISCO18": ["CISCO17", "Edificio CISCO", "CISCO19"],
    "CISCO19": ["CISCO20", "CISCO18", "CISCO14-5"],
    "CISCO20": ["CISCO19", "CISCO21"],
    "CISCO21": ["CISCO20", "CISCO22"],
    "CISCO22": ["CISCO21", "CISCO23"],
    "CISCO23": ["CISCO22", "CISCO24"],
    "CISCO24": ["CISCO23", "CISCO25"],
    "CISCO25": ["CISCO24", "CISCO26"],
    "CISCO26": ["CISCO25", "CISCO27"],
    "CISCO27": ["CISCO26", "INTEL19"],
    "Edificio CISCO": ["CISCO18"],
  };

  final List<String> buildingNodes = [
    "Edificio Rectoria",
    "Edificio Vinculaciones",
    "Auditorio",
    "Laboratorio E",
    "Laboratorio D",
    "Edificio C",
    "Edificio F",
    "Edificio G",
    "Edificio H",
    "Edificio K",
    "Edificio de Idiomas",
    "Edificio Nanotecnologia",
    "Edificio Stellantis",
    "Edificio Intel",
    "Edificio CISCO",
    "Enfermeria",
    "Cafeteria",
    "Cancha de Basquetball",
    "Cancha de Futbol Rapido",
    "Campo de Futbol",
    "Laboratorio I",
    "Laboratorio J",
    "Baño1",
    "Baño2",
  ];

  late final Map<String, CampusNode> campusGraph = _buildGraph();

  Map<String, CampusNode> _buildGraph() {
    final Map<String, CampusNode> graph = {};
    for (var id in nodeCoordinates.keys) {
      graph[id] = CampusNode(
        id: id,
        position: nodeCoordinates[id]!,
        neighbors: nodeConnections[id] ?? [],
      );
    }
    return graph;
  }

  @override
  void initState() {
    super.initState();
    if (debugUseNodeA) {
      _userPosition = campusGraph["CISCO14-5"]?.position;
    } else {
      _initLocation();
    }

    if (widget.initialDestinationId != null) {
      final destId = widget.initialDestinationId!;
      if (campusGraph.containsKey(destId)) {
        final destPos = campusGraph[destId]!.position;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(destPos, 18.5);
        });
      }
    }
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    );

    _positionStream!.listen((Position pos) {
      LatLng newPos = LatLng(pos.latitude, pos.longitude);
      bool inside = campusBounds.contains(newPos);

      setState(() {
        _isUserInsideCampus = inside;
        _currentBuildingInside = inside ? _detectBuilding(newPos) : null;
        _userPosition = newPos;
      });

      if (inside && _currentDestinationId != null) {
        _handleAutoRecalculation(newPos);
      }
    });
  }

  void _calculateMultipleCampusRoutesTo(String destinationId) {
    if (_userPosition == null || !_isUserInsideCampus) {
      _showOutsideCampusMessage();
      return;
    }

    _updateUserNodeInGraph(_userPosition!);
    _currentDestinationId = destinationId;

    setState(() {
      _currentPathIds = [];
      _routePoints = [];
      _alternativePathIds = [];
      _alternativeRoutePoints = [];
      _routeDistancesMeters = [];
    });

    List<String> mainPath = _dijkstra("US", destinationId);
    if (mainPath.isEmpty || mainPath.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró ruta válida")),
      );
      return;
    }

    double mainDist = _calculatePathDistance(mainPath);
    List<LatLng> mainPoints = mainPath
        .map((id) => campusGraph[id]!.position)
        .toList();

    List<List<String>> alternatives = [];
    List<double> altDistances = [];

    if (mainPath.length >= 4) {
      String avoid = mainPath[1];
      List<String> alt = _dijkstraAvoidingNode("US", destinationId, avoid);
      if (alt.isNotEmpty && _pathsAreDifferent(alt, mainPath)) {
        alternatives.add(alt);
        altDistances.add(_calculatePathDistance(alt));
      }
    }

    if (mainPath.length >= 6) {
      String avoid = mainPath[mainPath.length ~/ 2];
      List<String> alt = _dijkstraAvoidingNode("US", destinationId, avoid);
      if (alt.isNotEmpty &&
          _pathsAreDifferent(alt, mainPath) &&
          !alternatives.any((p) => !_pathsAreDifferent(p, alt))) {
        alternatives.add(alt);
        altDistances.add(_calculatePathDistance(alt));
      }
    }

    if (mainPath.length >= 4) {
      String avoid = mainPath[mainPath.length - 2];
      List<String> alt = _dijkstraAvoidingNode("US", destinationId, avoid);
      if (alt.isNotEmpty &&
          _pathsAreDifferent(alt, mainPath) &&
          !alternatives.any((p) => !_pathsAreDifferent(p, alt))) {
        alternatives.add(alt);
        altDistances.add(_calculatePathDistance(alt));
      }
    }

    List<Map<String, dynamic>> all = [
      {"path": mainPath, "dist": mainDist, "main": true},
      ...alternatives.asMap().entries.map(
        (e) => {"path": e.value, "dist": altDistances[e.key], "main": false},
      ),
    ]..sort((a, b) => a["dist"].compareTo(b["dist"]));

    all = all.take(4).toList();

    setState(() {
      _currentPathIds = all.first["path"];
      _routePoints = all.first["path"]
          .map<LatLng>((id) => campusGraph[id]!.position)
          .toList();

      _routeDistancesMeters = all
          .map<double>((r) => r["dist"] as double)
          .toList();

      _alternativePathIds = all
          .skip(1)
          .map<List<String>>((r) => r["path"] as List<String>)
          .toList();

      _alternativeRoutePoints = _alternativePathIds
          .map(
            (path) =>
                path.map<LatLng>((id) => campusGraph[id]!.position).toList(),
          )
          .toList();
    });

    _fitCameraToAllRoutes();
    _showRoutesInfoSnackBar();
  }

  double _calculatePathDistance(List<String> path) {
    double total = 0.0;
    for (int i = 0; i < path.length - 1; i++) {
      total += const Distance().as(
        LengthUnit.Meter,
        campusGraph[path[i]]!.position,
        campusGraph[path[i + 1]]!.position,
      );
    }
    return total;
  }

  List<String> _dijkstraAvoidingNode(String start, String end, String avoid) {
    if (!campusGraph.containsKey(avoid)) return [];

    final tempNeighbors = List<String>.from(campusGraph[avoid]!.neighbors);
    campusGraph.remove(avoid);

    final path = _dijkstra(start, end);

    campusGraph[avoid] = CampusNode(
      id: avoid,
      position: nodeCoordinates[avoid]!,
      neighbors: tempNeighbors,
    );

    return path;
  }

  bool _pathsAreDifferent(List<String> a, List<String> b) {
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return true;
    }
    return false;
  }

  void _fitCameraToAllRoutes() {
    List<LatLng> allPts = [..._routePoints];
    for (var pts in _alternativeRoutePoints) {
      allPts.addAll(pts);
    }
    if (allPts.length < 2) return;

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(allPts),
        padding: const EdgeInsets.all(60),
      ),
    );
  }

  void _showRoutesInfoSnackBar() {
    if (_routeDistancesMeters.isEmpty) return;

    const double speedKmH = 4.8;
    final timesMin = _routeDistancesMeters
        .map((m) => (m / 1000 / speedKmH) * 60)
        .toList();
  }

  List<String> _dijkstra(String start, String end) {
    if (!campusGraph.containsKey(start) || !campusGraph.containsKey(end)) {
      return [];
    }

    final distances = <String, double>{};
    final previous = <String, String?>{};
    final unvisited = <String>{};

    for (var node in campusGraph.keys) {
      distances[node] = double.infinity;
      previous[node] = null;
      unvisited.add(node);
    }

    distances[start] = 0;

    while (unvisited.isNotEmpty) {
      String current = unvisited.reduce(
        (a, b) => distances[a]! < distances[b]! ? a : b,
      );

      if (distances[current] == double.infinity) break;
      unvisited.remove(current);

      if (current == end) break;

      for (var neigh in campusGraph[current]!.neighbors) {
        if (!unvisited.contains(neigh)) continue;

        final alt =
            distances[current]! +
            const Distance().as(
              LengthUnit.Meter,
              campusGraph[current]!.position,
              campusGraph[neigh]!.position,
            );

        if (alt < distances[neigh]!) {
          distances[neigh] = alt;
          previous[neigh] = current;
        }
      }
    }

    if (previous[end] == null && start != end) return [];

    List<String> path = [];
    String? curr = end;
    while (curr != null) {
      path.insert(0, curr);
      curr = previous[curr];
    }
    return path;
  }

  void _updateUserNodeInGraph(LatLng pos) {
    String closest = _findClosestNode(pos);
    campusGraph["US"] = CampusNode(
      id: "US",
      position: pos,
      neighbors: [closest],
    );
  }

  String _findClosestNode(LatLng pos) {
    double minDist = double.infinity;
    String? closest;

    for (var entry in nodeCoordinates.entries) {
      double d = const Distance().as(LengthUnit.Meter, pos, entry.value);
      if (d < minDist) {
        minDist = d;
        closest = entry.key;
      }
    }
    return closest ?? nodeCoordinates.keys.first;
  }

  void _handleAutoRecalculation(LatLng current) {
    if (_currentDestinationId == null || _routePoints.isEmpty) return;

    if (_isFarFromRoute(current)) {
      _calculateMultipleCampusRoutesTo(_currentDestinationId!);
    }
  }

  bool _isFarFromRoute(LatLng pos) {
    if (_routePoints.isEmpty) return false;
    double minD = double.infinity;
    for (var p in _routePoints) {
      double d = const Distance().as(LengthUnit.Meter, pos, p);
      if (d < minD) minD = d;
    }
    return minD > 15;
  }

  void _showOutsideCampusMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Debes estar dentro del campus para generar rutas",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  List<Marker> _buildBuildingMarkers() {
    return buildingNodes.map((id) {
      final node = campusGraph[id]!;

      return Marker(
        point: node.position,
        width: 200,
        height: 80,
        child: GestureDetector(
          onTap: () async {
            if (!_isUserInsideCampus) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Debes estar dentro del campus para interactuar con los edificios",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
              return;
            }

            String? imageUrl;
            String timeText = "—";
            String coords =
                "Lat: ${node.position.latitude.toStringAsFixed(6)}\n"
                "Lng: ${node.position.longitude.toStringAsFixed(6)}";

            if (_userPosition != null) {
              _updateUserNodeInGraph(_userPosition!);
              List<String> path = _dijkstra("US", id);
              double distance = _calculatePathDistance(path);
              const double speedKmH = 4.8;
              double timeMin = (distance / 1000 / speedKmH) * 60;
              timeText = "${timeMin.toStringAsFixed(1)} min";
            }

            try {
              final response = await Supabase.instance.client
                  .from('edificios')
                  .select('imagen_url')
                  .eq('name_building', id)
                  .maybeSingle();

              if (response != null && response['imagen_url'] != null) {
                imageUrl = response['imagen_url'] as String;
              }
            } catch (e) {
              debugPrint("Error al consultar imagen de $id: $e");
            }

            if (!mounted) return;

            showBuildingModal(
              context,
              name: id,
              coordinates: coords,
              time: timeText,
              imageUrl: imageUrl ?? 'assets/images/default_building.jpg',
            );

            _calculateMultipleCampusRoutesTo(id);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white,
                child: Text(
                  id,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void showBuildingModal(
    BuildContext context, {
    required String name,
    required String coordinates,
    required String time,
    required String imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      imageUrl.startsWith('http') ||
                          imageUrl.startsWith('https')
                      ? Image.network(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _defaultImagePlaceholder(),
                        )
                      : Image.asset(
                          imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _defaultImagePlaceholder(),
                        ),
                ),
                const SizedBox(height: 16),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  coordinates,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Tiempo estimado: $time",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Marker? _buildUserMarker() {
    if (_userPosition == null) return null;
    return Marker(
      point: _userPosition!,
      width: 40,
      height: 40,
      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
    );
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(20.653400, -100.404080),
            initialZoom: 17,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.tuempresa.mapposting',
            ),

            MarkerLayer(
              markers: [
                ..._buildBuildingMarkers(),
                if (_buildUserMarker() != null) _buildUserMarker()!,
                if (widget.initialDestinationId != null &&
                    campusGraph.containsKey(widget.initialDestinationId))
                  Marker(
                    point: campusGraph[widget.initialDestinationId!]!.position,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.purple,
                      size: 50,
                    ),
                  ),
              ],
            ),

            if (_routePoints.isNotEmpty || _alternativeRoutePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  ...List.generate(_alternativeRoutePoints.length, (i) {
                    final indexFromEnd = _alternativeRoutePoints.length - 1 - i;
                    final points = _alternativeRoutePoints[indexFromEnd];
                    final distance = _routeDistancesMeters[indexFromEnd + 1];

                    final isLongest =
                        indexFromEnd == _alternativeRoutePoints.length - 1;
                    final color = isLongest
                        ? const Color(0xFF98FB98)
                        : Colors.green.withOpacity(0.7 - (i * 0.15));

                    return Polyline(
                      points: points,
                      strokeWidth: isLongest ? 3.5 : 4.5 - (i * 0.6),
                      color: color,
                    );
                  }),

                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 7.0,
                      color: Colors.green.shade800,
                      borderColor: Colors.green.shade900,
                      borderStrokeWidth: 2.0,
                    ),
                ],
              ),
          ],
        ),

        if (!_isUserInsideCampus)
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Estás fuera del campus.\nLa navegación se activará al ingresar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              _zoomButton(Icons.add, _zoomIn),
              const SizedBox(height: 8),
              _zoomButton(Icons.remove, _zoomOut),
            ],
          ),
        ),
      ],
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.listen(null).cancel();
    super.dispose();
  }
}
