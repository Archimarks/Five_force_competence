import 'dart:ui';

import 'package:flame/game.dart';

/// ---------------------------------------------------------------------------
/// CLASE: Sector
///
/// Representa un área rectangular dentro del tablero de juego, asociada a una
/// de las Cinco Fuerzas Competitivas de Porter. Permite verificar si una
/// posición (Vector2) pertenece a este sector.
/// ---------------------------------------------------------------------------
class Sector {
  /// Identificador único del sector.
  final String id;

  /// Nombre del sector, correspondiente a una de las Fuerzas de Porter.
  final String nombre;

  /// Rectángulo que define los límites del sector dentro del tablero.
  final Rect rect;

  /// Crea un nuevo `Sector`.
  Sector({required this.id, required this.nombre, required this.rect});

  /// Verifica si una posición (Vector2) está dentro de los límites de este sector.
  bool contiene(Vector2 posicion) {
    return rect.contains(posicion.toOffset());
  }
}
