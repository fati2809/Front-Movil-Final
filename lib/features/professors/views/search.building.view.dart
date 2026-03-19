import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/professors/views/building.detail.view.dart'; // ← Cambia a tu BuildingDetailView
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

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _searchController.addListener(_filterBuildings);
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
        // Contar profesores en este edificio
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar edificios: $e')));
    }
  }

  void _filterBuildings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBuildings = _buildings
          .where(
            (building) => building["nombre"]!.toLowerCase().contains(query),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                            backgroundColor: GlobalColors.mainColor.withOpacity(
                              0.1,
                            ),
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
                          onTap: () {
                            // Navegación al detalle del edificio
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

                            // Alternativa con GetX (si prefieres):
                            // Get.to(() => BuildingDetailView(
                            //   idBuilding: building["id"],
                            //   nameBuilding: building["nombre"],
                            //   codeBuilding: building["codigo"],
                            //   imagenUrl: building["imagen"],
                            //   latBuilding: building["lat"],
                            //   lonBuilding: building["lon"],
                            //   nameDiv: building["division"],
                            // ));
                          },
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
