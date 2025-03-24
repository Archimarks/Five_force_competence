/// *************************************************
/// * Archivo: color_equipo.dart
/// * Descripción: Definición centralizada de la paleta de colores para los equipos.
/// * Proyecto: Five Force Competence
/// * Autores: Marcos Alejandro Collazos Marmolejo
/// * Fecha: 24/03/2025
/// *************************************************
library;

import 'package:flutter/material.dart';

/// Enumerador de colores principales de la aplicación.
enum AppColorEquipo {
  amarillo,
  azul,
  cyan,
  naranja,
  verde;

  /// Obtiene el color principal correspondiente.
  /// Si el color no existe en el mapa, devuelve un color de respaldo (negro en este caso).
  Color get value => AppPalette.colorMap[this] ?? Colors.black;

  /// Obtiene el color asociado a cada equipo
  Color get color => AppPalette.colorMap[this]!;
}

/// Clase que contiene la paleta de colores asociada a los equipos.
class AppPalette {
  /// Mapeo de colores para cada equipo.
  static const Map<AppColorEquipo, Color> colorMap = {
    AppColorEquipo.amarillo: Colors.amber, // Amarillo real
    AppColorEquipo.azul: Colors.blue,
    AppColorEquipo.cyan: Colors.cyan,
    AppColorEquipo.naranja: Colors.deepOrange,
    AppColorEquipo.verde: Colors.greenAccent,
  };
}
