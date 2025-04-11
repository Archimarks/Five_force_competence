/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: Geraldine Perilla Valderrama
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco dentro del tablero de batalla.
/// Utiliza sprites por dirección mediante la clase `SpritesBarco`.
/// Soporta interacción: arrastre para colocación, toque para rotación,
/// y validación para evitar superposiciones y salidas del tablero.
/// ------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'direccion.dart';
import 'setup_game.dart';
import 'sprites_barco.dart';
import 'tablero.dart';

/// Componente visual e interactivo que representa un barco.
/// Puede rotarse, arrastrarse y colocarse dentro del tablero.
class Barco extends PositionComponent with DragCallbacks, TapCallbacks, HasGameRef<SetupGame> {
  /// Identificador único del barco.
  late final String id;

  /// Cantidad de celdas que ocupa el barco.
  final int longitud;

  /// Componente visual que maneja los sprites según dirección.
  late final SpritesBarco barcoVisual;

  /// Define si el barco está en orientación vertical.
  bool esVertical = true;

  /// Índice actual de rotación (0 a 3).
  int indiceRotacion = 0;

  /// Indica si el barco está siendo arrastrado actualmente.
  bool estaSiendoArrastrado = false;

  /// Posición anterior antes del arrastre (para revertir si invalida).
  late Vector2 _posicionAnterior;

  /// Lista de celdas del tablero que el barco está ocupando.
  List<Vector2> _celdasOcupadas = [];

  /// Prioridades visuales del componente para orden de renderizado.
  final int prioridadNormal = 0;
  final int prioridadArrastrando = 1;

  /// Callback al cambiar la posición.
  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;

  /// Callback cuando el barco se coloca exitosamente en el tablero.
  void Function(Barco barco)? onBarcoColocadoEnTablero;

  /// Función para validar si la colocación del barco es válida.
  bool Function(Barco barco)? validarColocacion;

  /// Constructor del barco. Recibe longitud, rutas de sprites y escala.
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

    // Inicializa el componente visual con sprites por dirección.
    barcoVisual = SpritesBarco(
      rutasSprites: rutasSprites,
      direccionActual: Direccion.arriba,
      tamano: size.clone(),
    );

    add(barcoVisual);
  }

  /// Rota el barco 90° en sentido horario. Revierta si la posición resultante es inválida.
  void rotar() {
    final oldRotation = indiceRotacion;
    final oldSize = size.clone();
    final oldPosition = position.clone();
    final celdasAntes = _celdasOcupadas.toList();

    indiceRotacion = (indiceRotacion + 1) % 4;
    esVertical = (indiceRotacion == 0 || indiceRotacion == 2);

    // Cambia tamaño y sprite del barco según dirección.
    size.setValues(50.0 * (esVertical ? 1 : longitud), 50.0 * (esVertical ? longitud : 1));
    barcoVisual.size.setFrom(size);
    barcoVisual.cambiarDireccion(_obtenerDireccionDesdeIndice(indiceRotacion));

    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (!esValida) {
      // Revertir rotación si la nueva posición no es válida.
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

  /// Retorna la dirección visual correspondiente a un índice de rotación.
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

  /// Maneja el evento de toque: rota el barco.
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  /// Inicia el arrastre del barco.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = prioridadArrastrando;
    _posicionAnterior = position.clone();
  }

  /// Actualiza la posición durante el arrastre.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  /// Finaliza el arrastre, valida posición y ajusta.
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
      // Revertir si la nueva posición no es válida
      position = _posicionAnterior;
    }

    _resetearVisualizacionTablero();
  }

  /// Retorna `true` si hay colisión visual con otro barco.
  bool colisionaCon(Barco otroBarco) => toRect().overlaps(otroBarco.toRect());

  /// Devuelve una copia de las celdas que este barco ocupa.
  List<Vector2> getCeldasOcupadas() => List.unmodifiable(_celdasOcupadas);

  /// Calcula las celdas ocupadas por el barco desde una posición en la grilla.
  List<Vector2> _calcularCeldasOcupadas(Vector2 gridPosition) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i.toDouble();
      final dy = esVertical ? i.toDouble() : 0;
      celdas.add(Vector2(gridPosition.x + dx, gridPosition.y + dy));
    }
    return celdas;
  }

  /// Resalta visualmente en el tablero las celdas bajo el barco durante el arrastre.
  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tablero.worldToGrid(position);
    gameRef.tablero.resaltarPosicion(gridPosition, longitud, esVertical, _celdasOcupadas);
  }

  /// Limpia los resaltados de celda del tablero.
  void _resetearVisualizacionTablero() {
    gameRef.tablero.resetearResaltado();
  }

  @override
  bool operator ==(Object other) => other is Barco && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Rectángulo que representa el área ocupada por el barco.
  @override
  Rect toRect() => Rect.fromLTWH(position.x, position.y, size.x, size.y);

  /// Calcula la posición del barco centrada en sus celdas objetivo.
  Vector2 _calcularPosicionCentrada(Vector2 gridPosition) {
    final double tamanoCelda = gameRef.tablero.tamanioCelda;
    final Vector2 base = gameRef.tablero.gridToWorld(gridPosition);
    final double offsetX = esVertical ? 0.0 : ((longitud - 1) * tamanoCelda / 2);
    final double offsetY = esVertical ? ((longitud - 1) * tamanoCelda / 2) : 0.0;
    return base - Vector2(offsetX, offsetY);
  }
}
