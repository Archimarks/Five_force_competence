// coordenada.dart
//
// Componente visual que representa una coordenada (letra o número) para los bordes del tablero 12x12.
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'extension_canvas.dart';

/// Componente que muestra una coordenada (A-L o 1-12) en el borde del tablero.
class Coordenada extends Component {
  /// Posición en pantalla donde se renderiza el texto.
  final Vector2 posicion;

  /// Texto de la coordenada (ej: "A", "1", "L", "12").
  final String texto;

  /// Estilo visual del texto.
  final TextStyle estilo;

  Coordenada({
    required this.posicion,
    required this.texto,
    this.estilo = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
  });

  @override
  void render(Canvas canvas) {
    // Utiliza la extensión para dibujar el texto de forma sencilla.
    canvas.drawText(texto, posicion.toOffset(), estilo);
  }
}
