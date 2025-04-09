import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'barco.dart';

class BarcoAlmacen extends PositionComponent with DragCallbacks {
  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Sprite del barco en orientación horizontal.
  final Sprite spriteHorizontal;

  /// Sprite del barco en orientación vertical.
  final Sprite spriteVertical;

  /// Indica si el barco está en orientación vertical. Por defecto es horizontal.
  bool esVertical = false;

  /// El [Barco] real que se creará y moverá al tablero al soltar este componente.
  Barco? barcoEnTablero;

  /// Callback que se invoca cuando se suelta el barco desde el almacén.
  final void Function(Barco barco)? onBarcoArrastradoAlTablero;

  BarcoAlmacen({
    required this.longitud,
    required this.spriteHorizontal,
    required this.spriteVertical,
    Vector2? posicionInicial,
    this.onBarcoArrastradoAlTablero,
  }) : super(
         position: posicionInicial ?? Vector2.zero(),
         size: Vector2(50.0 * longitud, 50.0), // Tamaño base horizontal
         anchor: Anchor.topLeft,
       );

  /// Renderiza el sprite del barco según su orientación actual.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = esVertical ? spriteVertical : spriteHorizontal;
    sprite.render(canvas, size: size);
  }

  /// Invocado cuando el usuario comienza a arrastrar el barco del almacén.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // Crear una instancia del Barco real que se moverá al tablero.
    barcoEnTablero = Barco(
      longitud: longitud,
      spriteHorizontal: spriteHorizontal,
      spriteVertical: spriteVertical,
      posicionInicial: position.clone(), // Inicializar en la posición del almacén
    )..addToParent(parent!); // Añadirlo temporalmente al mismo padre del almacén
  }

  /// Actualiza la posición del Barco real mientras se arrastra el componente del almacén.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    barcoEnTablero?.position.add(event.localDelta);
  }

  /// Invocado cuando se suelta el barco del almacén.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (barcoEnTablero != null) {
      onBarcoArrastradoAlTablero?.call(barcoEnTablero!);
      // El Barco real ahora está en el tablero, podemos remover el "fantasma" del almacén.
      removeFromParent();
    }
  }
}
