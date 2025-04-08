// coordenada.dart
//
// Componente visual que representa una coordenada (letra o número)
// para los bordes del tablero 12x12 en el juego.

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'extension_canvas.dart';

/// ---------------------------------------------------------------------------
/// `Coordenada` es un componente visual personalizado que representa una letra
/// (A–L) o un número (1–12) en los bordes del tablero. Se utiliza en el diseño
/// del juego tipo batalla naval para identificar filas y columnas.
///
/// Este componente hace uso de una extensión (`drawText`) sobre el lienzo para
/// renderizar el texto de manera sencilla.
/// ---------------------------------------------------------------------------
class Coordenada extends Component {
  /// Posición en pantalla donde se desea renderizar el texto.
  final Vector2 posicion;

  /// Texto que se mostrará como coordenada (ejemplo: "A", "1", "L", "12").
  final String texto;

  /// Estilo del texto, como color, tamaño de fuente y peso.
  final TextStyle estilo;

  /// Constructor de `Coordenada`.
  ///
  /// * [posicion] Define la ubicación en el lienzo.
  /// * [texto] Es el contenido que se desea mostrar.
  /// * [estilo] Es opcional; por defecto muestra texto blanco en negrita tamaño 14.
  Coordenada({
    required this.posicion,
    required this.texto,
    this.estilo = const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
  });

  /// Método de renderizado del componente.
  ///
  /// Utiliza la extensión personalizada `drawText` para pintar el texto sobre el lienzo.
  @override
  void render(Canvas canvas) {
    canvas.drawText(texto, posicion.toOffset(), estilo);
  }
}
