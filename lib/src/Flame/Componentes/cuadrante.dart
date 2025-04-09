/// ---------------------------------------------------------------------------
/// Clase `Cuadrante`
/// Representa una de las cinco fuerzas del modelo de Porter en el tablero.
/// Cada cuadrante tiene un nombre y un conjunto de celdas que lo componen.
/// ---------------------------------------------------------------------------
library;

import 'celda.dart';

class Cuadrante {
  /// Nombre que identifica al cuadrante (por ejemplo: A, B, C, D, E).
  final String nombre;

  /// Lista de celdas que pertenecen a este cuadrante.
  final List<Celda> celdas = [];

  /// Constructor para crear un [Cuadrante] con un [nombre].
  Cuadrante({required this.nombre});

  /// Añade una [celda] a este cuadrante si aún no está presente
  /// y actualiza la referencia de la celda a este cuadrante.
  void agregarCelda(Celda celda) {
    if (!celdas.contains(celda)) {
      celdas.add(celda);
      celda.agregarACuadrante(nombre);
    }
  }

  /// Verifica si una [celda] específica pertenece a este cuadrante.
  bool contieneCelda(Celda celda) => celdas.contains(celda);

  /// Devuelve una lista de coordenadas (fila, columna) de las celdas del cuadrante.
  List<(int, int)> obtenerCoordenadas() {
    return celdas.map((celda) => (celda.fila, celda.columna)).toList();
  }

  /// Devuelve la cantidad total de celdas en el cuadrante.
  int get cantidadCeldas => celdas.length;
}
