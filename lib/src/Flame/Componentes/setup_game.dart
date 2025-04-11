/// ---------------------------------------------------------------------------
/// `SetupGame` - Vista de configuración del juego basada en FlameGame.
/// ---------------------------------------------------------------------------
/// Este componente permite a los usuarios colocar barcos sobre un tablero 12x12.
/// Los barcos representan fuerzas de Porter, y su colocación se valida para evitar
/// solapamientos o ubicaciones fuera de los límites.
/// ---------------------------------------------------------------------------

library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'almacen_barco.dart';
import 'barco.dart';
import 'image_paths.dart';
import 'tablero.dart';

class SetupGame extends FlameGame {
  // ---------------------------------------------------------------------------
  // 🔧 Configuración de tablero y layout general
  // ---------------------------------------------------------------------------

  static const double _margen = 20;
  static const double _espacioExtra = 50;

  static const double _tamanioCelda = 25.0;
  static const int _filas = 12;
  static const int _columnas = 12;

  static const double _escalaBarco = 0.8;
  static const double _separacionBarcos = 50;

  late final bool esVertical;

  // ---------------------------------------------------------------------------
  // 🔗 Referencias a componentes clave
  // ---------------------------------------------------------------------------

  late final Tablero tablero;
  late final AlmacenBarco almacenBarco;

  final List<Barco> barcosEnTablero = [];

  // ---------------------------------------------------------------------------
  // 🎨 Color de fondo (transparente para overlay sobre UI nativa)
  // ---------------------------------------------------------------------------

  @override
  Color backgroundColor() => const Color(0x00000000);

  // ---------------------------------------------------------------------------
  // 🚀 Ciclo de carga principal del juego
  // ---------------------------------------------------------------------------

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    esVertical = size.y >= size.x;

    await _precargarSprites();

    _crearTablero();
    _crearAlmacenBarcos();
  }

  // ---------------------------------------------------------------------------
  // 🖼 Precarga de todos los sprites necesarios
  // ---------------------------------------------------------------------------

  Future<void> _precargarSprites() async {
    final rutas = ImagePaths.todosLosSpritesPorDireccion.values.expand((mapa) => mapa.values);
    await Future.wait(rutas.map(images.load));
  }

  // ---------------------------------------------------------------------------
  // 🎯 Crea y posiciona el tablero central de juego
  // ---------------------------------------------------------------------------

  void _crearTablero() {
    final Vector2 sizeTablero = Vector2.all(_tamanioCelda * _filas);
    final Vector2 posicionTablero =
        esVertical
            ? Vector2((size.x - sizeTablero.x) / 3, _margen)
            : Vector2(_margen + 150, (size.y - sizeTablero.y) / 2 + 50);

    tablero = Tablero(
      filas: _filas,
      columnas: _columnas,
      tamanioCelda: _tamanioCelda,
      position: posicionTablero,
      size: sizeTablero,
    );

    add(tablero);
  }

  // ---------------------------------------------------------------------------
  // 🧱 Crea el almacén lateral/inferior donde están los barcos iniciales
  // ---------------------------------------------------------------------------

  void _crearAlmacenBarcos() {
    final List<(String id, int longitud)> barcosDisponibles = [
      ('1', 1),
      ('2', 2),
      ('3', 3),
      ('4', 4),
      ('5', 5),
    ];

    final List<Barco> barcosIniciales = [];

    for (final (id, longitud) in barcosDisponibles) {
      final barco = Barco(
        id: id,
        longitud: longitud,
        rutasSprites: ImagePaths.todosLosSpritesPorDireccion[id]!,
        posicionInicial: Vector2.zero(),
        escala: _escalaBarco,
        onPosicionCambiada: (nuevaPos) {},
        onBarcoColocadoEnTablero: (barco) {
          final gridPos = tablero.worldToGrid(barco.position);

          if (tablero.esPosicionValida(gridPos, barco.longitud, barco.esVertical)) {
            tablero.agregarBarco(barco, gridPos, barco.esVertical);
            barcosEnTablero.add(barco);
            barco.onBarcoColocadoEnTablero = null;
            barco.validarColocacion = null;
          } else {
            barco.removeFromParent();
            barcosEnTablero.remove(barco);
          }
        },
        validarColocacion: (barco) {
          final gridPos = tablero.worldToGrid(barco.position);
          return tablero.esPosicionValida(gridPos, barco.longitud, barco.esVertical);
        },
      );

      barcosIniciales.add(barco);
    }

    final double anchoAlmacen = size.x - _margen * 2;
    final double posX = _margen;
    final double posY = tablero.position.y + tablero.size.y + _espacioExtra;

    // 🔥 Altura provisional, puedes calcularla dinámicamente si prefieres
    const double alturaAlmacen = 100;

    almacenBarco = AlmacenBarco(
      barcosIniciales: barcosIniciales,
      position: Vector2(posX, posY),
      size: Vector2(anchoAlmacen, alturaAlmacen),
      espacioEntreBarcos: _separacionBarcos,
    );

    add(almacenBarco);
  }
}
