/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: [Tu Nombre]
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco dentro del tablero de batalla.
/// Utiliza una imagen tipo sprite sheet con múltiples rotaciones horizontales.
/// Soporta arrastre para colocación y toque para cambiar la orientación.
///
/// Cada barco está compuesto por:
/// - Un identificador único.
/// - Una imagen visual que representa el sprite.
/// - Lógica de rotación mediante cambio de sección de sprite.
/// - Validación de colisión y posicionamiento dentro del tablero.
/// ------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'image_component.dart';
import 'setup_game.dart';
import 'tablero.dart';

/// ------------------------------------------------------------------------
/// COMPONENTE: Barco
///
/// Representa un barco que puede ser arrastrado y rotado dentro del tablero.
/// Permite validar la colocación del barco en el tablero y manejar las
/// interacciones visuales y de colisión.
/// ------------------------------------------------------------------------
class Barco extends PositionComponent with DragCallbacks, TapCallbacks, HasGameRef<SetupGame> {
  /// Identificador único del barco
  late final String id;

  /// Imagen del sprite visual (con múltiples rotaciones)
  late final ImagenComponente barcoVisual;

  /// Longitud del barco en celdas
  final int longitud;

  /// URL de la imagen completa del sprite
  final String imageUrl;

  /// Tamaño de cada sección del sprite (una por rotación)
  final Vector2 seccionSprite;

  /// Orientación del barco (true = vertical, false = horizontal)
  bool esVertical = false;

  /// Índice de rotación actual (0 a 3)
  int indiceRotacion = 0;

  /// Bandera para saber si se está arrastrando
  bool estaSiendoArrastrado = false;

  /// Posición anterior antes de mover el barco
  late Vector2 _posicionAnterior;

  /// Prioridad de renderizado
  final int prioridadNormal = 0;
  final int prioridadArrastrando = 1;

  /// Callbacks
  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;
  void Function(Barco barco)? onBarcoColocadoEnTablero;
  bool Function(Barco barco)? validarColocacion;

  /// Constructor del barco
  Barco({
    required this.longitud,
    required this.imageUrl,
    required this.seccionSprite,
    Vector2? posicionInicial,
    double escala = 1.0,
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
    this.id = id ?? UniqueKey().toString(); // Asigna un id único

    // Inicializa el componente de la imagen visual
    barcoVisual = ImagenComponente(
      imagePath: imageUrl,
      imageSize: size.clone(),
      srcSize: seccionSprite,
      srcPosition: Vector2.zero(), // Empieza en la rotación 0
    );

    add(barcoVisual); // Añadir la imagen al componente
  }

  /// Cambia la orientación del barco (cambia el sprite mostrado)
  void rotar() {
    final oldRotation = indiceRotacion;
    final oldSize = size.clone();
    final oldPosition = position.clone();

    indiceRotacion = (indiceRotacion + 1) % 4;
    esVertical = indiceRotacion % 2 == 1;

    // Ajustar tamaño del barco según orientación
    size.setValues(50.0 * (esVertical ? 1 : longitud), 50.0 * (esVertical ? longitud : 1));
    barcoVisual.size.setFrom(size);

    // Cambiar la sección del sprite visible
    barcoVisual.srcPosition = Vector2(seccionSprite.x * indiceRotacion, 0);

    // Validar si la nueva orientación es válida
    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (!esValida) {
      // Revertir si no se puede colocar en nueva orientación
      indiceRotacion = oldRotation;
      size.setFrom(oldSize);
      position.setFrom(oldPosition);
      barcoVisual.size.setFrom(oldSize);
      barcoVisual.srcPosition = Vector2(seccionSprite.x * oldRotation, 0);
      esVertical = oldRotation % 2 == 1;
    } else {
      // Reajustar a la grilla
      position = gameRef.tablero.gridToWorld(gridPosition);
    }
  }

  /// Evento de toque para cambiar la orientación del barco
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    rotar();
  }

  /// Evento de arrastre al comenzar
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = prioridadArrastrando;
    _posicionAnterior = position.clone();
  }

  /// Evento de arrastre mientras se mueve el barco
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  /// Evento de arrastre al finalizar el movimiento
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
      position = gameRef.tablero.gridToWorld(gridPosition);
      onBarcoColocadoEnTablero?.call(this);
    } else {
      position = _posicionAnterior;
    }

    _resetearVisualizacionTablero();
  }

  /// Verifica si colisiona con otro barco
  bool colisionaCon(Barco otroBarco) {
    return toRect().overlaps(otroBarco.toRect());
  }

  /// Celdas que ocupa este barco dentro del tablero
  List<Vector2> getCeldasOcupadas(double tamanoCelda) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i * tamanoCelda;
      final dy = esVertical ? i * tamanoCelda : 0;
      celdas.add(Vector2((position.x + dx) / tamanoCelda, (position.y + dy) / tamanoCelda));
    }
    return celdas;
  }

  /// Muestra visualmente las celdas que el barco está tocando
  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tablero.worldToGrid(position);
    gameRef.tablero.resaltarPosicion(gridPosition, longitud, esVertical);
  }

  /// Elimina resaltado visual del tablero
  void _resetearVisualizacionTablero() {
    gameRef.tablero.resetearResaltado();
  }

  /// Comparación de barcos por ID
  @override
  bool operator ==(Object other) => other is Barco && id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Rectángulo usado para detección de colisiones
  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }
}
