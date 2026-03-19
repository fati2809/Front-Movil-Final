import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/professors/views/professor.detail.view.dart';

class BuildingProfessorsView extends StatefulWidget {
  final String buildingName;
  final int buildingId;

  const BuildingProfessorsView({
    super.key,
    required this.buildingName,
    required this.buildingId,
  });

  @override
  State<BuildingProfessorsView> createState() => _BuildingProfessorsViewState();
}

class _BuildingProfessorsViewState extends State<BuildingProfessorsView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _professors = [];
  List<dynamic> _filteredProfessors = [];
  bool _isLoading = true;

  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchProfessors();
    _searchController.addListener(_filterProfessors);
  }

  Future<void> fetchProfessors() async {
    setState(() => _isLoading = true);

    try {
      final response = await dio.get(
        "https://maposting-backend.onrender.com/profesoresf/edificio/${widget.buildingId}",
      );

      if (response.statusCode == 200) {
        setState(() {
          _professors = List<Map<String, dynamic>>.from(response.data ?? []);
          _filteredProfessors = _professors;
          _isLoading = false;
        });
      } else {
        _showError("Error en la respuesta del servidor (${response.statusCode})");
      }
    } catch (e) {
      _showError("No se pudieron cargar los profesores");
      print("Error cargando profesores: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _filterProfessors() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredProfessors = _professors.where((prof) {
        final nombre = prof["nombre_profe"]?.toString().toLowerCase() ?? '';
        final planta = prof["planta_profe"]?.toString().toLowerCase() ?? '';
        return nombre.contains(query) || planta.contains(query);
      }).toList();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GlobalColors.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.buildingName,
          style: TextStyle(
            color: GlobalColors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar profesor...',
                prefixIcon: Icon(Icons.search, color: GlobalColors.mainColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Profesores',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_filteredProfessors.length} profesores',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProfessors.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron profesores',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProfessors.length,
                        itemBuilder: (context, index) {
                          final professor = _filteredProfessors[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  GlobalColors.mainColor.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: GlobalColors.mainColor,
                              ),
                            ),
                            title: Text(
                              professor["nombre_profe"] ?? 'Sin nombre',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Planta ${professor["planta_profe"] ?? 'N/A'}",
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: GlobalColors.mainColor,
                            ),
                                                    onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfessorDetailView(
                                idProfe: professor["id_profe"],  // ← nuevo campo requerido
                                professorName: professor["nombre_profe"] ?? 'Sin nombre',
                                office: professor["planta_profe"]?.toString() ?? 'N/A',
                                building: widget.buildingName,
                              ),
                            ),
                          );
                        },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}