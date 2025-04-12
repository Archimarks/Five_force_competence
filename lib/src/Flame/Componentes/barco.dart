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

  /// Índice de rotación actual (0: arriba, 1: derecha, 2: abajo, 3: izquierda).
  int indiceRotacion = 0;

  /// Indica si el barco está siendo arrastrado actualmente.
  bool estaSiendoArrastrado = false;

  /// Guarda la posición previa al arrastre para revertir si es inválido.
  late Vector2 _posicionAnterior;

  /// Lista de coordenadas (en grid) ocupadas por el barco en el tablero.
  List<Vector2> _celdasOcupadas = [];

  /// Callback ejecutado cuando el barco cambia su posición (durante arrastre).
  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;

  /// Callback ejecutado cuando el barco es colocado correctamente.
  void Function(Barco barco)? onBarcoColocadoEnTablero;

  /// Función personalizada para validar si una posición es válida.
  bool Function(Barco barco)? validarColocacion;

  /// Dirección vertical según el índice actual.
  bool get esVertical => (indiceRotacion % 2 == 0);

  // Prioridades visuales
  static const int _prioridadNormal = 0;
  static const int _prioridadArrastrando = 1;

  // ------------------------------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------------------------------

  /// Constructor del componente Barco.
  ///
  /// Requiere longitud, rutas de sprites y escala. Puede incluir una posición inicial
  /// y funciones de validación o eventos personalizados.
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
    _rotar();
  }

  /// Evento de inicio de arrastre: eleva prioridad y guarda la posición actual.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = _prioridadArrastrando;
    _posicionAnterior = position.clone();
  }

  /// Evento durante el arrastre: actualiza la posición y visualización del tablero.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  /// Evento al finalizar el arrastre: valida y coloca o revierte.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    priority = _prioridadNormal;

    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (esValida) {
      _actualizarPosicionEnTablero(gridPosition);
      onBarcoColocadoEnTablero?.call(this);
    } else {
      position = _posicionAnterior;
    }

    _resetearVisualizacionTablero();
  }

  // ------------------------------------------------------------------------
  // FUNCIONALIDAD DEL BARCO
  // ------------------------------------------------------------------------

  /// Gira el barco 90° en sentido horario.
  ///
  /// Si la nueva posición no es válida, revierte la rotación.
  void _rotar() {
    final rotacionAnterior = indiceRotacion;
    final sizeAnterior = size.clone();
    final posicionAnterior = position.clone();
    final celdasPrevias = _celdasOcupadas.toList();

    indiceRotacion = (indiceRotacion + 1) % 4;
    _actualizarTamanioYVisual();

    final gridPosition = gameRef.tablero.worldToGrid(position);
    final esValida =
        validarColocacion?.call(this) ??
        gameRef.tablero.esPosicionValida(gridPosition, longitud, esVertical);

    if (esValida) {
      gameRef.tablero.liberarCeldas(celdasPrevias);
      _actualizarPosicionEnTablero(gridPosition);
    } else {
      // Revertir cambios
      indiceRotacion = rotacionAnterior;
      size.setFrom(sizeAnterior);
      position.setFrom(posicionAnterior);
      barcoVisual.size.setFrom(sizeAnterior);
      barcoVisual.cambiarDireccion(_obtenerDireccionDesdeIndice(rotacionAnterior));
    }
  }

  /// Cambia la orientación del barco a vertical u horizontal según `esVertical`.
  ///
  /// Este método es público para que pueda ser usado por el tablero.
  /// Internamente usa `_rotar()` las veces necesarias para alcanzar la orientación deseada.
  void rotar(bool esVertical) {
    if (esVertical == esVertical) return;

    // Intentamos rotar hasta alcanzar la orientación deseada (máximo 3 rotaciones)
    int intentos = 0;
    while (esVertical != esVertical && intentos < 4) {
      _rotar();
      intentos++;
    }
  }

  /// Calcula y aplica la nueva posición del barco en el tablero.
  void _actualizarPosicionEnTablero(Vector2 gridPosition) {
    gameRef.tablero.liberarCeldas(_celdasOcupadas);
    position = _calcularPosicionCentrada(gridPosition);
    _celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
    gameRef.tablero.ocuparCeldas(_celdasOcupadas);
  }

  /// Devuelve `true` si este barco colisiona visualmente con otro.
  bool colisionaCon(Barco otroBarco) => toRect().overlaps(otroBarco.toRect());

  /// Retorna la lista actual de celdas que ocupa el barco.
  List<Vector2> getCeldasOcupadas(double tamanoCelda) => _celdasOcupadas;

  // ------------------------------------------------------------------------
  // MÉTODOS PRIVADOS
  // ------------------------------------------------------------------------

  /// Ajusta el tamaño y dirección del sprite según la rotación.
  void _actualizarTamanioYVisual() {
    size.setValues(50.0 * (esVertical ? 1 : longitud), 50.0 * (esVertical ? longitud : 1));
    barcoVisual.size.setFrom(size);
    barcoVisual.cambiarDireccion(_obtenerDireccionDesdeIndice(indiceRotacion));
  }

  /// Obtiene la dirección visual a partir del índice de rotación.
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

  /// Calcula las celdas ocupadas desde una posición de grid.
  List<Vector2> _calcularCeldasOcupadas(Vector2 gridPosition) {
    return List.generate(
      longitud,
      (i) => Vector2(
        gridPosition.x + (esVertical ? 0 : i.toDouble()),
        gridPosition.y + (esVertical ? i.toDouble() : 0),
      ),
    );
  }

  /// Calcula la posición en el mundo que centra el barco en el grid.
  Vector2 _calcularPosicionCentrada(Vector2 gridPosition) {
    final tamanoCelda = gameRef.tablero.tamanioCelda;
    final base = gameRef.tablero.gridToWorld(gridPosition);
    final offsetX = esVertical ? 0.0 : ((longitud - 1) * tamanoCelda / 2);
    final offsetY = esVertical ? ((longitud - 1) * tamanoCelda / 2) : 0.0;
    return base - Vector2(offsetX, offsetY);
  }

  /// Resalta la posición en el tablero donde se movería el barco.
  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tablero.worldToGrid(position);
    gameRef.tablero.resaltarPosicion(gridPosition, longitud, esVertical, _celdasOcupadas);
  }

  /// Elimina cualquier resaltado del tablero.
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

  /// Convierte el componente en un rectángulo, útil para detección de colisiones.
  @override
  Rect toRect() => Rect.fromLTWH(position.x, position.y, size.x, size.y);
}
