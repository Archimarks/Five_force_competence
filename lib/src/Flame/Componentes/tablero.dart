/// ---------------------------------------------------------------------------
/// `Tablero` - Componente principal del juego que representa una grilla 2D
/// para la colocación de barcos. Soporta validación de ubicaciones,
/// visualización de coordenadas, y resaltado de celdas.
/// ---------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'barco.dart';
import 'celda.dart';
import 'coordenada.dart';

/// `Tablero` hereda de `PositionComponent`, lo que le permite tener una posición
/// y tamaño dentro del juego. También utiliza el mixin `HasGameRef` para acceder
/// a referencias del juego Flame.
class Tablero extends PositionComponent with HasGameRef {
  /// Número de filas de la grilla
  final int filas;

  /// Número de columnas de la grilla
  final int columnas;

  /// Tamaño (ancho y alto) de cada celda en píxeles
  final double tamanioCelda;

  /// Grilla 2D de celdas que conforman el tablero
  late final List<List<Celda>> grilla;

  /// Coordenadas visuales (letras/índices) que se dibujan fuera del tablero
  final List<Coordenada> coordenadas = [];

  /// Lista de barcos actualmente colocados en el tablero
  final List<Barco> barcos = [];

  /// Constructor del tablero, inicializa dimensiones y genera la grilla de celdas
  Tablero({
    required this.filas,
    required this.columnas,
    required this.tamanioCelda,
    super.position,
    super.size,
  }) {
    // Se genera la matriz de celdas usando List.generate
    grilla = List.generate(
      filas,
      (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)),
    );
  }

  /// Calcula el área rectangular del tablero en coordenadas del mundo
  Rect get area => position.toOffset() & size.toSize();

  @override
  Future<void> onLoad() async {
    await _crearCeldas(); // Posiciona las celdas dentro del tablero
    _agregarCoordenadasVisuales(); // Añade letras/números de referencia visual
  }

  /// Posiciona y agrega cada celda a la escena del juego
  Future<void> _crearCeldas() async {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final celda =
            grilla[fila][columna]
              ..position = Vector2(
                columna * tamanioCelda + tamanioCelda,
                fila * tamanioCelda + tamanioCelda,
              ) // Ajusta posición de celda
              ..size = Vector2.all(tamanioCelda); // Define el tamaño cuadrado
        add(celda); // Añade la celda a la escena
      }
    }
  }

  /// Devuelve una celda en coordenadas fila/columna si está dentro de los límites
  Celda? obtenerCelda(int fila, int columna) {
    final filaValida = fila >= 0 && fila < filas;
    final columnaValida = columna >= 0 && columna < columnas;
    return filaValida && columnaValida ? grilla[fila][columna] : null;
  }

  /// Calcula las celdas que ocuparía un barco desde cierta posición en la grilla
  List<Vector2> calcularCeldasOcupadas(Vector2 gridPos, int longitud, bool esVertical) {
    final celdas = <Vector2>[];
    final filaInicio = gridPos.y.floor();
    final columnaInicio = gridPos.x.floor();

    for (int i = 0; i < longitud; i++) {
      final fila = esVertical ? filaInicio + i : filaInicio;
      final columna = esVertical ? columnaInicio : columnaInicio + i;
      celdas.add(Vector2(columna.toDouble(), fila.toDouble()));
    }

    return celdas;
  }

  /// Marca las celdas como ocupadas por un barco
  void ocuparCeldas(List<Vector2> celdas) {
    for (final pos in celdas) {
      final celda = obtenerCelda(pos.y.toInt(), pos.x.toInt());
      celda?.colocarBarco();
    }
  }

  /// Libera las celdas previamente ocupadas
  void liberarCeldas(List<Vector2> celdas) {
    for (final pos in celdas) {
      final celda = obtenerCelda(pos.y.toInt(), pos.x.toInt());
      celda?.liberar();
    }
  }

  /// Agrega letras (A, B, C, ...) y números (1, 2, 3, ...) como referencias visuales
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

  /// Coloca un barco en el tablero si la posición es válida
  void agregarBarco(Barco barco, Vector2 gridPos, bool esVertical) {
    if (!esPosicionValida(gridPos, barco.longitud, esVertical)) return;

    final celdas = calcularCeldasOcupadas(gridPos, barco.longitud, esVertical);
    ocuparCeldas(celdas);

    barcos.add(barco);
    add(barco); // Añade el barco a la escena
  }

  /// Valida si un barco cabe en cierta posición y no hay superposición
  bool esPosicionValida(Vector2 gridPosition, int longitud, bool esVertical) {
    final int startX = gridPosition.x.floor();
    final int startY = gridPosition.y.floor();

    for (int i = 0; i < longitud; i++) {
      final int fila = esVertical ? startY + i : startY;
      final int columna = esVertical ? startX : startX + i;

      if (fila < 0 || fila >= filas || columna < 0 || columna >= columnas) {
        return false; // Fuera de límites
      }

      final celda = obtenerCelda(fila, columna);
      if (celda == null || celda.tieneBarco) return false; // Ya ocupada
    }

    return true;
  }

  /// Mueve o rota un barco a una nueva posición si es válida
  bool actualizarBarco(Barco barco, Vector2 nuevaPos, bool esVertical) {
    final nuevaGrid = worldToGrid(nuevaPos);

    if (!esPosicionValida(nuevaGrid, barco.longitud, esVertical)) return false;

    final celdasAntiguas = calcularCeldasOcupadas(
      worldToGrid(barco.position),
      barco.longitud,
      barco.esVertical,
    );

    final celdasNuevas = calcularCeldasOcupadas(nuevaGrid, barco.longitud, esVertical);

    liberarCeldas(celdasAntiguas);
    ocuparCeldas(celdasNuevas);

    barco.position = gridToWorld(nuevaGrid); // Ajusta posición visual
    barco.esVertical = esVertical; // Actualiza orientación lógica

    return true;
  }

  /// Resalta las celdas que ocuparía un barco como vista previa
  void resaltarPosicion(
    Vector2 gridPosition,
    int longitud,
    bool esVertical, [
    List<Vector2> celdasPropias = const [], // Celdas que ya ocupa este barco
  ]) {
    resetearResaltado(); // Quita cualquier resaltado anterior

    final List<Vector2> celdas = [];

    for (int i = 0; i < longitud; i++) {
      final dx = esVertical ? 0 : i.toDouble();
      final dy = esVertical ? i.toDouble() : 0;

      final x = gridPosition.x + dx;
      final y = gridPosition.y + dy;

      if (x >= columnas || y >= filas) {
        _resaltarComoRechazado(celdas);
        return;
      }

      final celda = obtenerCelda(y.toInt(), x.toInt());
      if (celda == null || (celda.tieneBarco && !celdasPropias.contains(Vector2(x, y)))) {
        _resaltarComoRechazado(celdas);
        return;
      }

      celdas.add(Vector2(x, y));
    }

    for (final coord in celdas) {
      final celda = obtenerCelda(coord.y.toInt(), coord.x.toInt());
      celda?.resaltar(); // Muestra visualmente que está disponible
    }
  }

  /// Muestra en rojo las celdas que hacen inválida la posición
  void _resaltarComoRechazado(List<Vector2> celdasParciales) {
    for (final coord in celdasParciales) {
      final celda = obtenerCelda(coord.y.toInt(), coord.x.toInt());
      celda?.rechazar(); // Estilo visual de rechazo
    }
  }

  /// Quita cualquier resaltado aplicado a las celdas
  void resetearResaltado() {
    for (final fila in grilla) {
      for (final celda in fila) {
        celda.resetearColor(); // Restaura el color original
      }
    }
  }
}

/// Extensión utilitaria para convertir entre coordenadas del mundo y del grid
extension TableroUtils on Tablero {
  /// Convierte una posición del mundo (píxeles) a coordenadas de grilla (columna, fila)
  Vector2 worldToGrid(Vector2 worldPosition) {
    return Vector2(
      ((worldPosition.x - position.x) / tamanioCelda),
      ((worldPosition.y - position.y) / tamanioCelda),
    );
  }

  /// Convierte una coordenada de grilla a posición visual en el mundo
  Vector2 gridToWorld(Vector2 gridPosition) {
    return Vector2(
      position.x + gridPosition.x * tamanioCelda + tamanioCelda / 2,
      position.y + gridPosition.y * tamanioCelda + tamanioCelda / 2,
    );
  }
}
