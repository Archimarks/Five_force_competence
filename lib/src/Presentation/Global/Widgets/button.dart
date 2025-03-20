import 'package:flutter/material.dart';

import '../Color/color.dart'; // Importa la clase AppColor

/// *************************************************
/// * Widget: Button
/// * Descripción: Botón reutilizable con sombra y estilos personalizados.
/// * Proyecto: Five Force Competence
/// * Autores: Marcos Alejandro Collazos Marmolejo
/// * Fecha: [Fecha de creación]
/// *************************************************

class Button extends StatelessWidget {
  final String texto;
  final AppColor color;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double borderRadius;

  const Button({
    super.key,
    required this.texto,
    required this.color,
    required this.onPressed,
    this.width = 250,
    this.height = 50,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: color.glowColor, blurRadius: 15, spreadRadius: 3)],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: _buttonStyle(),
        child: Semantics(
          label: texto, // Mejora accesibilidad
          child: Text(
            texto,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Método para centralizar el estilo del botón y mejorar la modularidad.
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: color.value,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
    );
  }
}
