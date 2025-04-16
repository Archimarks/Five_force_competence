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

import 'barco.dart';
import 'image_paths.dart';
import 'tablero_estrategia.dart'; // Importa la nueva clase combinada

/// Escena principal donde los jugadores configuran sus unidades estratégicas
/// antes de iniciar el juego. Se compone de un `TableroEstrategia` interactivo.
class SetupGame extends FlameGame {
  // ===========================================================================
  // ⚙️ PARÁMETROS DE CONFIGURACIÓN GENERAL
  // ===========================================================================

  static const double _margen = 5;

  static const double _tamanioCelda = 27;
  static const int _filas = 12;
  static const int _columnas = 12;

  static const double _separacionBarcos = 70;

  late final bool esVertical; // Determina orientación del dispositivo

  // ===========================================================================
  // 🧩 COMPONENTES DEL JUEGO
  // ===========================================================================

  late final TableroEstrategia tableroEstrategia;

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
    _crearTableroEstrategia();
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
  // 🔲 TABLERO ESTRATEGIA - Creación y Posicionamiento
  // ===========================================================================

  /// Crea el componente principal que gestiona el tablero y el almacén de barcos.
  void _crearTableroEstrategia() {
    final sizeTablero = Vector2.all(_tamanioCelda * _filas);
    final posicionTablero = esVertical ? Vector2((size.x - sizeTablero.x) / 10, _margen) : Vector2(_margen + 150, (size.y - sizeTablero.y) / 2);

    final datosBarcosIniciales = <Map<String, dynamic>>[
      {'id': '5', 'longitud': 5, 'sprites': ImagePaths.todosLosSpritesPorDireccion['5']!},
      {'id': '4', 'longitud': 4, 'sprites': ImagePaths.todosLosSpritesPorDireccion['4']!},
      {'id': '3', 'longitud': 3, 'sprites': ImagePaths.todosLosSpritesPorDireccion['3']!},
      {'id': '2', 'longitud': 2, 'sprites': ImagePaths.todosLosSpritesPorDireccion['2']!},
      {'id': '1', 'longitud': 1, 'sprites': ImagePaths.todosLosSpritesPorDireccion['1']!},
    ];

    tableroEstrategia = TableroEstrategia(
      filas: _filas,
      columnas: _columnas,
      tamanioCelda: _tamanioCelda,
      datosBarcosIniciales: datosBarcosIniciales,
      espacioEntreBarcos: _separacionBarcos,
      position: posicionTablero,
      size: Vector2(sizeTablero.x, sizeTablero.y), // Ajusta el tamaño del componente combinado
    );

    add(tableroEstrategia);
  }
}
