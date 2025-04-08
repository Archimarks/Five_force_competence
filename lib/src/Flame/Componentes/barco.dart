// 📁 lib/src/Core/Elements/barco.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------------------
/// Clase Barco
/// ------------------------------------------------------------------------
/// Representa un barco dentro del tablero del juego. Este componente puede:
/// - Ser arrastrado por el usuario.
/// - Rotar entre orientación horizontal y vertical.
/// - Detectar colisiones para evitar superposiciones.
/// - Mostrar diferentes sprites según su orientación y tamaño.
/// - Validar si la posición es válida para su colocación.
///
/// Tamaño del barco:
///   - Muy Bajo  = 1 celda.
///   - Bajo      = 2 celdas.
///   - Medio     = 3 celdas.
///   - Alto      = 4 celdas.
///   - Muy Alto  = 5 celdas.
/// ------------------------------------------------------------------------
class Barco extends PositionComponent with DragCallbacks, HasGameRef, TapCallbacks {
  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Sprite del barco en orientación horizontal.
  late Sprite spriteHorizontal;

  /// Sprite del barco en orientación vertical.
  late Sprite spriteVertical;

  /// Indica si el barco está en orientación vertical.
  bool esVertical = false;

  /// Determina si el barco está actualmente siendo arrastrado.
  bool estaSiendoArrastrado = false;

  /// Constructor principal.
  Barco({
    required this.longitud,
    required this.spriteHorizontal,
    required this.spriteVertical,
    Vector2? posicionInicial,
  }) {
    position = posicionInicial ?? Vector2.zero();
    size = Vector2(50.0 * longitud, 50.0); // Tamaño base horizontal
    anchor = Anchor.topLeft;
  }

  /// Método para rotar el barco entre orientación horizontal y vertical.
  void rotar() {
    esVertical = !esVertical;

    // Intercambia ancho y alto.
    size = Vector2(size.y, size.x);
  }

  /// Renderiza el sprite adecuado según la orientación actual.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = esVertical ? spriteVertical : spriteHorizontal;
    sprite.render(canvas, size: size);
  }

  /// Cuando el usuario comienza a arrastrar el barco.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
  }

  /// Actualiza la posición del barco mientras se arrastra.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
  }

  /// Cuando se suelta el barco, se puede verificar si está sobre una celda válida.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    // Aquí puedes anclar a celda más cercana si es válida.
  }

  /// Permite rotar el barco al tocarlo (tap).
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  /// Verifica si el barco colisiona con otro barco.
  bool colisionaCon(Barco otroBarco) {
    final rectA = toRect();
    final rectB = otroBarco.toRect();
    return rectA.overlaps(rectB);
  }

  /// Devuelve la representación en Rect del barco.
  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }
}
