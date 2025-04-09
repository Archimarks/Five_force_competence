/// ---------------------------------------------------------------------------
/// `Tablero` es un componente principal de Flame que representa la grilla
/// de juego. Soporta una dimensión configurable, creación visual de celdas,
/// asignación de cuadrantes para análisis tipo Porter y coordenadas visuales.
/// ---------------------------------------------------------------------------
library;

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'barco.dart'; // si tienes una clase `Barco`
import 'celda.dart';
import 'coordenada.dart';
import 'cuadrante.dart';

/// Componente de Flame que representa un tablero de juego dinámico.
class Tablero extends PositionComponent with HasGameRef {
  /// Número de filas del tablero.
  final int filas;

  /// Número de columnas del tablero.
  final int columnas;

  /// Tamaño visual de cada celda en píxeles.
  final double tamanioCelda;

  /// Grilla 2D que contiene todas las celdas.
  late final List<List<Celda>> grilla;

  /// Lista de los cinco cuadrantes del modelo de Porter.
  final List<Cuadrante> cuadrantes = [
    Cuadrante(nombre: 'A'),
    Cuadrante(nombre: 'B'),
    Cuadrante(nombre: 'C'),
    Cuadrante(nombre: 'D'),
    Cuadrante(nombre: 'E'),
  ];

  /// Lista de coordenadas visuales (letras/números en bordes).
  final List<Coordenada> coordenadas = [];

  /// Lista de barcos actualmente en el tablero.
  final List<Barco> barcos = [];

  /// Constructor del tablero. Tamaño y dimensiones por defecto son 12x12.
  Tablero({
    this.filas = 12,
    this.columnas = 12,
    this.tamanioCelda = 20.0,
    super.position,
    super.size,
  }) {
    grilla = List.generate(
      filas,
      (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)),
    );
  }

  /// Devuelve un nuevo tablero con algunos valores modificados.
  Tablero copyWith({
    int? filas,
    int? columnas,
    double? tamanioCelda,
    Vector2? position,
    Vector2? size,
  }) {
    return Tablero(
      filas: filas ?? this.filas,
      columnas: columnas ?? this.columnas,
      tamanioCelda: tamanioCelda ?? this.tamanioCelda,
      position: position ?? this.position.clone(),
      size: size ?? this.size.clone(),
    );
  }

  /// Retorna el área del tablero como `Rect`, útil para validaciones.
  Rect get area => position.toOffset() & size.toSize();

  @override
  Future<void> onLoad() async {
    await _asignarCeldasACuadrantes();
    await _construirCeldas();
    _agregarCoordenadas();
  }

  /// Asigna celdas a cuadrantes del modelo de Porter.
  Future<void> _asignarCeldasACuadrantes() async {
    for (final fila in grilla) {
      for (final celda in fila) {
        final f = celda.fila;
        final c = celda.columna;

        if (f < filas ~/ 2 && c < columnas ~/ 2) {
          cuadrantes[0].agregarCelda(celda); // A: Compradores
        }
        if (f < filas ~/ 2 && c >= columnas ~/ 2) {
          cuadrantes[1].agregarCelda(celda); // B: Proveedores
        }
        if (f >= filas ~/ 2 && c < columnas ~/ 2) {
          cuadrantes[2].agregarCelda(celda); // C: Nuevos competidores
        }
        if (f >= filas ~/ 2 && c >= columnas ~/ 2) {
          cuadrantes[3].agregarCelda(celda); // D: Rivalidad
        }
        if (f >= filas ~/ 3 && f < filas * 2 ~/ 3 && c >= columnas ~/ 3 && c < columnas * 2 ~/ 3) {
          cuadrantes[4].agregarCelda(celda); // E: Sustitutos
        }
      }
    }
  }

  /// Crea y posiciona celdas visualmente dentro del tablero.
  Future<void> _construirCeldas() async {
    for (final fila in grilla) {
      for (final celda in fila) {
        celda
          ..position = Vector2(
            celda.columna * tamanioCelda + tamanioCelda,
            celda.fila * tamanioCelda + tamanioCelda,
          )
          ..size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Agrega coordenadas visuales (letras y números) al tablero.
  void _agregarCoordenadas() {
    const letras = 'ABCDEFGHIJKL';

    for (int col = 0; col < columnas; col++) {
      coordenadas.add(
        Coordenada(
          texto: letras[col],
          posicion: Vector2((col * tamanioCelda) + tamanioCelda + tamanioCelda / 2 - 8, 0),
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

  /// Devuelve la celda en la fila y columna especificadas.
  Celda? obtenerCelda(int fila, int columna) {
    if (fila >= 0 && fila < filas && columna >= 0 && columna < columnas) {
      return grilla[fila][columna];
    }
    return null;
  }

  /// Agrega un barco al tablero (lógica adicional puede colocarse aquí).
  void agregarBarco(Barco barco) {
    barcos.add(barco);
  }

  /// Devuelve los cuadrantes del tablero.
  List<Cuadrante> obtenerCuadrantes() => cuadrantes;
}

/// Extensión utilitaria para convertir entre coordenadas del mundo y del tablero.
extension TableroUtils on Tablero {
  Vector2 worldToGrid(Vector2 worldPosition) {
    return Vector2(
      ((worldPosition.x - position.x) / tamanioCelda).floor().toDouble(),
      ((worldPosition.y - position.y) / tamanioCelda).floor().toDouble(),
    );
  }

  Vector2 gridToWorld(Vector2 gridPosition) {
    return Vector2(
      position.x + gridPosition.x * tamanioCelda + tamanioCelda / 2,
      position.y + gridPosition.y * tamanioCelda + tamanioCelda / 2,
    );
  }

  /// Verifica si un barco se puede colocar desde una celda dada, respetando la longitud.
  bool esPosicionValida(Vector2 gridPosition, int longitud, bool esVertical) {
    final int startX = gridPosition.x.toInt();
    final int startY = gridPosition.y.toInt();

    if (esVertical) {
      if (startY + longitud > filas) return false;
      for (int i = 0; i < longitud; i++) {
        final celda = obtenerCelda(startY + i, startX);
        if (celda == null || celda.tieneBarco) return false;
      }
    } else {
      if (startX + longitud > columnas) return false;
      for (int i = 0; i < longitud; i++) {
        final celda = obtenerCelda(startY, startX + i);
        if (celda == null || celda.tieneBarco) return false;
      }
    }
    return true;
  }
}
