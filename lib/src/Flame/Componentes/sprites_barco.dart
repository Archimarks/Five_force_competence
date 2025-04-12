import 'package:flame/components.dart';

import 'direccion.dart';

/// Componente visual que representa un barco con sprites separados por dirección.
class SpritesBarco extends SpriteComponent {
  /// Mapa de direcciones a sus respectivos sprites
  final Map<Direccion, Sprite> sprites = {};

  /// Dirección actual mostrada
  Direccion direccionActual;

  /// Constructor del componente visual del barco
  SpritesBarco({
    required Map<String, String> rutasSprites,
    required this.direccionActual,
    required Vector2 tamano,
  }) : super(size: tamano, anchor: Anchor.topLeft) {
    _cargarSprites(rutasSprites, tamano); // Pasa el tamaño al cargar los sprites
  }

  Future<void> _cargarSprites(Map<String, String> rutas, Vector2 tamano) async {
    sprites[Direccion.arriba] = await Sprite.load(rutas['arriba']!);
    sprites[Direccion.derecha] = await Sprite.load(rutas['derecha']!);
    sprites[Direccion.abajo] = await Sprite.load(rutas['abajo']!);
    sprites[Direccion.izquierda] = await Sprite.load(rutas['izquierda']!);

    sprite = sprites[direccionActual];

    // Establece el tamaño al valor proporcionado en el constructor
    size = tamano;
  }

  /// Cambia el sprite actual según la nueva dirección
  void cambiarDireccion(Direccion nuevaDireccion) {
    direccionActual = nuevaDireccion;
    sprite = sprites[direccionActual];
  }
}
