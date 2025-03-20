import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final String texto;

  const TitleWidget({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    double fontSize = _getFontSize(texto);

    return Text(
      texto,
      style: TextStyle(
        fontSize: fontSize, // Aplicamos el tamaño de fuente dinámico
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      textAlign: TextAlign.center,
    );
  }

  double _getFontSize(String texto) {
    // Si el texto tiene más de 20 caracteres, reducimos el tamaño del texto
    if (texto.length > 30) {
      return 18.0; // Texto largo, tamaño de fuente más pequeño
    } else if (texto.length > 20) {
      return 20.0; // Texto medio, tamaño de fuente intermedio
    } else {
      return 24.0; // Texto corto, tamaño de fuente más grande
    }
  }
}
