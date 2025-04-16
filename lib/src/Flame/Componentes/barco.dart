/// ------------------------------------------------------------------------
/// Archivo: barco.dart
/// Proyecto: Five Force Competence
/// Desarrollado por: Geraldine Perilla Valderrama
/// Fecha: 2025
///
/// Descripción:
/// Este componente representa un barco arrastrable y rotable dentro del área de
/// TableroEstrategia. Permite interacción mediante gestos: arrastrar para
/// posicionar, tocar para rotar, y valida las posiciones para evitar colisiones
/// o ubicaciones inválidas dentro del tablero.
///
/// Cada barco está compuesto visualmente por un conjunto de imágenes
/// (una por dirección) y se adapta automáticamente al grid del tablero.
///
/// [onDragStartCallback]: Callback llamado cuando comienza el arrastre del barco.
/// [onDragEndCallback]: Callback llamado cuando finaliza el arrastre del barco.
/// ------------------------------------------------------------------------

library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'direccion.dart';
import 'setup_game.dart';
import 'sprites_barco.dart';
import 'tablero_estrategia.dart'; // Importa la clase combinada

/// Componente que representa un barco arrastrable y rotable dentro del
/// `TableroEstrategia`.
///
/// Maneja su visualización a través de sprites por dirección,
/// validación de ubicación dentro del tablero, y gestos de usuario.
class Barco extends PositionComponent with DragCallbacks, TapCallbacks, HasGameRef<SetupGame> {
  // ------------------------------------------------------------------------
  // PROPIEDADES - ESTADO Y CONFIGURACIÓN
  // ------------------------------------------------------------------------

  // --------------------
  // Identificación y configuración
  // --------------------

  /// Identificador único del barco.
  late final String id;

  /// Número de celdas que ocupa el barco.
  final int longitud;

  /// Tamaño de cada celda del tablero.
  final double tamanioesCelda;

  /// Componente visual del barco que administra sprites según dirección.
  late final SpritesBarco barcoVisual;

  /// Rutas de los sprites según la rotación o estado.
  final Map<String, String> rutasSprites;

  // --------------------
  // Estado de rotación y orientación
  // --------------------

  /// Índice de rotación actual (0: arriba, 1: derecha, 2: abajo, 3: izquierda).
  int indiceRotacion = 0;

  /// Dirección vertical según el índice actual.
  bool get esVertical => (indiceRotacion % 2 == 0);

  // --------------------
  // Estado de interacción
  // --------------------

  /// Indica si el barco está siendo arrastrado actualmente.
  bool estaSiendoArrastrado = false;

  /// Callback llamado cuando comienza el arrastre de este barco.
  final void Function(Barco) onDragStartCallback;

  /// Callback llamado cuando finaliza el arrastre de este barco.
  final void Function(Barco) onDragEndCallback;

  /// Callback ejecutado cuando el barco cambia su posición (durante arrastre).
  void Function(Vector2 nuevaPosicion)? onPosicionCambiada;

  /// Función personalizada para validar si una posición es válida.
  bool Function(Barco barco)? validarColocacion;

  // --------------------
  // Posiciones y celdas
  // --------------------

  /// Guarda la posición inicial del barco.
  late Vector2 _posicionInicial;

  /// Guarda la posición previa al arrastre para revertir si es inválido.
  late Vector2 _posicionAnterior;

  /// Guarda la posición actual del barco.
  late Vector2 _posicionActual;

  /// Lista de coordenadas (en grid) ocupadas por el barco en el tablero.
  List<Vector2> _celdasOcupadas = [];

  /// Devuelve la posición inicial del barco.
  Vector2 get posicionInicial => _posicionInicial.clone();

  /// Devuelve la posición anterior del barco.
  Vector2 get posicionAnterior => _posicionAnterior;

  /// Devuelve la posición actual del barco.
  Vector2 get posicionActual => _posicionActual;

  // --------------------
  // Prioridades visuales
  // --------------------

  static const int _prioridadNormal = 0;
  static const int _prioridadArrastrando = 1;

  // --------------------
  // Metodos
  // --------------------

