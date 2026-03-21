import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/professors/views/building.detail.view.dart';
import 'package:flutter_front/features/auth/controllers/auth_controller.dart';

class SearchBuildingView extends StatefulWidget {
  const SearchBuildingView({Key? key}) : super(key: key);

  @override
  State<SearchBuildingView> createState() => _SearchBuildingViewState();
}

class _SearchBuildingViewState extends State<SearchBuildingView> {
  final AuthController _authController = Get.find();
  final TextEditingController _searchController = TextEditingController();
  final Dio dio = Dio();

  List<Map<String, dynamic>> _buildings = [];
  List<Map<String, dynamic>> _filteredBuildings = [];

  // Edificio más buscado (neurona)
  Map<String, dynamic>? _topBuilding;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _loadTopBuilding();
    _searchController.addListener(_filterBuildings);
  }

  // ── Carga el edificio más buscado desde la neurona ──────────
  Future<void> _loadTopBuilding() async {
    try {
      final response = await dio.get(
        "https://maposting-backend.onrender.com/edificios/top/buscado",
      );
      setState(() {
        _topBuilding = response.data as Map<String, dynamic>;
      });
    } catch (e) {
      // Si no hay búsquedas aún simplemente no muestra la tarjeta
      print("Sin top building aún: $e");
    }
  }

  // ── Registra la búsqueda en la neurona al escribir ──────────
  Future<void> _registrarBusqueda(String query) async {
    if (query.trim().isEmpty) return;
    try {
      await dio.post(
        "https://maposting-backend.onrender.com/edificios/buscar",
        data: {"query": query},
      );
    } catch (e) {
      print("Error registrando búsqueda: $e");
    }
  }

  Future<void> _loadBuildings() async {
    try {
      final buildingsResponse = await dio.get(
        "https://maposting-backend.onrender.com/edificios",
      );
      final professorsResponse = await dio.get(
        "https://maposting-backend.onrender.com/profesoresf",
      );

      final buildingsData = buildingsResponse.data as List<dynamic>;
      final professorsData = professorsResponse.data as List<dynamic>;

      List<Map<String, dynamic>> buildings = [];

      for (var building in buildingsData) {
        int professorCount = professorsData
            .where((p) => p["id_building"] == building["id_building"])
            .length;

        buildings.add({
          "id": building["id_building"],
          "nombre": building["name_building"].toString(),
          "codigo": building["code_building"]?.toString() ?? "",
          "imagen": building["imagen_url"]?.toString() ?? "",
          "lat": building["lat_building"] as double?,
          "lon": building["lon_building"] as double?,
          "descripcion": building["descrip_building"]?.toString() ?? "",
          "profesores_count": professorCount,
        });
      }

      setState(() {
        _buildings = buildings;
        _filteredBuildings = buildings;
      });
    } catch (e) {
      print("ERROR CARGANDO EDIFICIOS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar edificios: $e')),
      );
    }
  }

  void _filterBuildings() {
    final query = _searchController.text.toLowerCase();

    // Registra la búsqueda en la neurona
    if (query.isNotEmpty) _registrarBusqueda(query);

    setState(() {
      _filteredBuildings = _buildings
          .where((b) => b["nombre"]!.toLowerCase().contains(query))
          .toList();
    });
  }

  // ── Navega al detalle de un edificio ────────────────────────
  void _irADetalle(Map<String, dynamic> building) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuildingDetailView(
          idBuilding: building["id"],
          nameBuilding: building["nombre"],
          codeBuilding: building["codigo"],
          imagenUrl: building["imagen"],
          latBuilding: building["lat"],
          lonBuilding: building["lon"],
          descriptionBuilding: building["descripcion"],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Tarjeta "Más buscado" estilo Google Maps ─────────────────
  Widget _buildTopBuildingCard() {
    if (_topBuilding == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Busca el edificio en la lista local para navegar al detalle
          final match = _buildings.firstWhere(
            (b) => b["id"] == _topBuilding!["id_building"],
            orElse: () => {},
          );
          if (match.isNotEmpty) _irADetalle(match);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                GlobalColors.mainColor.withOpacity(0.85),
                GlobalColors.mainColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: GlobalColors.mainColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Imagen o ícono
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _topBuilding!["imagen_url"] != null &&
                        _topBuilding!["imagen_url"].toString().isNotEmpty
                    ? Image.network(
                        _topBuilding!["imagen_url"],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                      )
                    : _buildFallbackIcon(),
              ),
              const SizedBox(width: 14),
              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department,
                            color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          "Más buscado",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _topBuilding!["name_building"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_topBuilding!["veces_buscado"]} búsquedas",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.white24,
      child: const Icon(Icons.apartment, color: Colors.white, size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Buscar Edificios",
          style: TextStyle(
            color: GlobalColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar edificio...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Tarjeta más buscado — solo cuando no hay texto en el buscador
          if (_searchController.text.isEmpty) _buildTopBuildingCard(),

          if (_searchController.text.isEmpty && _topBuilding != null)
            const SizedBox(height: 8),

          // Lista de edificios
          Expanded(
            child: _filteredBuildings.isEmpty
                ? const Center(
                    child: Text(
                      "No se encontraron edificios",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredBuildings.length,
                    itemBuilder: (context, index) {
                      final building = _filteredBuildings[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                GlobalColors.mainColor.withOpacity(0.1),
                            radius: 28,
                            child: Icon(
                              Icons.apartment,
                              color: GlobalColors.mainColor,
                              size: 32,
                            ),
                          ),
                          title: Text(
                            building["nombre"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "${building["profesores_count"]} profesor${building["profesores_count"] == 1 ? '' : 'es'}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () => _irADetalle(building),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}