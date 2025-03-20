import 'package:flutter/material.dart';

enum ButtonColor { azulClaro, azul, azulOscuro, verde }

extension ButtonColorExtension on ButtonColor {
  Color get value {
    switch (this) {
      case ButtonColor.azulClaro:
        return const Color.fromARGB(255, 48, 85, 117);
      case ButtonColor.azul:
        return const Color.fromARGB(255, 3, 43, 104);
      case ButtonColor.azulOscuro:
        return const Color.fromARGB(255, 27, 38, 54);
      case ButtonColor.verde:
        return const Color.fromARGB(255, 27, 54, 44);
    }
  }

  Color get glowColor {
    switch (this) {
      case ButtonColor.azulClaro:
        return const Color.fromARGB(255, 150, 225, 255).withAlpha((0.6 * 255).toInt());
      case ButtonColor.azul:
        return const Color.fromARGB(255, 150, 225, 255).withAlpha((0.6 * 255).toInt());
      case ButtonColor.azulOscuro:
        return const Color.fromARGB(255, 150, 225, 255).withAlpha((0.6 * 255).toInt());
      case ButtonColor.verde:
        return const Color.fromARGB(255, 150, 255, 185).withAlpha((0.6 * 255).toInt());
    }
  }
}

class Button extends StatelessWidget {
  final String texto;
  final ButtonColor color;
  final VoidCallback onPressed;

  const Button({super.key, required this.texto, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: color.glowColor, blurRadius: 15, spreadRadius: 3)],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.value,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