  void actualizarPosicionInicial(Vector2 nuevaPosicion) {
    _posicionInicial = nuevaPosicion.clone();
  }

  void actualizarPosicionAnterior(Vector2 nuevaPosicion) {
    _posicionAnterior = nuevaPosicion.clone();
  }

  void actualizarPosicionActual(Vector2 nuevaPosicion) {
    _posicionActual = nuevaPosicion.clone();
  }

  // ------------------------------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------------------------------

  /// Constructor del componente Barco.
  ///
  /// Requiere longitud, rutas de sprites, tamaño de la celda y los callbacks de arrastre.
  /// Puede incluir una posición inicial.
  Barco({
    // Opcionales
    String? id,
    Vector2? posicionInicial,
    this.onPosicionCambiada,
    this.validarColocacion,

    // Requeridos
    required this.longitud,
    required this.rutasSprites,
    required this.tamanioesCelda,
    required this.onDragStartCallback,
    required this.onDragEndCallback,
  }) : super(position: posicionInicial ?? Vector2.zero(), size: Vector2(tamanioesCelda, tamanioesCelda * longitud), anchor: Anchor.topLeft) {
    this.id = id ?? UniqueKey().toString();

    _posicionInicial = position.clone();

    barcoVisual = SpritesBarco(rutasSprites: rutasSprites, direccionActual: Direccion.arriba, tamano: size.clone());
    add(barcoVisual);

    add(RectangleHitbox(size: size.clone()));
  }

  // ------------------------------------------------------------------------
  // GESTOS DE USUARIO
  // ------------------------------------------------------------------------

