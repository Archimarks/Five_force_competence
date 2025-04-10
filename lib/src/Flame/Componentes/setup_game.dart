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

    // Precarga de imágenes necesarias
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
    await Future.wait(ImagePaths.todosLosBarcos.map((ruta) => images.load(ruta)));
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
    final double offsetBaseVertical = posicionTablero.y + sizeTablero.y + _espacioExtra;
    final double offsetBaseHorizontal = _margen;
    final double separacionVertical = _tamanioCelda * 1 + _separacionBarcos;
    final double separacionHorizontal = _tamanioCelda * 2 + _separacionBarcos * 2;

    final List<(String, String, int)> barcosData = [
      ('1', ImagePaths.barco1, 1),
      ('2', ImagePaths.barco2, 2),
      ('3', ImagePaths.barco3, 3),
      ('4', ImagePaths.barco4, 4),
      ('5', ImagePaths.barco5, 5),
    ];

    for (int i = 0; i < barcosData.length; i++) {
      final (id, imageUrl, sizeEnCeldas) = barcosData[i];

      final Vector2 posicionBarcoAlmacen =
          esVertical
              ? Vector2(_margen + i * separacionHorizontal, offsetBaseVertical)
              : Vector2(offsetBaseHorizontal, _margen + i * separacionVertical + 100);

      final Barco barcoAlmacen = Barco(
        id: id,
        longitud: sizeEnCeldas,
        imageUrl: imageUrl, // Pasa la URL de la imagen al Barco
        posicionInicial: posicionBarcoAlmacen,
        escala: _escalaBarco,
        onPosicionCambiada: (nuevaPosicion) {
          // Opcional: Retroalimentación visual durante el arrastre
        },
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
        seccionSprite: posicionBarcoAlmacen,
      );

      add(barcoAlmacen..priority = 1);
    }
  }
}
