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
  azulClaro,
  azul,
  azulOscuro,
  verde;

  /// Obtiene el color principal correspondiente.
  Color get value => AppPalette._colorMap[this]!;

  /// Obtiene el color de sombra/brillo asociado.
  Color get glowColor => AppPalette._glowMap[this]!;
}

class AppPalette {
  static const Map<AppColor, Color> _colorMap = {
    AppColor.azulClaro: Color(0xFF305575),
    AppColor.azul: Color(0xFF032B68),
    AppColor.azulOscuro: Color(0xFF1B2636),
    AppColor.verde: Color(0xFF1B362C),
  };

  static Color _applyGlow(Color baseColor) {
    // ignore: deprecated_member_use
    return baseColor.withOpacity(0.6); // Genera automáticamente el color con brillo
  }

  static final Map<AppColor, Color> _glowMap = {
    for (var entry in _colorMap.entries) entry.key: _applyGlow(entry.value),
  };
}
