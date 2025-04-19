// image_paths.dart
/// ---------------------------------------------------------------------------
/// Este archivo contiene todas las rutas de imágenes utilizadas en el juego.
/// En particular, define las rutas de sprites por cada dirección para cada barco.
/// Cada barco tiene 4 imágenes diferentes, una por orientación.
/// ---------------------------------------------------------------------------
library;

class ImagePaths {
  /// Rutas organizadas por ID de barco y dirección:
  /// Ejemplo: todosLosSpritesPorDireccion['1']?['arriba'] → "barcos/barco1_arriba.png"
  static final Map<String, Map<String, String>> todosLosSpritesPorDireccion = {
    '1': {'arriba': 'barco1_arriba.png', 'derecha': 'barco1_derecha.png', 'abajo': 'barco1_abajo.png', 'izquierda': 'barco1_izquierda.png'},
    '2': {'arriba': 'barco2_arriba.png', 'derecha': 'barco2_derecha.png', 'abajo': 'barco2_abajo.png', 'izquierda': 'barco2_izquierda.png'},
    '3': {'arriba': 'barco3_arriba.png', 'derecha': 'barco3_derecha.png', 'abajo': 'barco3_abajo.png', 'izquierda': 'barco3_izquierda.png'},
    '4': {'arriba': 'barco4_arriba.png', 'derecha': 'barco4_derecha.png', 'abajo': 'barco4_abajo.png', 'izquierda': 'barco4_izquierda.png'},
    '5': {'arriba': 'barco5_arriba.png', 'derecha': 'barco5_derecha.png', 'abajo': 'barco5_abajo.png', 'izquierda': 'barco5_izquierda.png'},
  };

  /// Lista plana de todas las rutas de imágenes (para precarga masiva).
  static List<String> get todasLasImagenes => todosLosSpritesPorDireccion.values.expand((mapaDirecciones) => mapaDirecciones.values).toList();
}
