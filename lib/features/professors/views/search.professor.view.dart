import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_front/utils/global.colors.dart';
import 'package:flutter_front/features/professors/views/professor.detail.view.dart';

class SearchAllProfessorsView extends StatefulWidget {
  const SearchAllProfessorsView({super.key});

  @override
  State<SearchAllProfessorsView> createState() => _SearchAllProfessorsViewState();
}

class _SearchAllProfessorsViewState extends State<SearchAllProfessorsView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _professors = [];
  List<dynamic> _filteredProfessors = [];
  bool _isLoading = true;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _fetchAllProfessors();
    _searchController.addListener(_filterProfessors);
  }

  Future<void> _fetchAllProfessors() async {
    setState(() => _isLoading = true);
    try {
      // Endpoint para TODOS los profesores (sin filtro por edificio)
      final response = await dio.get(
        "http://localhost:8000/profesoresf",  // ← Cambia por tu URL real
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
      print("Error cargando todos los profesores: $e");
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
        // Puedes agregar más campos si quieres filtrar por división o edificio
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
          'Buscar Profesores',
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
                hintText: 'Buscar por nombre o planta...',
                prefixIcon: Icon(Icons.search, color: GlobalColors.mainColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Título y contador
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
                  '${_filteredProfessors.length} profesores encontrados',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista
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
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    GlobalColors.mainColor.withOpacity(0.15),
                                child: Icon(
                                  Icons.person,
                                  color: GlobalColors.mainColor,
                                  size: 32,
                                ),
                              ),
                              title: Text(
                                professor["nombre_profe"] ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Planta: ${professor["planta_profe"] ?? 'No especificada'}",
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  if (professor["name_div"] != null)
                                    Text(
                                      "División: ${professor["name_div"]}",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfessorDetailView(
                                    idProfe: professor["id_profe"],  // ← esto faltaba
                                    professorName: professor["nombre_profe"] ?? 'Sin nombre',
                                    office: professor["planta_profe"]?.toString() ?? 'N/A',
                                    building: professor["name_building"] ?? 'No asignado',
                                  ),
                                ),
                              );
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