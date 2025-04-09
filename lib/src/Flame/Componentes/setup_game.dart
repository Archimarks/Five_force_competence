/// ---------------------------------------------------------------------------
/// `SetupGame` - Vista de configuración del juego basada en FlameGame.
/// ---------------------------------------------------------------------------
/// Permite a los usuarios colocar barcos (edificaciones) en un tablero 12x12.
/// Cada barco está asociado a una fuerza de Porter. La UI se adapta según
/// la orientación del dispositivo y se asegura que los barcos solo se coloquen
/// en posiciones válidas.
/// ---------------------------------------------------------------------------

library;

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'barco.dart';
import 'barco_almacen.dart';
import 'image_paths.dart';
import 'tablero.dart';

class SetupGame extends FlameGame {
  // ---------------------------------------------------------------------------
  // Referencias principales
  // ---------------------------------------------------------------------------

  late final Tablero tablero;
  final List<BarcoAlmacen> barcosAlmacen = [];
  final List<Barco> barcosEnTablero = [];

  // ---------------------------------------------------------------------------
  // Configuración de layout y escalado
  // ---------------------------------------------------------------------------

  static const double _margen = 20;
  static const double _separacionBarcos = 10;
  static const double _escalaBarco = 10;
  static const double _espacioExtra = 30;

  late final bool esVertical;

  // ---------------------------------------------------------------------------
  // Ciclo de carga
  // ---------------------------------------------------------------------------

  @override
  Future<void> onLoad() async {
    super.onLoad();

    esVertical = size.y >= size.x;

    // Precarga de imágenes necesarias
    await _cargarImagenesBarcos();

    final Vector2 sizeTablero = Vector2.all(20.0 * 12);
    final Vector2 posicionTablero =
        esVertical
            ? Vector2((size.x - sizeTablero.x) / 2, _margen)
            : Vector2(_margen + 130, (size.y - sizeTablero.y) / 2);

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
    tablero = Tablero(position: posicion, size: size);
    add(tablero);
  }

  // ---------------------------------------------------------------------------
  // Barcos (usando imágenes individuales por barco)
  // ---------------------------------------------------------------------------

  void _agregarBarcos(Vector2 posicionTablero, Vector2 sizeTablero) {
    final double qSize = sizeTablero.x / 12;
    final double offsetBase =
        esVertical ? posicionTablero.y + sizeTablero.y + _espacioExtra : _margen;

    final List<(String, String, int)> barcos = [
      ('1', ImagePaths.barco1, 1),
      ('2', ImagePaths.barco2, 2),
      ('3', ImagePaths.barco3, 3),
      ('4', ImagePaths.barco4, 4),
      ('5', ImagePaths.barco5, 5),
    ];

    for (int i = 0; i < barcos.length; i++) {
      final (id, imageUrl, sizeEnCeldas) = barcos[i];

      final Vector2 posicion =
          esVertical
              ? Vector2(_margen + i * (qSize * 2), offsetBase)
              : Vector2(_margen, offsetBase + i * (qSize * sizeEnCeldas + _separacionBarcos));

      _crearBarco(
        id: id,
        imageUrl: imageUrl,
        sizeEnCeldas: sizeEnCeldas,
        posicion: posicion,
        qSize: qSize,
      );
    }
  }

  void _crearBarco({
    required String id,
    required String imageUrl,
    required int sizeEnCeldas,
    required Vector2 posicion,
    required double qSize,
  }) {
    final sprite = Sprite(images.fromCache(imageUrl));

    final barco = BarcoAlmacen(
      id: id,
      longitud: sizeEnCeldas,
      spriteHorizontal: sprite,
      spriteVertical: sprite,
      posicionInicial: posicion,
      escala: _escalaBarco,
      onBarcoArrastradoAlTablero: _onBarcoArrastradoAlTablero,
    );

    barcosAlmacen.add(barco);
    add(barco);
  }

  // ---------------------------------------------------------------------------
  // Lógica de colocación de barcos
  // ---------------------------------------------------------------------------

  void _onBarcoArrastradoAlTablero(Barco barco) {
    final Vector2 gridPosition = tablero.worldToGrid(barco.position);

    if (tablero.esPosicionValida(gridPosition, barco.longitud, barco.esVertical)) {
      barco.position = tablero.gridToWorld(gridPosition);
      tablero.add(barco);
      barcosEnTablero.add(barco);
    } else {
      barco.removeFromParent(); // Elimina el barco si se soltó en una celda inválida
    }
  }
}
