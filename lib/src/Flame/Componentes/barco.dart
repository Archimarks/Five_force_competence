/// ------------------------------------------------------------------------
/// Clase Barco
/// ------------------------------------------------------------------------
/// Representa un barco dentro del tablero del juego. Este componente gestiona:
/// - Arrastre y colocación por el usuario.
/// - Rotación entre orientación horizontal y vertical.
/// - Detección de colisiones con otros barcos.
/// - Presentación visual mediante sprites según su orientación y tamaño.
/// - Validación de la posición para asegurar su correcta colocación en el tablero.
/// ------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Barco extends PositionComponent with DragCallbacks, HasGameRef, TapCallbacks {
  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Sprite del barco en orientación horizontal.
  final Sprite spriteHorizontal;

  /// Sprite del barco en orientación vertical.
  final Sprite spriteVertical;

  /// Indica si el barco está en orientación vertical. Por defecto es horizontal.
  bool esVertical = false;

  /// Determina si el barco está actualmente siendo arrastrado.
  bool estaSiendoArrastrado = false;

  /// Callback que se invoca cuando la posición del barco cambia.
  /// Útil para notificar al tablero sobre la nueva posición.
  final void Function(Vector2 nuevaPosicion)? onPosicionCambiada;

  /// Callback que se invoca cuando el barco se coloca en el tablero.
  final void Function(Barco barco)? onBarcoColocado;

  /// Constructor principal del [Barco].
  ///
  /// Requiere la [longitud] del barco y sus [spriteHorizontal] y [spriteVertical].
  /// Opcionalmente, se puede especificar una [posicionInicial] y callbacks para
  /// [onPosicionCambiada] y [onBarcoColocado].
  Barco({
    required this.longitud,
    required this.spriteHorizontal,
    required this.spriteVertical,
    Vector2? posicionInicial,
    this.onPosicionCambiada,
    this.onBarcoColocado,
  }) : super(
         position: posicionInicial ?? Vector2.zero(),
         size: Vector2(50.0 * longitud, 50.0), // Tamaño base horizontal
         anchor: Anchor.topLeft,
       );

  /// Cambia la orientación del barco entre horizontal y vertical, actualizando su tamaño.
  void rotar() {
    esVertical = !esVertical;
    size.setValues(size.y, size.x);
  }

  /// Renderiza el sprite del barco según su orientación actual.
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final sprite = esVertical ? spriteVertical : spriteHorizontal;
    sprite.render(canvas, size: size);
  }

  /// Invocado cuando el usuario comienza a arrastrar el barco.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
  }

  /// Actualiza la posición del barco mientras el usuario lo arrastra.
  /// Notifica a través del callback [onPosicionCambiada] si está definido.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta; // Corrección: usar event.localDelta
    onPosicionCambiada?.call(position);
  }

  /// Invocado cuando el usuario deja de arrastrar el barco.
  /// Llama al callback [onBarcoColocado] si está definido.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    onBarcoColocado?.call(this);
    // Aquí se podría implementar la lógica para anclar a la celda más cercana.
  }

  /// Rota el barco cuando el usuario toca el componente.
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  /// Verifica si este barco colisiona con otro [Barco].
  ///
  /// Retorna `true` si los rectángulos de ambos barcos se superponen.
  bool colisionaCon(Barco otroBarco) {
    return toRect().overlaps(otroBarco.toRect());
  }

  /// Devuelve el rectángulo que ocupa este barco en la pantalla.
  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }
}
