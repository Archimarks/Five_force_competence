import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Flame/Componentes/setup_game.dart';
import '../../Global/Color/color_equipo.dart';
import '../../Global/Widgets/app_bar.dart';

/// Vista que permite organizar las edificaciones antes de la batalla.
///
/// Contiene el juego con Flame, encabezado personalizado, instrucciones,
/// y botón para iniciar la batalla. Carga automáticamente los datos del
/// equipo desde `SharedPreferences`.
class SetupGameView extends StatefulWidget {
  const SetupGameView({super.key});

  @override
  State<SetupGameView> createState() => _SetupGameViewState();
}

class _SetupGameViewState extends State<SetupGameView> {
  /// Instancia del juego con Flame
  final SetupGame game = SetupGame();

  /// Nombre del equipo, cargado desde SharedPreferences.
  String nombreEquipo = '';

  /// Color del equipo, cargado desde SharedPreferences y convertido desde enum.
  Color colorEquipo = Colors.black;

  /// ID de la partida actual.
  String? partidaId;

  /// Nombre del equipo actual (clave en Firebase).
  String? equipo;

  @override
  void initState() {
    super.initState();
    _cargarDatosEquipo();
  }

  /// Carga los datos persistidos del equipo y partida desde SharedPreferences.
  Future<void> _cargarDatosEquipo() async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener nombre del equipo
    nombreEquipo = prefs.getString('EMPRESA') ?? '';

    // Obtener y convertir color del equipo desde el enum
    final colorName = prefs.getString('COLOR');
    if (colorName != null) {
      final colorEnum = AppColorEquipo.values.firstWhere((e) => e.name == colorName);
      colorEquipo = colorEnum.color;
    }

    // Obtener identificadores adicionales
    partidaId = prefs.getString('PARTIDA');
    equipo = prefs.getString('EQUIPO');

    // Refrescar la vista una vez cargados los datos
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: customAppBar(context: context, title: nombreEquipo, backgroundColor: colorEquipo),
      ),
      body: Stack(
        children: [
          /// Fondo de imagen personalizado
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Icon/FONDO GENERAL.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

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
                  child:
                      nombreEquipo.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : GameWidget(game: game),
                ),
              ),

              // Botón "¡A la batalla!"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Aquí puedes implementar la navegación a la vista de batalla
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
