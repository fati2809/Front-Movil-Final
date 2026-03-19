import 'package:flutter/material.dart';
import 'package:flutter_front/utils/global.colors.dart';

class MapGuideView extends StatelessWidget {
  const MapGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guía de uso del Mapa'),
        backgroundColor: GlobalColors.mainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introducción
            const Text(
              '¿Cómo leer el mapa del campus?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: 'Ruta principal (la más recomendada)',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Línea más gruesa (7 px)\n'
                    '• Color verde oscuro intenso\n'
                    '• Es la ruta **más corta** en distancia\n'
                    '• Siempre se muestra en la parte superior (encima de las demás)',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              color: Colors.green.shade800,
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Rutas alternativas',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Se muestran hasta 3 rutas alternativas (si existen)\n'
                    '• Ordenadas de más corta a más larga\n'
                    '• Cuanto más larga la ruta → más clara y delgada es la línea\n\n'
                    'Colores y grosores aproximados:\n'
                    '• Verde lima claro (más delgada) → ruta más larga\n'
                    '• Verde medio → ruta intermedia\n'
                    '• Verde más oscuro → ruta alternativa más corta',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              color: const Color(0xFF98FB98), // verde lima ejemplo
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Marcadores de edificios',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Icono rojo con el nombre del edificio\n'
                    '• Al tocarlo:\n'
                    '  - Aparece un modal con foto, coordenadas y tiempo estimado\n'
                    '  - Se calculan las rutas hacia ese edificio\n'
                    '  - La cámara se ajusta automáticamente para mostrar todas las rutas',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Tu ubicación actual',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Icono azul (my_location)\n'
                    '• Se actualiza en tiempo real si tienes GPS activado\n'
                    '• Si estás fuera del campus aparece un aviso rojo arriba',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Controles adicionales',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Botones + / − (arriba a la derecha) → zoom\n'
                    '• El mapa se ajusta automáticamente cuando se generan rutas\n'
                    '• Si te alejas mucho de la ruta sugerida, se recalcula automáticamente',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              color: Colors.grey.shade700,
            ),

            const SizedBox(height: 32),

            // Botón para volver al mapa
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.map),
                label: const Text('Volver al mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalColors.mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}