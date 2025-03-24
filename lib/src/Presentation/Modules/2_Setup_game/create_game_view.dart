import 'package:flutter/material.dart';

import '../../../Data/Firebase/Equipo/crear_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../../../Data/Firebase/Partida/eliminar_partida.dart';
import '../../../Data/Firebase/Sector/guardar_sector.dart'; // Nueva clase importada
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

//---------------------------------------------------------
Map<int, Map<String, dynamic>> seleccionEquipos = {};

final opcionesEmpresa = [
  {'id': 1, 'nombre': 'Comotor'},
  {'id': 2, 'nombre': 'Taxis Verdes'},
  {'id': 3, 'nombre': 'Ultra Huila'},
  {'id': 3, 'nombre': 'Taxis el Inge'},
];

final opcionesFuerza = [
  {'id': 1, 'nombre': 'Producto sustituto'},
  {'id': 2, 'nombre': 'Elementos fuertes'},
  {'id': 3, 'nombre': 'Comida de noche'},
  {'id': 3, 'nombre': 'Ser Inges'},
];

final opcionesColores = [
  {'id': 1, 'nombre': 'Naranja', 'color': Colors.orange},
  {'id': 2, 'nombre': 'Verde', 'color': Colors.green},
  {'id': 3, 'nombre': 'Amarillo', 'color': Colors.yellow},
  {'id': 4, 'nombre': 'Cyan', 'color': Colors.cyanAccent},
];
//---------------------------------------------------------

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
  final CrearEquipo crearEquipo = CrearEquipo();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _cargarPartidaActual();
      if (partidaActual != null) {
        _crearEquiposEnPartida();
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

  /// **Crea los equipos en la partida actual**
  Future<void> _crearEquiposEnPartida() async {
    if (partidaActual != null) {
      await crearEquipo.crearEquipos(partidaActual!);
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
                  icon: const Icon(Icons.star_border),
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
                  titulo: 'Tiempo permitido',
                  icon: const Icon(Icons.star_border),
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
                    direccion: Direccion.vertical,
                    opcionesEmpresa: opcionesEmpresa,
                    opcionesFuerza: opcionesFuerza,
                    opcionesColores: opcionesColores,
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
            icon: const Icon(Icons.star_border),
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
            titulo: 'Tiempo permitido',
            icon: const Icon(Icons.star_border),
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
            direccion: Direccion.horizontal,
            opcionesEmpresa: opcionesEmpresa,
            opcionesFuerza: opcionesFuerza,
            opcionesColores: opcionesColores,
            onSeleccion: (p0) {},
          ),
      ],
    );
  }
}
