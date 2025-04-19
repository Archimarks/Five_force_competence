import 'package:flutter/material.dart';

/// *************************************************
/// * Archivo: color.dart
/// * Descripción: Definición centralizada de la paleta de colores.
/// * Proyecto: Five Force Competence
/// * Autores: Marcos Alejandro Collazos Marmolejo
/// * Fecha: [Fecha de creación]
/// *************************************************

/// Enumerador de colores principales de la aplicación.
enum AppColor {
  azulGris,
  azulReal,
  gris,
  platino,
  azulIntenso,
  azulOxford,
  verdeBosque,
  azulAcero;

  /// Obtiene el color principal correspondiente.
  Color get value => AppPalette._colorMap[this]!;

  /// Obtiene el color de sombra/brillo asociado.
  Color get glowColor => AppPalette._glowMap[this]!;
}

class AppPalette {
  static const Map<AppColor, Color> _colorMap = {
    AppColor.azulGris: Color.fromARGB(255, 48, 85, 117),
    AppColor.azulReal: Color.fromARGB(255, 3, 42, 103),
    AppColor.gris: Color.fromARGB(255, 129, 132, 121),
    AppColor.platino: Color.fromARGB(255, 217, 217, 217),
    AppColor.azulIntenso: Color.fromARGB(255, 14, 26, 38),
    AppColor.azulOxford: Color.fromARGB(255, 18, 33, 63),
    AppColor.verdeBosque: Color.fromARGB(255, 5, 96, 17),
    AppColor.azulAcero: Color.fromARGB(255, 61, 105, 130),
  };

  static Color _applyGlow(Color baseColor) {
    // ignore: deprecated_member_use
    return baseColor.withOpacity(0.6); // Genera automáticamente el color con brillo
  }

  static final Map<AppColor, Color> _glowMap = {for (var entry in _colorMap.entries) entry.key: _applyGlow(entry.value)};
}
