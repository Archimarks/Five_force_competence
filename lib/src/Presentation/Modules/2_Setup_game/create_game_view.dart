import 'package:flutter/material.dart';

import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../../../Data/Firebase/Partida/eliminar_partida.dart';
import '../../../Data/Firebase/Sector/guardar_sector.dart';
import '../../../Data/Firebase/Sector/traer_todos_sectores.dart';
import '../../../Data/Firebase/Tiempo/guardar_tiempo.dart';
import '../../../Data/Firebase/Tiempo/traer_todos_tiempos.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Global/Widgets/card_equipo.dart';
import '../../Global/Widgets/desplegable_sector.dart';
import '../../Global/Widgets/desplegable_tiempo.dart';
import '../../Routes/routes.dart';

//--------------------------------------------------------
/// **Título de la pantalla**
String titulo = 'Partida N';
//--------------------------------------------------------

//--------------------------------------------------------

/// **Vista para la creación de una partida**
class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  String? partidaActual;

  String? opcionSectorSeleccionada;
  String? opcionTiempoSeleccionada;

  List<String> opcionesSectores = [];
  List<String> opcionesTiempos = [];

  final TraerTodosTiempos traerTodosTiempos = TraerTodosTiempos();
  final TraerTodosSectores traerTodosSectores = TraerTodosSectores();

  final GuardarSector guardarSector = GuardarSector();
  final GuardarTiempo guardarTiempo = GuardarTiempo();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _cargarPartidaActual();
      if (partidaActual != null) {
        _cargarPartidaGuardaSector();
        _cargarPartidaGuardaTiempo();
        _cargarSectores();
        _cargarTiempos();
      }
    });
  }

  Future<void> _cargarPartidaActual() async {
    CargarPartida cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida(); // Llamamos al método actualizado
    if (cargarPartida.partidaId != null) {
      partidaActual = cargarPartida.partidaId;
    }
  }

  /// **Carga los sectores desde Firebase y los almacena en la lista de opciones**
  Future<void> _cargarSectores() async {
    Map<String, dynamic>? sectores = await traerTodosSectores.obtenerSectores();
    if (sectores != null) {
      setState(() {
        opcionesSectores = sectores.keys.toList();
      });
    }
  }

  /// **Carga los tiempo desde Firebase y los almacena en la lista de opciones**
  Future<void> _cargarTiempos() async {
    Map<String, dynamic>? tiempos = await traerTodosTiempos.obtenerSectores();
    if (tiempos != null) {
      setState(() {
        opcionesTiempos = tiempos.keys.toList();
      });
    }
  }

  /// **Obtiene la partida guardada en persistencia local**
  Future<void> _cargarPartidaGuardaSector() async {
    String? partida = await guardarSector.obtenerPartidaGuardada();
    setState(() {
      partidaActual = partida;
    });
  }

  Future<void> _cargarPartidaGuardaTiempo() async {
    String? partida = await guardarTiempo.obtenerPartidaGuardada();
    setState(() {
      partidaActual = partida;
    });
  }

  /// **Guarda la selección Sector en Firebase**
  void _guardarSector(String? seleccion) {
    guardarSector.guardarSeleccion(seleccion);
  }

  /// **Guarda la selección Sector en Firebase**
  void _guardarTiempo(String? seleccion) {
    guardarTiempo.guardarSeleccion(seleccion);
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
                DesplegableSector(
                  titulo: 'Sector',
                  icon: const Icon(Icons.widgets, color: Colors.lightBlueAccent),
                  opciones: opcionesSectores,
                  valorSeleccionado: opcionSectorSeleccionada,
                  partidaId: partidaActual ?? '',
                  onChanged: (nuevaOpcion) {
                    setState(() {
                      opcionSectorSeleccionada = nuevaOpcion;
                    });
                    _guardarSector(nuevaOpcion);
                  },
                  onClear: () {
                    setState(() {
                      opcionSectorSeleccionada = null;
                    });
                    _guardarSector(null);
                  },
                ),
                const SizedBox(height: 25),
                DesplegableTiempo(
                  titulo: 'Tiempo permitido (Segundos)',
                  icon: const Icon(Icons.timer_outlined, color: Colors.lightBlueAccent),
                  opciones: opcionesTiempos,
                  valorSeleccionado: opcionTiempoSeleccionada,
                  partidaId: partidaActual ?? '',
                  onChanged: (nuevaOpcion) {
                    setState(() {
                      opcionTiempoSeleccionada = nuevaOpcion;
                    });
                    _guardarTiempo(nuevaOpcion);
                  },
                  onClear: () {
                    setState(() {
                      opcionTiempoSeleccionada = null;
                    });
                    _guardarTiempo(null);
                  },
                ),
                const SizedBox(height: 24),
                if (opcionSectorSeleccionada != null && opcionTiempoSeleccionada != null)
                  CardEquipo(
                    partidaId: partidaActual ?? '',
                    direccion: Direccion.vertical,
                    onSeleccion: (p0) {},
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
          child: DesplegableSector(
            titulo: 'Sector',
            icon: const Icon(Icons.widgets, color: Colors.lightBlueAccent),
            opciones: opcionesSectores,
            valorSeleccionado: opcionSectorSeleccionada,
            partidaId: partidaActual ?? '',
            onChanged: (nuevaOpcion) {
              setState(() {
                opcionSectorSeleccionada = nuevaOpcion;
              });
              _guardarSector(nuevaOpcion);
            },
            onClear: () {
              setState(() {
                opcionSectorSeleccionada = null;
              });
              _guardarSector(null);
            },
          ),
        ),
        const SizedBox(width: 50),
        Expanded(
          child: DesplegableTiempo(
            titulo: 'Tiempo permitido (Segundos)',
            icon: const Icon(Icons.timer_outlined, color: Colors.lightBlueAccent),
            opciones: opcionesTiempos,
            valorSeleccionado: opcionTiempoSeleccionada,
            partidaId: partidaActual ?? '',
            onChanged: (nuevaOpcion) {
              setState(() {
                opcionTiempoSeleccionada = nuevaOpcion;
              });
              _guardarTiempo(nuevaOpcion);
            },
            onClear: () {
              setState(() {
                opcionTiempoSeleccionada = null;
              });
              _guardarTiempo(null);
            },
          ),
        ),
        if (opcionSectorSeleccionada != null && opcionTiempoSeleccionada != null)
          CardEquipo(
            partidaId: partidaActual ?? '',
            direccion: Direccion.horizontal,
            onSeleccion: (p0) {},
          ),
      ],
    );
  }
}
