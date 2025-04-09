/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: Marcos Alejandro Collazos Marmolejo y Geraldine Perilla Valderrama
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco dentro del tablero de batalla.
/// Gestiona su renderización, interacción mediante arrastre, rotación y
/// validación de colisiones.
/// ------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Barco extends PositionComponent with DragCallbacks, HasGameRef, TapCallbacks {
  final int longitud;
  final Sprite spriteHorizontal;
  final Sprite spriteVertical;

  bool esVertical = false;
  bool estaSiendoArrastrado = false;
  final int prioridadNormal = 0;
  final int prioridadArrastrando = 1;

  final void Function(Vector2 nuevaPosicion)? onPosicionCambiada;
  final void Function(Barco barco)? onBarcoColocado;
  final bool Function(Barco barco)? validarColocacion;

  /// Posición anterior para restaurar si no se puede colocar.
  late Vector2 _posicionAnterior;

  Barco({
    required this.longitud,
    required this.spriteHorizontal,
    required this.spriteVertical,
    Vector2? posicionInicial,
    this.onPosicionCambiada,
    this.onBarcoColocado,
    this.validarColocacion,
  }) : super(
         position: posicionInicial ?? Vector2.zero(),
         size: Vector2(20.0 * longitud, 20.0),
         anchor: Anchor.topLeft,
       );

  /// Rotación
  void rotar() {
    esVertical = !esVertical;
    size.setValues(size.y, size.x);
    angle += 1.5708; // 90 grados en radianes
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
    estaSiendoArrastrado = true;
    priority = prioridadArrastrando;
    _posicionAnterior = position.clone(); // Guardamos por si toca volver
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    priority = prioridadNormal;

    // Validación: si existe función y no es válida, volver atrás
    if (validarColocacion != null && !validarColocacion!(this)) {
      position = _posicionAnterior;
    } else {
      onBarcoColocado?.call(this);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    final oldSize = size.clone();
    final oldPosition = position.clone();

    rotar();

    // Revalidar tras rotación
    if (validarColocacion != null && !validarColocacion!(this)) {
      // Revertir si no se puede colocar
      size.setFrom(oldSize);
      position.setFrom(oldPosition);
      esVertical = !esVertical;
      angle -= 1.5708;
    }
  }

  bool colisionaCon(Barco otroBarco) {
    return toRect().overlaps(otroBarco.toRect());
  }

  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }

  List<Vector2> getCeldasOcupadas(double tamanoCelda) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i * tamanoCelda;
      final dy = esVertical ? i * tamanoCelda : 0;
      celdas.add(Vector2((position.x + dx) / tamanoCelda, (position.y + dy) / tamanoCelda));
    }
    return celdas;
  }
}
