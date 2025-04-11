import 'package:flame/components.dart';

import 'direccion.dart';

/// Componente visual que representa un barco con sprites separados por dirección.
class SpritesBarco extends SpriteComponent {
  /// Mapa de direcciones a sus respectivos sprites
  final Map<Direccion, Sprite> _sprites = {};

  /// Dirección actual mostrada
  Direccion direccionActual;

  /// Constructor del componente visual del barco
  SpritesBarco({
    required Map<String, String> rutasSprites,
    required this.direccionActual,
    required Vector2 tamano,
  }) : super(size: tamano, anchor: Anchor.topLeft) {
    _cargarSprites(rutasSprites);
  }

  Future<void> _cargarSprites(Map<String, String> rutas) async {
    _sprites[Direccion.arriba] = await Sprite.load(rutas['arriba']!);
    _sprites[Direccion.derecha] = await Sprite.load(rutas['derecha']!);
    _sprites[Direccion.abajo] = await Sprite.load(rutas['abajo']!);
    _sprites[Direccion.izquierda] = await Sprite.load(rutas['izquierda']!);

    sprite = _sprites[direccionActual];

    // Ajusta el tamaño al sprite original
    size = sprite!.originalSize;
  }

  /// Cambia el sprite actual según la nueva dirección
  void cambiarDireccion(Direccion nuevaDireccion) {
    direccionActual = nuevaDireccion;
    sprite = _sprites[direccionActual];
  }
}
