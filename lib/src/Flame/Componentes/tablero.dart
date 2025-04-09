/// ---------------------------------------------------------------------------
/// `Tablero` es un componente principal de Flame que representa la grilla
/// de juego 12x12. Maneja la creación y disposición de las celdas,
/// la asignación de celdas a los cuadrantes del modelo de las cinco fuerzas
/// y la visualización de las coordenadas de los bordes.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'celda.dart';
import 'coordenada.dart';
import 'cuadrante.dart';

/// Número de filas en el tablero.
const int filas = 12;

/// Número de columnas en el tablero.
const int columnas = 12;

/// Componente de Flame que representa el tablero de juego.
class Tablero extends PositionComponent with HasGameRef {
  /// Tamaño visual de cada celda en píxeles.
  static const double tamanioCelda = 40.0;

  // Cambiar Component a PositionComponent
  /// Grilla 2D que contiene todas las celdas del tablero.
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

  /// Lista de componentes visuales para las coordenadas de los bordes.
  final List<Coordenada> coordenadas = [];

  /// Constructor del tablero.
  Tablero({super.position, super.size}); // Añadir constructor para position y size

  /// Se llama una vez que el componente se adjunta al juego.
  @override
  Future<void> onLoad() async {
    await _asignarCeldasACuadrantes();
    await _construirCeldas();
    _agregarCoordenadas();
  }

  /// Asigna cada celda del tablero a uno o más cuadrantes según reglas específicas.
  Future<void> _asignarCeldasACuadrantes() async {
    for (final fila in grilla) {
      for (final celda in fila) {
        final f = celda.fila;
        final c = celda.columna;

        // Cuadrante A: Poder de negociación de compradores (superior izquierda)
        if (f < 6 && c < 6) {
          cuadrantes[0].agregarCelda(celda);
        }

        // Cuadrante B: Poder de negociación de proveedores (superior derecha)
        if (f < 6 && c >= 6) {
          cuadrantes[1].agregarCelda(celda);
        }

        // Cuadrante C: Amenaza de nuevos competidores (inferior izquierda)
        if (f >= 6 && c < 6) {
          cuadrantes[2].agregarCelda(celda);
        }

        // Cuadrante D: Rivalidad entre competidores existentes (inferior derecha)
        if (f >= 6 && c >= 6) {
          cuadrantes[3].agregarCelda(celda);
        }

        // Cuadrante E: Amenaza de productos o servicios sustitutos (central)
        if (f >= 4 && f < 8 && c >= 4 && c < 8) {
          cuadrantes[4].agregarCelda(celda);
        }
      }
    }
  }

  /// Crea y añade visualmente cada celda como un componente hijo del tablero.
  Future<void> _construirCeldas() async {
    for (final fila in grilla) {
      for (final celda in fila) {
        celda.position = Vector2(
          celda.columna * tamanioCelda + tamanioCelda, // Ajuste para el espacio de las coordenadas
          celda.fila * tamanioCelda + tamanioCelda, // Ajuste para el espacio de las coordenadas
        );
        celda.size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Crea y añade los componentes de texto para las coordenadas de los bordes.
  Future<void> _agregarCoordenadas() async {
    const letras = 'ABCDEFGHIJKL';

    // Letras en la parte superior
    for (int col = 0; col < columnas; col++) {
      coordenadas.add(
        Coordenada(
          texto: letras[col],
          posicion: Vector2(
            (col * tamanioCelda) + tamanioCelda + (tamanioCelda / 2) - 8,
            0,
          ), // Centrado aproximado
        ),
      );
    }

    // Números en la parte izquierda
    for (int fila = 0; fila < filas; fila++) {
      coordenadas.add(
        Coordenada(
          texto: '${fila + 1}',
          posicion: Vector2(
            0,
            (fila * tamanioCelda) + tamanioCelda + (tamanioCelda / 2) - 8,
          ), // Centrado aproximado
        ),
      );
    }
    addAll(coordenadas); // Añadir las coordenadas al tablero para que se rendericen
  }

  /// Renderiza las coordenadas visuales sobre el tablero.
  @override
  void render(Canvas canvas) {
    // Las coordenadas ahora son componentes hijos y se renderizan automáticamente
    // No es necesario iterar y renderizar aquí directamente.
    super.render(canvas);
  }

  /// Devuelve la celda en la fila y columna especificadas, o null si está fuera de los límites.
  Celda? obtenerCelda(int fila, int columna) {
    if (fila >= 0 && fila < filas && columna >= 0 && columna < columnas) {
      return grilla[fila][columna];
    }
    return null;
  }

  /// Devuelve la lista de cuadrantes.
  List<Cuadrante> obtenerCuadrantes() => cuadrantes;
}

// Extensión en Tablero para convertir entre coordenadas mundiales y de la grilla
extension TableroUtils on Tablero {
  Vector2 worldToGrid(Vector2 worldPosition) {
    return Vector2(
      ((worldPosition.x - position.x) / Tablero.tamanioCelda).floor().toDouble(),
      ((worldPosition.y - position.y) / Tablero.tamanioCelda).floor().toDouble(),
    );
  }

  Vector2 gridToWorld(Vector2 gridPosition) {
    return Vector2(
      position.x + gridPosition.x * Tablero.tamanioCelda + Tablero.tamanioCelda / 2,
      position.y + gridPosition.y * Tablero.tamanioCelda + Tablero.tamanioCelda / 2,
    );
  }

  bool esPosicionValida(Vector2 gridPosition, int longitud, bool esVertical) {
    final int startX = gridPosition.x.toInt();
    final int startY = gridPosition.y.toInt();

    if (esVertical) {
      if (startY + longitud > filas) return false;
      for (int i = 0; i < longitud; i++) {
        final celda = obtenerCelda(startY + i, startX);
        if (celda == null || celda.tieneBarco)
          return false; // Verificar límites y si ya hay un barco
      }
    } else {
      if (startX + longitud > columnas) return false;
      for (int i = 0; i < longitud; i++) {
        final celda = obtenerCelda(startY, startX + i);
        if (celda == null || celda.tieneBarco)
          return false; // Verificar límites y si ya hay un barco
      }
    }
    return true;
  }
}