  /// Evento de tap: al tocar el barco, se rota si no está en el tablero.
  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    final estaEnTablero = gameRef.tableroEstrategia.areaTablero.contains(position.toOffset());
    if (!estaEnTablero) {
      _rotar();
    }
  }

  /// Evento de inicio de arrastre: eleva prioridad, guarda la posición actual y llama al callback.
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    estaSiendoArrastrado = true;
    priority = _prioridadArrastrando;
    _posicionAnterior = position.clone();
    onDragStartCallback(this);
  }

  /// Evento durante el arrastre: actualiza la posición y visualización del tablero.
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.localDelta;
    onPosicionCambiada?.call(position);
    _actualizarVisualizacionTablero();
  }

  /// Evento al finalizar el arrastre: revierte prioridad, llama al callback y gestiona la colocación.
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    estaSiendoArrastrado = false;
    priority = _prioridadNormal;
    onDragEndCallback(this);

    final gridPosition = gameRef.tableroEstrategia.worldToGrid(position);

    final estaFueraDelContenedorBarco = !gameRef.tableroEstrategia.areaBarcosIniciales.contains(position.toOffset());
    final estaFueraDelTablero = !gameRef.tableroEstrategia.areaTablero.contains(position.toOffset());
    final esValidaEnTablero = !estaFueraDelTablero && (validarColocacion?.call(this) ?? gameRef.tableroEstrategia.esPosicionValida(gridPosition, longitud, esVertical));

    if (estaFueraDelContenedorBarco && estaFueraDelTablero && !esValidaEnTablero) {
      gameRef.tableroEstrategia.liberarCeldas(_celdasOcupadas);
      _celdasOcupadas.clear();
      position = _posicionInicial;
      _resetearVisualizacionTablero();
      return;
    } else if (estaFueraDelContenedorBarco && !estaFueraDelTablero && esValidaEnTablero) {
      gameRef.tableroEstrategia.liberarCeldas(_celdasOcupadas);
      _celdasOcupadas.clear();
      _celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
      gameRef.tableroEstrategia.agregarBarco(this, gridPosition, esVertical);
      return;
    } else if (estaFueraDelContenedorBarco && estaFueraDelTablero && !esValidaEnTablero) {
      _celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
      position = _posicionInicial;
      _resetearVisualizacionTablero();
      return;
    } else {
      position = _posicionAnterior;
      _resetearVisualizacionTablero();
      return;
    }
  }

  // ------------------------------------------------------------------------
  // FUNCIONALIDAD DEL BARCO
  // ------------------------------------------------------------------------

  /// Gira el barco 90° en sentido horario.
  void _rotar() {
    indiceRotacion = (indiceRotacion + 1) % 4;
    _actualizarTamanioYVisual();
  }

  /// Cambia la orientación del barco a vertical u horizontal según `esVertical`.
  ///
  /// Este método es público para que pueda ser usado externamente.
  /// Internamente usa `_rotar()` las veces necesarias para alcanzar la orientación deseada.
  void rotar(bool esVertical) {
    if (esVertical == this.esVertical) return;

    // Intentamos rotar hasta alcanzar la orientación deseada (máximo 3 rotaciones)
    int intentos = 0;
    while (esVertical != this.esVertical && intentos < 4) {
      _rotar();
      intentos++;
    }
  }

  /// Calcula y aplica la nueva posición del barco en el tablero.
  //void _actualizarPosicionEnTablero(Vector2 gridPosition) {
  //gameRef.tableroEstrategia.liberarCeldas(_celdasOcupadas);
  //position = calcularPosicionCentrada(gridPosition);
  //_celdasOcupadas = _calcularCeldasOcupadas(gridPosition);
  //gameRef.tableroEstrategia.ocuparCeldas(_celdasOcupadas);
  //}

  /// Devuelve `true` si este barco colisiona visualmente con otro.
  bool colisionaCon(Barco otroBarco) => toRect().overlaps(otroBarco.toRect());

  /// Retorna la lista actual de celdas que ocupa el barco.
  List<Vector2> getCeldasOcupadas(tamanioesCelda) => _celdasOcupadas;

  // ------------------------------------------------------------------------
  // MÉTODOS PRIVADOS
  // ------------------------------------------------------------------------

  /// Ajusta el tamaño y dirección del sprite según la rotación.
  void _actualizarTamanioYVisual() {
    size.setValues(tamanioesCelda * (esVertical ? 1 : longitud), tamanioesCelda * (esVertical ? longitud : 1));
    barcoVisual.size.setFrom(size); // Asegúrate de que el tamaño del visual se actualice
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
    return List.generate(longitud, (i) => Vector2(gridPosition.x + (esVertical ? 0 : i.toDouble()), gridPosition.y + (esVertical ? i.toDouble() : 0)));
  }

  /// Calcula la posición en el mundo que centra el barco en el grid.
  Vector2 calcularPosicionCentrada(Vector2 gridPosition) {
    final tamanoCelda = gameRef.tableroEstrategia.tamanioCelda;
    Vector2 base;

    if (longitud == 1) {
      // Para barcos de longitud 1, usamos el centro de la celda
      base = gameRef.tableroEstrategia.gridToWorldCentro(gridPosition);
    } else {
      // Para barcos de longitud > 1, usamos la esquina superior izquierda de la celda
      base = gameRef.tableroEstrategia.gridToWorldEsquina(gridPosition, longitud, esVertical);
    }

    double offsetX = 0.0;
    double offsetY = 0.0;
    Vector2 resultado;

    if (longitud > 1) {
      offsetX = esVertical ? 0.0 : ((longitud - 1) / 2) * tamanoCelda;
      offsetY = esVertical ? ((longitud - 1) / 2) * tamanoCelda : 0.0;
      resultado = base + Vector2(0, tamanoCelda) - Vector2(offsetX, offsetY); // Ajuste para esquina superior izquierda
    } else {
      resultado = base - Vector2(tamanoCelda / 2, tamanoCelda / 2);
    }

    return resultado;
  }

  /// Resalta la posición en el tablero donde se movería el barco.
  void _actualizarVisualizacionTablero() {
    final gridPosition = gameRef.tableroEstrategia.worldToGrid(position);
    gameRef.tableroEstrategia.resaltarPosicion(gridPosition, longitud, esVertical, _celdasOcupadas);
  }

  /// Elimina cualquier resaltado del tablero.
  void _resetearVisualizacionTablero() {
    gameRef.tableroEstrategia.resetearResaltado();
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
