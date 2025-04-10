// extension_canvas.dart
// extension_canvas.dart
//
// Extensiones para facilitar el dibujo de texto en el lienzo y conversión entre tipos de coordenadas.

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// Extensión sobre la clase `Canvas` para facilitar el dibujo
/// de texto personalizado directamente sobre el lienzo.
/// ------------------------------------------------------------
extension DibujoTextoEnLienzo on Canvas {
  /// Dibuja texto en una posición específica del lienzo con un estilo determinado.
  ///
  /// ### Parámetros:
  /// * `texto` - Texto que se desea dibujar.
  /// * `posicion` - Coordenadas en las que se posiciona el texto dentro del lienzo.
  /// * `estilo` - Estilo visual del texto (`TextStyle`).
  ///
  /// ### Parámetros opcionales:
  /// * `alineacion` - Alineación horizontal del texto (por defecto: `TextAlign.center`).
  /// * `direccionTexto` - Dirección del texto (por defecto: `TextDirection.ltr`).
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

/// ------------------------------------------------------------
/// Extensión para facilitar la conversión de un objeto `Offset`
/// de Flutter a un `Vector2` utilizado en Flame.
/// ------------------------------------------------------------
extension ConversorVector2 on Offset {
  /// Convierte el objeto `Offset` actual en un `Vector2`.
  Vector2 aVector2() => Vector2(dx, dy);
}

/// ------------------------------------------------------------
/// Extensión para facilitar la conversión de un `Vector2`
/// de Flame a un `Offset` utilizado en Flutter.
/// ------------------------------------------------------------
extension ConversorOffset on Vector2 {
  /// Convierte el objeto `Vector2` actual en un `Offset`.
  Offset aOffset() => Offset(x, y);
}
