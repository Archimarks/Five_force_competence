import 'package:flutter/material.dart';

import '../../../Data/Firebase/Partida/eliminar_partida.dart';
import '../../../Data/Firebase/Sector/guardar_sector.dart'; // Nueva clase importada
import '../../../Data/Firebase/Sector/traer_todos_sectores.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Global/Widgets/campo_desplegable.dart';
import '../../Routes/routes.dart';

//--------------------------------------------------------
/// **Título de la pantalla**
String titulo = 'Partida N';
//--------------------------------------------------------

/// **Vista para la creación de una partida**
class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  final GuardarSector guardarSector = GuardarSector(); // Instancia de la nueva clase
  final TraerTodosSectores traerTodosSectores = TraerTodosSectores();

  List<String> opcionesTematicas = [];
  String? opcionTematicasSeleccionada;
  String? partidaActual;

  @override
  void initState() {
    super.initState();
    _cargarPartidaGuardada();
    _cargarSectores();
  }

  /// **Obtiene la partida guardada en persistencia local**
  Future<void> _cargarPartidaGuardada() async {
    String? partida = await guardarSector.obtenerPartidaGuardada();
    setState(() {
      partidaActual = partida;
    });

    if (partidaActual != null) {
      debugPrint('🎮 Partida cargada: $partidaActual');
    } else {
      debugPrint('❌ No hay partida guardada.');
    }
  }

  /// **Carga los sectores desde Firebase y los almacena en la lista de opciones**
  Future<void> _cargarSectores() async {
    Map<String, dynamic>? sectores = await traerTodosSectores.obtenerSectores();
    if (sectores != null) {
      setState(() {
        opcionesTematicas = sectores.keys.toList();
      });
    }
  }

  /// **Guarda la selección en Firebase**
  void _guardarSeleccion(String? seleccion) {
    guardarSector.guardarSeleccion(seleccion);
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: titulo,
        onLeadingPressed: () async {
          Navigator.pushReplacementNamed(context, Routes.home);
          final eliminarPartida = EliminarPartida();
          await eliminarPartida.eliminarPartidaGuardada();
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Placeholder()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 70, 70, 70).withAlpha((0.6 * 255).toInt()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                orientation == Orientation.portrait ? _portraitVertical() : _landscapeHorizontal(),
          ),
        ],
      ),
    );
  }

  /// **Diseño para orientación vertical**
  Widget _portraitVertical() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                CampoDesplegable(
                  titulo: 'Sector',
                  icon: const Icon(Icons.star_border),
                  opciones: opcionesTematicas,
                  valorSeleccionado: opcionTematicasSeleccionada,
                  partidaId: partidaActual ?? '', // Se añade el argumento requerido
                  onChanged: (nuevaOpcion) {
                    setState(() {
                      opcionTematicasSeleccionada = nuevaOpcion;
                    });
                    _guardarSeleccion(nuevaOpcion);
                  },
                  onClear: () {
                    setState(() {
                      opcionTematicasSeleccionada = null;
                    });
                    _guardarSeleccion(null);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// **Diseño para orientación horizontal**
  Widget _landscapeHorizontal() {
    return Row(
      children: [
        Expanded(
          child: CampoDesplegable(
            titulo: 'Sector',
            icon: const Icon(Icons.star_border),
            opciones: opcionesTematicas,
            valorSeleccionado: opcionTematicasSeleccionada,
            partidaId: partidaActual ?? '', // Se añade el argumento requerido
            onChanged: (nuevaOpcion) {
              setState(() {
                opcionTematicasSeleccionada = nuevaOpcion;
              });
              _guardarSeleccion(nuevaOpcion);
            },
            onClear: () {
              setState(() {
                opcionTematicasSeleccionada = null;
              });
              _guardarSeleccion(null);
            },
          ),
        ),
      ],
    );
  }
}
