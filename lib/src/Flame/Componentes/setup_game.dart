import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

import 'barco.dart';
import 'barco_almacen.dart';
import 'fuerza.dart';
import 'tablero.dart';

/// ---------------------------------------------------------------------------
/// Pantalla de configuración del juego (`SetupGame`)
/// ---------------------------------------------------------------------------
/// Esta clase extiende `FlameGame` y se encarga de cargar el tablero de juego
/// junto con los barcos disponibles en el "almacén", permitiendo su arrastre
/// y colocación en el tablero según las reglas de validez definidas.
///
/// Cada barco representa una de las cinco fuerzas de Porter.
/// ---------------------------------------------------------------------------
class SetupGame extends FlameGame {
  late final Tablero tablero;
  final List<BarcoAlmacen> barcosAlmacen = [];
  final List<Barco> barcosEnTablero = [];

  static const double paddingInicialX = 20;
  static const double paddingInicialY = 100;
  static const double separacionBarcos = 60;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Crear el tablero y añadirlo al juego
    tablero = Tablero(
      position: Vector2(50, 50),
      size: Vector2(Tablero.tamanioCelda * 12, Tablero.tamanioCelda * 12),
    );
    add(tablero);

    // Cargar los sprites de los barcos
    final barcosImage = await images.load('ship_2.png');
    final barcosSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: barcosImage,
      columns: 1,
      rows: Fuerza.values.length,
    );

    // Crear los barcos en el "almacén"
    for (int i = 0; i < Fuerza.values.length; i++) {
      final fuerza = Fuerza.values[i];
      final sprite = barcosSpriteSheet.getSprite(0, i);

      final barcoAlmacen = BarcoAlmacen(
        longitud: fuerza.longitudBarco,
        spriteHorizontal: sprite,
        spriteVertical: sprite, // Por ahora, ambos iguales
        posicionInicial: Vector2(paddingInicialX, paddingInicialY + i * separacionBarcos),
        onBarcoArrastradoAlTablero: _onBarcoArrastradoAlTablero,
      );

      barcosAlmacen.add(barcoAlmacen);
      add(barcoAlmacen);
    }
  }

  /// Lógica que se ejecuta cuando un barco es arrastrado al tablero.
  /// Verifica si la posición es válida, y si lo es, lo fija en el tablero.
  void _onBarcoArrastradoAlTablero(Barco barco) {
    final gridPosition = tablero.worldToGrid(barco.position);

    if (tablero.esPosicionValida(gridPosition, barco.longitud, barco.esVertical)) {
      barco.position = tablero.gridToWorld(gridPosition);
      tablero.add(barco);
      barcosEnTablero.add(barco);
    } else {
      barco.removeFromParent(); // Posición inválida: se descarta
    }
  }
}
