/// ---------------------------------------------------------------------------
/// `SetupGame` - Escena de configuración inicial del juego basada en FlameGame
/// ---------------------------------------------------------------------------
/// Esta escena permite a los jugadores organizar barcos dentro de un tablero
/// 12x12. Cada barco representa una fuerza competitiva (modelo de Porter),
/// y debe colocarse estratégicamente evitando solapamientos o límites.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'almacen_barco.dart';
import 'barco.dart';
import 'image_paths.dart';
import 'tablero.dart';

/// Escena principal donde los jugadores configuran sus unidades estratégicas
/// antes de iniciar el juego. Se compone de un `Tablero` interactivo y un
/// `AlmacenBarco` desde donde los barcos son arrastrados y colocados.
class SetupGame extends FlameGame {
  // ===========================================================================
  // ⚙️ PARÁMETROS DE CONFIGURACIÓN GENERAL
  // ===========================================================================

  static const double _margen = 20;
  static const double _espacioExtra = 50;

  static const double _tamanioCelda = 25.0;
  static const int _filas = 12;
  static const int _columnas = 12;

  static const double _escalaBarco = 0.8;
  static const double _separacionBarcos = 50;

  late final bool esVertical; // Determina orientación del dispositivo

  // ===========================================================================
  // 🧩 COMPONENTES DEL JUEGO
  // ===========================================================================

  late final Tablero tablero;
  late final AlmacenBarco almacenBarco;

  /// Lista de barcos colocados correctamente sobre el tablero.
  final List<Barco> barcosEnTablero = [];

  // ===========================================================================
  // 🎨 ESTILO VISUAL
  // ===========================================================================

  /// Define color de fondo transparente para permitir overlays nativos.
  @override
  Color backgroundColor() => const Color(0x00000000);

  // ===========================================================================
  // 🚀 CICLO DE VIDA - CARGA INICIAL
  // ===========================================================================

  /// Inicializa todos los componentes principales al cargar la escena.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    esVertical = size.y >= size.x;

    await _precargarSprites();
    _crearTablero();
    _crearAlmacenBarcos();
  }

  // ===========================================================================
  // 📦 SPRITES - Precarga
  // ===========================================================================

  /// Carga anticipadamente todos los sprites necesarios para los barcos.
  Future<void> _precargarSprites() async {
    final rutas = ImagePaths.todosLosSpritesPorDireccion.values.expand((mapa) => mapa.values);
    await Future.wait(rutas.map(images.load));
  }

  // ===========================================================================
  // 🔲 TABLERO - Creación y Posicionamiento
  // ===========================================================================

  /// Crea el tablero principal donde se colocan los barcos.
  void _crearTablero() {
    final sizeTablero = Vector2.all(_tamanioCelda * _filas);
    final posicionTablero =
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

  // ===========================================================================
  // ⚓ ALMACÉN DE BARCOS - Configuración Inicial
  // ===========================================================================

  /// Crea el componente visual que contiene los barcos disponibles al jugador.
  void _crearAlmacenBarcos() {
    final barcosDisponibles = <(String id, int longitud)>[
      ('1', 1),
      ('2', 2),
      ('3', 3),
      ('4', 4),
      ('5', 5),
    ];

    final List<Barco> barcosIniciales = [];

    // Genera instancias de barcos con sus respectivos callbacks
    for (final (id, longitud) in barcosDisponibles) {
      final barco = Barco(
        id: id,
        longitud: longitud,
        rutasSprites: ImagePaths.todosLosSpritesPorDireccion[id]!,
        posicionInicial: Vector2.zero(),
        escala: _escalaBarco,
        onPosicionCambiada: (_) {}, // Se puede usar para animaciones o feedback
        onBarcoColocadoEnTablero: (barco) {
          final gridPos = tablero.worldToGrid(barco.position);

          // Verifica si la posición es válida antes de fijarlo
          if (tablero.esPosicionValida(gridPos, barco.longitud, barco.esVertical)) {
            tablero.agregarBarco(barco, gridPos, barco.esVertical);
            barcosEnTablero.add(barco);

            // Limpia callbacks innecesarios tras colocación definitiva
            barco.onBarcoColocadoEnTablero = null;
            barco.validarColocacion = null;
          } else {
            // Remueve el barco si la posición no es válida
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

    // Calcula la posición y tamaño del almacén
    final double anchoAlmacen = size.x - _margen * 2;
    final double posX = _margen;
    final double posY = tablero.position.y + tablero.size.y + _espacioExtra;

    // Altura fija, ajustable si se desea hacerlo dinámico
    const double alturaAlmacen = 150;

    almacenBarco = AlmacenBarco(
      barcosIniciales: barcosIniciales,
      position: Vector2(posX, posY),
      size: Vector2(anchoAlmacen, alturaAlmacen),
      espacioEntreBarcos: _separacionBarcos,
    );

    add(almacenBarco);
  }
}
