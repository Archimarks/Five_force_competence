/// image_component.dart
///
/// Contiene dos componentes visuales para Flame:
/// - `ImagenComponente`: Componente de imagen genérico que renderiza un sprite.
/// - `ImagenBoton`: Extiende `ImagenComponente` e incluye una funcionalidad de botón táctil.
library;

import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'setup_game.dart';

/// Componente visual para mostrar una imagen (sprite) en pantalla.
///
/// Este componente permite especificar un sprite completo o una sección de una imagen,
/// con soporte para escalado, posición personalizada y ratio de aspecto.
///
/// [imagePath] es la ruta del recurso.
/// [srcSize] y [srcPosition] permiten recortar una sección específica del sprite.
/// [imageSize] determina el tamaño de renderizado final.
///
/// El sprite se carga en `onLoad()` usando `gameRef.images`.
class ImagenComponente extends PositionComponent with HasGameRef<SetupGame> {
  late Sprite image;

  /// Define si el sprite debe ser renderizado o no.
  bool shouldRender = true;

  /// Ruta al recurso de imagen.
  String imagePath = '';

  /// Posición de recorte dentro del sprite (en píxeles).
  Vector2 srcPosition = Vector2.zero();

  /// Tamaño del recorte dentro del sprite (en píxeles).
  Vector2 srcSize = Vector2.zero();

  /// Relación de aspecto calculada a partir del sprite recortado.
  double _aspectRatio = 0;
  double get aspectRatio => _aspectRatio;

  ImagenComponente({
    required Vector2? imageSize,
    required String? imagePath,
    Vector2? position,
    Vector2? srcSize,
    Vector2? srcPosition,
  }) : super(position: position ?? Vector2.zero(), size: imageSize ?? Vector2.zero()) {
    this.imagePath = imagePath ?? '';
    this.srcSize = srcSize ?? Vector2.zero();
    this.srcPosition = srcPosition ?? Vector2.zero();

    if (this.srcSize.y > 0) {
      _aspectRatio = this.srcSize.x / this.srcSize.y;
    }
  }

  @override
  Future<void> onLoad() async {
    image = await Sprite.load(
      imagePath,
      srcSize: srcSize == Vector2.zero() ? null : srcSize,
      srcPosition: srcPosition == Vector2.zero() ? null : srcPosition,
      images: gameRef.images,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (shouldRender) {
      image.render(canvas, position: Vector2.zero(), size: size);
    }
  }
}

/// Componente de imagen que actúa como un botón táctil.
///
/// Extiende [ImagenComponente] y añade la capacidad de detectar toques.
/// Permite asignar una función [onTap] que se ejecutará al presionar el botón.
class ImagenBoton extends ImagenComponente with TapCallbacks {
  /// Callback que se ejecuta cuando el botón es presionado.
  void Function()? onTapCallback;

  ImagenBoton({
    required super.imageSize,
    required super.imagePath,
    super.position,
    super.srcSize,
    super.srcPosition,
    void Function()? onTap,
  }) {
    if (onTap != null) {
      onTapCallback = onTap;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTapCallback?.call();
  }
}
