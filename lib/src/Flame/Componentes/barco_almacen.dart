/// ---------------------------------------------------------------------------
/// Componente visual interactivo que representa un barco disponible en el
/// almacén para ser arrastrado al tablero.
///
/// Cada instancia representa un tipo de barco con una longitud específica.
/// Al arrastrarse, crea una instancia real (`Barco`) que se coloca en el tablero.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'barco.dart';

class BarcoAlmacen extends PositionComponent with DragCallbacks {
  /// Identificador único del barco.
  final String id;

  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Sprite del barco en orientación horizontal.
  final Sprite spriteHorizontal;

  /// Sprite del barco en orientación vertical.
  final Sprite spriteVertical;

  /// Escala visual del sprite.
  final double escala;

  /// Orientación actual del barco (por defecto, horizontal).
  bool esVertical = false;

  /// Instancia del barco real creada durante el arrastre.
  Barco? barcoEnTablero;

  /// Callback que se ejecuta cuando el barco se suelta sobre el tablero.
  final void Function(Barco barco)? onBarcoArrastradoAlTablero;

  /// Constructor.
  BarcoAlmacen({
    required this.id,
    required this.longitud,
    required this.spriteHorizontal,
    required this.spriteVertical,
    this.escala = 1.0,
    this.onBarcoArrastradoAlTablero,
    Vector2? posicionInicial,
  }) : super(
         position: posicionInicial ?? Vector2.zero(),
         size: Vector2(20.0 * longitud, 20.0),
         anchor: Anchor.topLeft,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _ajustarTamanio();
  }

  /// Ajusta el tamaño del componente según la orientación y la escala.
  void _ajustarTamanio() {
    final sprite = esVertical ? spriteVertical : spriteHorizontal;
    size = sprite.srcSize * escala;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = esVertical ? spriteVertical : spriteHorizontal;
    sprite.render(canvas, size: size);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    barcoEnTablero =
        Barco(
            longitud: longitud,
            spriteHorizontal: spriteHorizontal,
            spriteVertical: spriteVertical,
            posicionInicial: position.clone(),
          )
          ..esVertical = esVertical
          ..addToParent(parent!);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    barcoEnTablero?.position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (barcoEnTablero != null) {
      onBarcoArrastradoAlTablero?.call(barcoEnTablero!);
      removeFromParent(); // Este barco del almacén ya no se usa.
    }
  }

  /// Método estático para generar una lista de barcos del almacén.
  /// Ideal para usarse desde `SetupGame`.
  static List<BarcoAlmacen> crearBarcosDisponibles({
    required List<Sprite> spritesHorizontales,
    required List<Sprite> spritesVerticales,
    required void Function(Barco barco) onArrastre,
    Vector2? posicionInicial,
    double separacion = 10.0,
    double escala = 1.0,
  }) {
    assert(spritesHorizontales.length == 5 && spritesVerticales.length == 5);

    final inicio = posicionInicial ?? Vector2(10, 10);
    final barcos = <BarcoAlmacen>[];

    for (int i = 0; i < 5; i++) {
      final longitud = i + 1;
      final posicionY = inicio.y + i * (20.0 * escala + separacion);

      barcos.add(
        BarcoAlmacen(
          id: 'barco_$i',
          longitud: longitud,
          spriteHorizontal: spritesHorizontales[i],
          spriteVertical: spritesVerticales[i],
          posicionInicial: Vector2(inicio.x, posicionY),
          escala: escala,
          onBarcoArrastradoAlTablero: onArrastre,
        ),
      );
    }

    return barcos;
  }
}
