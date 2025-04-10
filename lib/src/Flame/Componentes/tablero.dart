/// ---------------------------------------------------------------------------
/// `Tablero` - Componente principal del juego que representa una grilla 2D
/// para la colocación de barcos. Soporta validación de ubicaciones,
/// visualización de coordenadas, y resaltado de celdas.
/// ---------------------------------------------------------------------------

library;

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'barco.dart';
import 'celda.dart';
import 'coordenada.dart';

/// Componente Flame que representa un tablero de juego dinámico y visual.
class Tablero extends PositionComponent with HasGameRef {
  // ---------------------------------------------------------------------------
  // Propiedades configurables
  // ---------------------------------------------------------------------------

  /// Número de filas del tablero.
  final int filas;

  /// Número de columnas del tablero.
  final int columnas;

  /// Tamaño visual de cada celda en píxeles.
  final double tamanioCelda;

  // ---------------------------------------------------------------------------
  // Estructuras internas
  // ---------------------------------------------------------------------------

  /// Grilla 2D que contiene todas las celdas.
  late final List<List<Celda>> grilla;

  /// Lista de coordenadas visuales (letras y números).
  final List<Coordenada> coordenadas = [];

  /// Lista de barcos actualmente colocados en el tablero.
  final List<Barco> barcos = [];

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  Tablero({
    required this.filas,
    required this.columnas,
    required this.tamanioCelda,
    super.position,
    super.size,
  }) {
    grilla = List.generate(
      filas,
      (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)),
    );
  }

  /// Retorna el área del tablero como `Rect`, útil para detección de colisiones.
  Rect get area => position.toOffset() & size.toSize();

  @override
  Future<void> onLoad() async {
    await _crearCeldas();
    _agregarCoordenadasVisuales();
  }

  // ---------------------------------------------------------------------------
  // Celdas
  // ---------------------------------------------------------------------------

  /// Crea y posiciona visualmente todas las celdas del tablero.
  Future<void> _crearCeldas() async {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final celda =
            grilla[fila][columna]
              ..position = Vector2(
                columna * tamanioCelda + tamanioCelda,
                fila * tamanioCelda + tamanioCelda,
              )
              ..size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Devuelve la celda en la posición indicada, o null si está fuera de rango.
  Celda? obtenerCelda(int fila, int columna) {
    final filaValida = fila >= 0 && fila < filas;
    final columnaValida = columna >= 0 && columna < columnas;
    return filaValida && columnaValida ? grilla[fila][columna] : null;
  }

  // ---------------------------------------------------------------------------
  // Coordenadas visuales (bordes)
  // ---------------------------------------------------------------------------

  void _agregarCoordenadasVisuales() {
    const letras = 'ABCDEFGHIJKL';

    for (int columna = 0; columna < columnas; columna++) {
      coordenadas.add(
        Coordenada(
          texto: letras[columna],
          posicion: Vector2((columna * tamanioCelda) + tamanioCelda + tamanioCelda / 2 - 8, 0),
        ),
      );
    }

    for (int fila = 0; fila < filas; fila++) {
      coordenadas.add(
        Coordenada(
          texto: '${fila + 1}',
          posicion: Vector2(0, (fila * tamanioCelda) + tamanioCelda + tamanioCelda / 2 - 8),
        ),
      );
    }

    addAll(coordenadas);
  }

  // ---------------------------------------------------------------------------
  // Lógica de colocación de barcos
  // ---------------------------------------------------------------------------

  /// Intenta agregar un barco al tablero y marca las celdas ocupadas.
  void agregarBarco(Barco barco, Vector2 posicionInicial, bool esVertical) {
    barcos.add(barco);

    final int filaInicio = posicionInicial.y.floor();
    final int columnaInicio = posicionInicial.x.floor();

    for (int i = 0; i < barco.longitud; i++) {
      final int fila = esVertical ? filaInicio + i : filaInicio;
      final int columna = esVertical ? columnaInicio : columnaInicio + i;
      final celda = obtenerCelda(fila, columna);
      celda?.colocarBarco();
    }

    add(barco);
  }

  /// Verifica si un barco se puede colocar en la posición deseada.
  bool esPosicionValida(Vector2 gridPosition, int longitud, bool esVertical) {
    final int startX = gridPosition.x.floor();
    final int startY = gridPosition.y.floor();

    for (int i = 0; i < longitud; i++) {
      final int fila = esVertical ? startY + i : startY;
      final int columna = esVertical ? startX : startX + i;

      final celda = obtenerCelda(fila, columna);
      if (celda == null || celda.tieneBarco) return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Resaltado de celdas (feedback visual)
  // ---------------------------------------------------------------------------

  /// Resalta las celdas donde se intenta colocar un barco.
  void resaltarPosicion(Vector2 gridPosition, int longitud, bool esVertical) {
    resetearResaltado(); // Limpiar antes de resaltar nuevo intento

    for (int i = 0; i < longitud; i++) {
      final int fila = esVertical ? gridPosition.y.floor() + i : gridPosition.y.floor();
      final int columna = esVertical ? gridPosition.x.floor() : gridPosition.x.floor() + i;

      final celda = obtenerCelda(fila, columna);
      if (celda != null) {
        final esValida = esPosicionValida(Vector2(columna.toDouble(), fila.toDouble()), 1, false);
        esValida ? celda.resaltar() : celda.rechazar();
      }
    }
  }

  /// Limpia todos los resaltados de las celdas.
  void resetearResaltado() {
    for (final fila in grilla) {
      for (final celda in fila) {
        celda.resetearColor();
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Extensiones utilitarias para conversión de coordenadas
// ---------------------------------------------------------------------------

/// Extensión utilitaria para convertir entre coordenadas del mundo y de grilla.
extension TableroUtils on Tablero {
  /// Convierte una posición del mundo a una posición de grilla.
  Vector2 worldToGrid(Vector2 worldPosition) {
    return Vector2(
      ((worldPosition.x - position.x) / tamanioCelda),
      ((worldPosition.y - position.y) / tamanioCelda),
    );
  }

  /// Convierte una posición de grilla a una posición del mundo.
  Vector2 gridToWorld(Vector2 gridPosition) {
    return Vector2(
      position.x + gridPosition.x * tamanioCelda + tamanioCelda / 2,
      position.y + gridPosition.y * tamanioCelda + tamanioCelda / 2,
    );
  }
}
