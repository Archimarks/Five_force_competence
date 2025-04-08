import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'celda.dart';
import 'coordenada.dart';
import 'cuadrante.dart';

const int filas = 12;
const int columnas = 12;
const double tamanioCelda = 32.0;

/// ---------------------------------------------------------------------------
/// `Tablero` es un componente principal de Flame que representa la grilla
/// de juego 12x12. Maneja celdas, coordenadas visuales y los cuadrantes
/// del modelo de las cinco fuerzas.
/// ---------------------------------------------------------------------------
class Tablero extends Component with HasGameRef {
  /// Grilla 12x12 que contiene todas las celdas del tablero.
  final List<List<Celda>> grilla = List.generate(
    filas,
    (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)),
  );

  /// Lista de los cinco cuadrantes del modelo de Porter.
  final List<Cuadrante> cuadrantes = [
    Cuadrante(nombre: 'A'),
    Cuadrante(nombre: 'B'),
    Cuadrante(nombre: 'C'),
    Cuadrante(nombre: 'D'),
    Cuadrante(nombre: 'E'),
  ];

  /// Coordenadas visuales de letras y números.
  final List<Coordenada> coordenadas = [];

  @override
  Future<void> onLoad() async {
    _asignarCeldasACuadrantes();
    await _construirCeldas();
    _agregarCoordenadas();
  }

  /// Asigna celdas a uno o más cuadrantes, según reglas predefinidas.
  void _asignarCeldasACuadrantes() {
    for (var fila in grilla) {
      for (var celda in fila) {
        final f = celda.fila;
        final c = celda.columna;

        // Cuadrante A: superior izquierda
        if (f < 6 && c < 6) {
          cuadrantes[0].agregarCelda(celda);
        }

        // Cuadrante B: superior derecha
        if (f < 6 && c >= 6) {
          cuadrantes[1].agregarCelda(celda);
        }

        // Cuadrante C: inferior izquierda
        if (f >= 6 && c < 6) {
          cuadrantes[2].agregarCelda(celda);
        }

        // Cuadrante D: inferior derecha
        if (f >= 6 && c >= 6) {
          cuadrantes[3].agregarCelda(celda);
        }

        // Cuadrante E: central (solapa A–D)
        if (f >= 4 && f < 8 && c >= 4 && c < 8) {
          cuadrantes[4].agregarCelda(celda);
        }
      }
    }
  }

  /// Construye visualmente cada celda en el tablero.
  Future<void> _construirCeldas() async {
    for (var fila in grilla) {
      for (var celda in fila) {
        celda.position = Vector2(
          celda.columna * tamanioCelda + tamanioCelda,
          celda.fila * tamanioCelda + tamanioCelda,
        );
        celda.size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Crea las coordenadas visuales (letras arriba, números a la izquierda).
  void _agregarCoordenadas() {
    final letras = 'ABCDEFGHIJKL'.split('');

    // Letras en la parte superior
    for (int col = 0; col < columnas; col++) {
      coordenadas.add(
        Coordenada(texto: letras[col], posicion: Vector2((col * tamanioCelda) + tamanioCelda, 0)),
      );
    }

    // Números en la parte izquierda
    for (int fila = 0; fila < filas; fila++) {
      coordenadas.add(
        Coordenada(
          texto: '${fila + 1}',
          posicion: Vector2(0, (fila * tamanioCelda) + tamanioCelda),
        ),
      );
    }
  }

  /// Renderiza las coordenadas visuales sobre el tablero.
  @override
  void render(Canvas canvas) {
    for (final coord in coordenadas) {
      coord.render(canvas);
    }
  }
}
