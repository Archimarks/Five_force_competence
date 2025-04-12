/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: Geraldine Perilla Valderrama
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco dentro del tablero de batalla.
/// Permite interacción mediante gestos: arrastrar para posicionar,
/// tocar para rotar, y valida las posiciones para evitar colisiones
/// o ubicaciones inválidas.
///
/// Cada barco está compuesto visualmente por un conjunto de imágenes
/// (una por dirección) y se adapta automáticamente al grid del tablero.
/// ------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'direccion.dart';
import 'setup_game.dart';
import 'sprites_barco.dart';
import 'tablero.dart';

/// Componente que representa un barco arrastrable y rotable sobre un tablero.
///
/// Maneja su visualización a través de sprites por dirección,
/// validación de ubicación, y gestos de usuario.
class Barco extends PositionComponent with DragCallbacks, TapCallbacks, HasGameRef<SetupGame> {
  // ------------------------------------------------------------------------
  // PROPIEDADES - ESTADO Y CONFIGURACIÓN
  // ------------------------------------------------------------------------

  /// Identificador único del barco.
  late final String id;

  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Componente visual del barco que administra sprites según dirección.
  late final SpritesBarco barcoVisual;

  /// Indica si el barco está orientado verticalmente.
  bool esVertical = true;

  /// Índice de rotación actual (0: arriba, 1: derecha, 2: abajo, 3: izquierda).
  int indiceRotacion = 0;

  /// Indica si el barco está siendo arrastrado en este momento.
  bool estaSiendoArrastrado = false;

  /// Guarda la posición previa al arrastre para revertir si es inválido.
  late Vector2 _posicionAnterior;

  /// Lista de coordenadas (en grid) ocupadas por el barco en el tablero.
  List<Vector2> _celdasOcupadas = [];

  /// Prioridad normal para el orden de renderizado.
  final int prioridadNormal = 0;

  /// Prioridad cuando el barco está siendo arrastrado.
  final int prioridadArrastrando = 1;

  /// Callback ejecutado cuando el barco cambia su posición.
  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;

  /// Callback ejecutado cuando el barco es colocado en una posición válida.
  void Function(Barco barco)? onBarcoColocadoEnTablero;

  /// Función personalizada para validar si una posición es válida.
  bool Function(Barco barco)? validarColocacion;

  // ------------------------------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------------------------------

  /// Constructor del componente Barco.
  ///
  /// Requiere longitud, rutas de sprites y escala. Puede incluir una posición inicial
  /// y funciones de validación o de eventos personalizados.
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

  // ------------------------------------------------------------------------
  // GESTOS DE USUARIO
  // ------------------------------------------------------------------------

  /// Evento de tap: al tocar el barco, se rota.
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  /// Evento de inicio de arrastre: cambia prioridad y guarda la posición inicial.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = prioridadArrastrando;
    _posicionAnterior = position.clone();
  }

  /// Evento durante el arrastre: mueve el barco y actualiza visualización del tablero.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  /// Evento al soltar el barco: valida ubicación y lo coloca o revierte.
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
      // Revertir a posición anterior
      position = _posicionAnterior;
    }

    _resetearVisualizacionTablero();
  }

  // ------------------------------------------------------------------------
  // FUNCIONALIDAD DEL BARCO
  // ------------------------------------------------------------------------

  /// Gira el barco 90° en sentido horario.
  ///
  /// Valida la rotación y revierte si no es posible.
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

  /// Determina si este barco colisiona con otro (a nivel de rectángulo).
  bool colisionaCon(Barco otroBarco) => toRect().overlaps(otroBarco.toRect());

  /// Devuelve la lista de celdas ocupadas actualmente.
  List<Vector2> getCeldasOcupadas(double tamanoCelda) => _celdasOcupadas;

  // ------------------------------------------------------------------------
  // MÉTODOS PRIVADOS
  // ------------------------------------------------------------------------

  /// Obtiene la dirección visual en base al índice de rotación.
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

  /// Calcula las celdas que ocupará el barco desde una posición en grid.
  List<Vector2> _calcularCeldasOcupadas(Vector2 gridPosition) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i.toDouble();
      final dy = esVertical ? i.toDouble() : 0;
      celdas.add(Vector2(gridPosition.x + dx, gridPosition.y + dy));
    }
    return celdas;
  }

  /// Calcula la posición en el mundo para centrar el barco en una celda del grid.
  Vector2 _calcularPosicionCentrada(Vector2 gridPosition) {
    final tamanoCelda = gameRef.tablero.tamanioCelda;
    final base = gameRef.tablero.gridToWorld(gridPosition);
    final offsetX = esVertical ? 0.0 : ((longitud - 1) * tamanoCelda / 2);
    final offsetY = esVertical ? ((longitud - 1) * tamanoCelda / 2) : 0.0;
    return base - Vector2(offsetX, offsetY);
  }

  /// Resalta en el tablero las celdas donde se movería el barco.
  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tablero.worldToGrid(position);
    gameRef.tablero.resaltarPosicion(gridPosition, longitud, esVertical, _celdasOcupadas);
  }

  /// Elimina cualquier resaltado en el tablero.
  void _resetearVisualizacionTablero() {
    gameRef.tablero.resetearResaltado();
  }

  // ------------------------------------------------------------------------
  // OPERADORES Y UTILIDADES
  // ------------------------------------------------------------------------

  @override
  bool operator ==(Object other) => other is Barco && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Convierte el componente en un rectángulo, útil para colisiones.
  @override
  Rect toRect() => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
