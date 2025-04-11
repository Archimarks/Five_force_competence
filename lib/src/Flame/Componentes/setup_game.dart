// setup_game.dart
/// ---------------------------------------------------------------------------
/// `SetupGame` - Vista de configuración del juego basada en FlameGame.
/// ---------------------------------------------------------------------------
/// Permite a los usuarios colocar barcos (edificaciones) en un tablero 12x12.
/// Cada barco está asociado a una fuerza de Porter. La UI se adapta según
/// la orientación del dispositivo y se asegura que los barcos solo se coloquen
/// en posiciones válidas.
/// ---------------------------------------------------------------------------

library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'barco.dart';
import 'image_paths.dart';
import 'tablero.dart';

class SetupGame extends FlameGame {
  // ---------------------------------------------------------------------------
  // Referencias principales
  // ---------------------------------------------------------------------------

  late final Tablero tablero;
  final List<Barco> barcosEnTablero = [];

  // ---------------------------------------------------------------------------
  // Configuración de layout y escalado
  // ---------------------------------------------------------------------------

  static const double _margen = 20;
  static const double _espacioExtra = 50;

  static const double _escalaBarco = 0.8;
  static const double _separacionBarcos = 10;

  static const double _tamanioCelda = 25.0;
  static const int _filas = 12;
  static const int _columnas = 12;

  late final bool esVertical;

  // ---------------------------------------------------------------------------
  // Color de fondo transparente
  // ---------------------------------------------------------------------------

  @override
  Color backgroundColor() => const Color(0x00000000);

  // ---------------------------------------------------------------------------
  // Ciclo de carga
  // ---------------------------------------------------------------------------

  @override
  Future<void> onLoad() async {
    super.onLoad();

    esVertical = size.y >= size.x;

    await _cargarImagenesBarcos();

    final Vector2 sizeTablero = Vector2.all(_tamanioCelda * 12);
    final Vector2 posicionTablero =
        esVertical
            ? Vector2((size.x - sizeTablero.x) / 3, _margen)
            : Vector2(_margen + 150, (size.y - sizeTablero.y) / 2 + 50);

    _agregarTablero(posicionTablero, sizeTablero);
    _agregarBarcos(posicionTablero, sizeTablero);
  }
  // ---------------------------------------------------------------------------
  // Precarga de imágenes
  // ---------------------------------------------------------------------------

  Future<void> _cargarImagenesBarcos() async {
    final todasLasRutas = ImagePaths.todosLosSpritesPorDireccion.values.expand(
      (mapa) => mapa.values,
    );
    await Future.wait(todasLasRutas.map((ruta) => images.load(ruta)));
  }
  // ---------------------------------------------------------------------------
  // Tablero de juego
  // ---------------------------------------------------------------------------

  void _agregarTablero(Vector2 posicion, Vector2 size) {
    tablero = Tablero(
      position: posicion,
      size: size,
      tamanioCelda: _tamanioCelda,
      filas: _filas,
      columnas: _columnas,
    );
    add(tablero);
  }

  // ---------------------------------------------------------------------------
  // Barcos (usando un solo componente visual por barco)
  // ---------------------------------------------------------------------------
  void _agregarBarcos(Vector2 posicionTablero, Vector2 sizeTablero) {
    final double anchoDisponible = size.x - _margen * 2;

    final double anchoBarcoAprox = _tamanioCelda * 2.5;
    final double altoBarcoAprox = _tamanioCelda * 2.5;

    final int barcosPorFila = (anchoDisponible ~/ (anchoBarcoAprox + _separacionBarcos)).clamp(
      1,
      5,
    );

    final double offsetBaseX = _margen;
    final double offsetBaseY = posicionTablero.y + sizeTablero.y + _espacioExtra;

    final List<(String id, int longitud)> barcosData = [
      ('1', 1),
      ('2', 2),
      ('3', 3),
      ('4', 4),
      ('5', 5),
    ];

    for (int i = 0; i < barcosData.length; i++) {
      final (id, longitud) = barcosData[i];

      final int fila = i ~/ barcosPorFila;
      final int columna = i % barcosPorFila;

      final double posX = offsetBaseX + columna * (anchoBarcoAprox + _separacionBarcos);
      final double posY = offsetBaseY + fila * (altoBarcoAprox + _separacionBarcos + 10);

      final Vector2 posicionBarcoAlmacen = Vector2(posX, posY);

      final Barco barcoAlmacen = Barco(
        id: id,
        longitud: longitud,
        rutasSprites: ImagePaths.todosLosSpritesPorDireccion[id]!,
        posicionInicial: posicionBarcoAlmacen,
        escala: _escalaBarco,
        onPosicionCambiada: (nuevaPosicion) {},
        onBarcoColocadoEnTablero: (barco) {
          final gridPosition = tablero.worldToGrid(barco.position);
          if (tablero.esPosicionValida(gridPosition, barco.longitud, barco.esVertical)) {
            tablero.agregarBarco(barco, gridPosition, barco.esVertical);
            barcosEnTablero.add(barco);
            barco.onBarcoColocadoEnTablero = null;
            barco.validarColocacion = null;
          } else {
            barco.removeFromParent();
            barcosEnTablero.remove(barco);
          }
        },
        validarColocacion: (barco) {
          final gridPosition = tablero.worldToGrid(barco.position);
          return tablero.esPosicionValida(gridPosition, barco.longitud, barco.esVertical);
        },
      );

      add(barcoAlmacen..priority = 1);
    }
  }
}
