// extension_canvas.dart
//
// Extensiones para facilitar el dibujo de texto en el lienzo y conversión entre tipos de coordenadas.
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Extensión sobre Canvas para permitir el dibujo fácil de texto.
extension DibujoTextoEnLienzo on Canvas {
  /// Dibuja texto en una posición específica del lienzo con estilo y alineación.
  void drawText(
    String texto,
    Offset posicion,
    TextStyle estilo, {
    TextAlign alineacion = TextAlign.center,
    TextDirection direccionTexto = TextDirection.ltr,
  }) {
    final pintorTexto = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: alineacion,
      textDirection: direccionTexto,
    )..layout();

    pintorTexto.paint(this, posicion);
  }
}

/// Extensión para convertir un [Offset] de Flutter a un [Vector2] de Flame.
extension ConversorVector2 on Offset {
  Vector2 aVector2() => Vector2(dx, dy);
}
