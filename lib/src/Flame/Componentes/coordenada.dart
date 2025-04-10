// coordenada.dart
// coordenada.dart
//
// Componente visual que representa una coordenada (letra o número)
// para los bordes del tablero 12x12 en el juego.

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// `Coordenada` es un componente visual personalizado que representa una letra
/// (A–L) o un número (1–12) en los bordes del tablero. Se utiliza en el diseño
/// del juego tipo batalla naval para identificar filas y columnas.
///
/// Este componente hace uso de una extensión (`drawText`) sobre el lienzo para
/// renderizar el texto de manera sencilla.
/// ---------------------------------------------------------------------------
class Coordenada extends TextComponent {
  /// Constructor de `Coordenada`.
  ///
  /// * [texto] Es el contenido que se desea mostrar.
  /// * [posicion] Define la ubicación en el lienzo.
  /// * [estilo] Es opcional; por defecto muestra texto blanco en negrita tamaño 14.
  Coordenada({
    required String texto,
    required Vector2 posicion,
    TextStyle estilo = const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  }) : super(
         text: texto,
         position: posicion,
         anchor: Anchor.center, // Centrar el texto para una mejor alineación
         textRenderer: TextPaint(style: estilo),
       );

  /// No es necesario el método render si se extiende de TextComponent.
  /// El TextComponent se encarga de renderizar el texto.
}

extension CanvasExtension on Canvas {
  void drawText(String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(this, position);
  }
}
