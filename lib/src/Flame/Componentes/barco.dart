/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: Geraldine Perilla Valderrama
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco dentro del tablero de batalla.
/// Utiliza imágenes separadas por dirección en lugar de un sprite sheet.
/// Soporta arrastre para colocación, toque para rotación, y validación
/// para evitar superposiciones y salidas del tablero.
/// ------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'direccion.dart';
import 'setup_game.dart';
import 'sprites_barco.dart';
import 'tablero.dart';

class Barco extends PositionComponent with DragCallbacks, TapCallbacks, HasGameRef<SetupGame> {
  late final String id;
  final int longitud;
  late final SpritesBarco barcoVisual;
  bool esVertical = true;
  int indiceRotacion = 0;
  bool estaSiendoArrastrado = false;
  late Vector2 _posicionAnterior;

  /// Celdas actualmente ocupadas por este barco
  List<Vector2> _celdasOcupadas = [];

  final int prioridadNormal = 0;
  final int prioridadArrastrando = 1;

  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;
  void Function(Barco barco)? onBarcoColocadoEnTablero;
  bool Function(Barco barco)? validarColocacion;

  Barco({
    required this.longitud,
    required Map<String, String> rutasSprites,
    Vector2? posicionInicial,
    required double escala,
    this.onPosicionCambiada,
    this.onBarcoColocadoEnTablero,
    this.validarColocacion,
    String? id,
  }) : super(
         position: posicionInicial ?? Vector2.zero(),
         size: Vector2(50.0 * longitud * escala, 50.0 * escala),
         scale: Vector2.all(escala),
         anchor: Anchor.topLeft,
       ) {
    this.id = id ?? UniqueKey().toString();

    barcoVisual = SpritesBarco(
      rutasSprites: rutasSprites,
      direccionActual: Direccion.arriba,
      tamano: size.clone(),
    );

    add(barcoVisual);
  }

  void rotar() {
    final oldRotation = indiceRotacion;
    final oldSize = size.clone();
    final oldPosition = position.clone();
    final celdasAntes = _celdasOcupadas.toList();

    indiceRotacion = (indiceRotacion + 1) % 4;
    esVertical = (indiceRotacion == 0 || indiceRotacion == 2);

    size.setValues(50.0 * (esVertical ? 1 : longitud), 50.0 * (esVertical ? longitud : 1));
    barcoVisual.size.setFrom(size);
    barcoVisual.cambiarDireccion(_obtenerDireccionDesdeIndice(indiceRotacion));

    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (!esValida) {
      indiceRotacion = oldRotation;
      esVertical = (oldRotation == 0 || oldRotation == 2);
      size.setFrom(oldSize);
      position.setFrom(oldPosition);
      barcoVisual.size.setFrom(oldSize);
      barcoVisual.cambiarDireccion(_obtenerDireccionDesdeIndice(oldRotation));
    } else {
      gameRef.tablero.liberarCeldas(celdasAntes);
      position = _calcularPosicionCentrada(gridPosition);
      _celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
      gameRef.tablero.ocuparCeldas(_celdasOcupadas);
    }
  }

  Direccion _obtenerDireccionDesdeIndice(int indice) {
    switch (indice % 4) {
      case 0:
        return Direccion.arriba;
      case 1:
        return Direccion.derecha;
      case 2:
        return Direccion.abajo;
      case 3:
      default:
        return Direccion.izquierda;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = prioridadArrastrando;
    _posicionAnterior = position.clone();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    priority = prioridadNormal;

    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (esValida) {
      gameRef.tablero.liberarCeldas(_celdasOcupadas);
      position = _calcularPosicionCentrada(gridPosition);
      _celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
      gameRef.tablero.ocuparCeldas(_celdasOcupadas);
      onBarcoColocadoEnTablero?.call(this);
    } else {
      position = _posicionAnterior;
    }

    _resetearVisualizacionTablero();
  }

  bool colisionaCon(Barco otroBarco) => toRect().overlaps(otroBarco.toRect());

  List<Vector2> getCeldasOcupadas(double tamanoCelda) => _celdasOcupadas;

  List<Vector2> _calcularCeldasOcupadas(Vector2 gridPosition) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i.toDouble();
      final dy = esVertical ? i.toDouble() : 0;
      celdas.add(Vector2(gridPosition.x + dx, gridPosition.y + dy));
    }
    return celdas;
  }

  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tablero.worldToGrid(position);
    gameRef.tablero.resaltarPosicion(gridPosition, longitud, esVertical, _celdasOcupadas);
  }

  void _resetearVisualizacionTablero() {
    gameRef.tablero.resetearResaltado();
  }

  @override
  bool operator ==(Object other) => other is Barco && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  Rect toRect() => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  Vector2 _calcularPosicionCentrada(Vector2 gridPosition) {
    final double tamanoCelda = gameRef.tablero.tamanioCelda;
    final Vector2 base = gameRef.tablero.gridToWorld(gridPosition);
    final double offsetX = esVertical ? 0.0 : ((longitud - 1) * tamanoCelda / 2);
    final double offsetY = esVertical ? ((longitud - 1) * tamanoCelda / 2) : 0.0;
    return base - Vector2(offsetX, offsetY);
  }
}
