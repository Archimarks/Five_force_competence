import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../Flame/Componentes/setup_game.dart';
import '../../Global/Widgets/app_bar.dart';

/// Nombre del equipo, cargado desde SharedPreferences.
String nombreEquipo = '';

/// Color del equipo, cargado desde SharedPreferences y convertido desde enum.
Color colorEquipo = Colors.black;

/// ID de la partida actual.
String? partidaId;

/// Nombre del equipo actual (clave en Firebase).
String? equipo;

/// Vista que permite organizar las edificaciones antes de la batalla.
/// Contiene el juego con Flame, encabezado personalizado, instrucciones,
/// y botón para iniciar la batalla.
class SetupGameView extends StatelessWidget {
  final SetupGame game = SetupGame();

  SetupGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB2D7E7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: customAppBar(context: context, title: nombreEquipo, backgroundColor: colorEquipo),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Título principal
              const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  'Organiza tus edificaciones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B33),
                  ),
                ),
              ),

              // Sección de juego Flame (expande a lo restante)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GameWidget(game: game),
                ),
              ),

              // Botón "¡A la batalla!"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C1B1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      // TODO: Acción al presionar el botón
                    },
                    child: const Text('¡A la batalla!', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
