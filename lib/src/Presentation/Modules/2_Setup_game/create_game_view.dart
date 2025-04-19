import 'package:flutter/material.dart';

import '../../../Data/Firebase/Equipo/eliminar_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../../../Data/Firebase/Partida/eliminar_partida.dart';
import '../../../Data/Firebase/Sector/guardar_sector.dart';
import '../../../Data/Firebase/Sector/traer_todos_sectores.dart';
import '../../../Data/Firebase/Tiempo/guardar_tiempo.dart';
import '../../../Data/Firebase/Tiempo/traer_todos_tiempos.dart';
import '../../Global/Color/color.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Global/Widgets/button.dart';
import '../../Global/Widgets/card_equipo.dart';
import '../../Global/Widgets/desplegable_sector.dart';
import '../../Global/Widgets/desplegable_tiempo.dart';
import '../../Global/Widgets/popup_resumen.dart';
import '../../Routes/routes.dart';

/// ------------------------------------------------------------
/// * Título mostrado en la pantalla de creación de partida.
/// * Se actualizará con el ID de la partida actual.
/// ------------------------------------------------------------
String titulo = '';

/// ------------------------------------------------------------
/// * Vista principal para la creación de partidas.
/// * El usuario puede seleccionar un sector, un tiempo límite
///   y configurar los equipos participantes antes de iniciar.
/// ------------------------------------------------------------
class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  /// ID de la partida actual obtenida desde Firebase o persistencia local.
  String? partidaActual;

  /// Opciones seleccionadas por el usuario.
  String? opcionSectorSeleccionada;
  String? opcionTiempoSeleccionada;

  /// Listas de opciones disponibles.
  List<String> opcionesSectores = [];
  List<String> opcionesTiempos = [];

  /// Instancias para consultar datos en Firebase.
  final TraerTodosTiempos traerTodosTiempos = TraerTodosTiempos();
  final TraerTodosSectores traerTodosSectores = TraerTodosSectores();
  final GuardarSector guardarSector = GuardarSector();
  final GuardarTiempo guardarTiempo = GuardarTiempo();
  final EliminarEquipo eliminarTodosLosEquipos = EliminarEquipo();

  /// Tarjetas asignadas y disponibles para los equipos.
  List<int> tarjetas = [];
  List<int> tarjetasDisponibles = [];

  /// Mapa de tarjetas seleccionadas por cada equipo.
  Map<int, Map<String, dynamic>> seleccionTarjetas = {};

  /// Estados de los equipos: esperando o preparados.
  Map<String, EstadoEquipo> estadoEquipos = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _cargarPartidaActual();
      if (partidaActual != null) {
        _cargarPartidaGuardaSector();
        _cargarPartidaGuardaTiempo();
        _cargarSectores();
        _cargarTiempos();
      }
      titulo = partidaActual!;
    });
  }

  /// ------------------------------------------------------------
  /// * Carga el ID de la partida actual desde persistencia local.
  /// ------------------------------------------------------------
  Future<void> _cargarPartidaActual() async {
    CargarPartida cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida();
    if (cargarPartida.partidaId != null) {
      partidaActual = cargarPartida.partidaId;
    }
  }

  /// ------------------------------------------------------------
  /// * Carga las opciones de sectores desde Firebase.
  /// * Actualiza la lista `opcionesSectores`.
  /// ------------------------------------------------------------
  Future<void> _cargarSectores() async {
    Map<String, dynamic>? sectores = await traerTodosSectores.obtenerSectores();
    if (sectores != null) {
      setState(() {
        opcionesSectores = sectores.keys.toList();
      });
    }
  }

  /// ------------------------------------------------------------
  /// * Carga las opciones de tiempos desde Firebase.
  /// * Actualiza la lista `opcionesTiempos`.
  /// ------------------------------------------------------------
  Future<void> _cargarTiempos() async {
    Map<String, dynamic>? tiempos = await traerTodosTiempos.obtenerSectores();
    if (tiempos != null) {
      setState(() {
        opcionesTiempos = tiempos.keys.toList();
      });
    }
  }

  /// Carga la partida guardada en la selección de sector.
  Future<void> _cargarPartidaGuardaSector() async {
    String? partida = await guardarSector.obtenerPartidaGuardada();
    setState(() {
      partidaActual = partida;
    });
  }

  /// Carga la partida guardada en la selección de tiempo.
  Future<void> _cargarPartidaGuardaTiempo() async {
    String? partida = await guardarTiempo.obtenerPartidaGuardada();
    setState(() {
      partidaActual = partida;
    });
  }

  /// Guarda el sector seleccionado en Firebase.
  void _guardarSector(String? seleccion) {
    guardarSector.guardarSeleccion(seleccion);
  }

  /// Guarda el tiempo seleccionado en Firebase.
  void _guardarTiempo(String? seleccion) {
    guardarTiempo.guardarSeleccion(seleccion);
  }

  /// ------------------------------------------------------------
  /// * Elimina todos los equipos creados en la partida actual.
  /// * Se invoca cuando se cambia de sector.
  /// ------------------------------------------------------------
  Future<void> _eliminarTodosEquipos(String partidaActual) async {
    await eliminarTodosLosEquipos.eliminarTodosLosEquipos(partidaActual);
    setState(() {
      this.partidaActual = partidaActual;
    });
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
      ),
      body: Stack(
        children: [
          /// Fondo con imagen y transparencia oscura
          Positioned.fill(child: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/Icon/FONDO GENERAL.png'), fit: BoxFit.cover)))),
          Positioned.fill(child: Container(color: const Color.fromARGB(255, 70, 70, 70).withAlpha((0.6 * 255).toInt()))),
          Padding(padding: const EdgeInsets.all(20.0), child: orientation == Orientation.portrait ? _portraitVertical() : _landscapeHorizontal()),
        ],
      ),
    );
  }

  /// ------------------------------------------------------------
  /// * Layout para orientación **vertical (portrait)**.
  /// * Muestra los desplegables, tarjetas de equipos y botón.
  /// ------------------------------------------------------------
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

                /// Selector de sector
                DesplegableSector(
                  titulo: 'Sector',
                  icon: Icon(Icons.widgets, color: Colors.blueGrey[100]),
                  opciones: opcionesSectores,
                  valorSeleccionado: opcionSectorSeleccionada,
                  partidaId: partidaActual ?? '',
                  onChanged: (nuevaOpcion) async {
                    if (partidaActual != null) {
                      await _eliminarTodosEquipos(partidaActual!);
                      setState(() {
                        tarjetas.clear();
                        tarjetasDisponibles.clear();
                        seleccionTarjetas.clear();
                        estadoEquipos.clear();
                      });
                    }
                    setState(() {
                      opcionSectorSeleccionada = nuevaOpcion;
                    });
                    _guardarSector(nuevaOpcion);
                  },
                  onClear: () async {
                    if (partidaActual != null) {
                      await _eliminarTodosEquipos(partidaActual!);
                      setState(() {
                        tarjetas.clear();
                        tarjetasDisponibles.clear();
                        seleccionTarjetas.clear();
                        estadoEquipos.clear();
                      });
                    }
                    setState(() {
                      opcionSectorSeleccionada = null;
                    });
                    _guardarSector(null);
                  },
                ),

                const SizedBox(height: 25),

                /// Selector de tiempo
                DesplegableTiempo(
                  titulo: 'Tiempo permitido (Segundos)',
                  icon: Icon(Icons.timer_outlined, color: Colors.blueGrey[100]),
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

                /// Tarjeta de equipos (si hay sector y tiempo seleccionados)
                if (opcionSectorSeleccionada != null && opcionTiempoSeleccionada != null)
                  CardEquipo(
                    partidaId: partidaActual ?? '',
                    direccion: Direccion.vertical,
                    onSeleccion: (nuevaSeleccionTarjetas) {
                      setState(() {
                        seleccionTarjetas = nuevaSeleccionTarjetas;
                      });
                    },
                    tarjetas: tarjetas,
                    tarjetasDisponibles: tarjetasDisponibles,
                    seleccionTarjetas: seleccionTarjetas,
                    estadoEquipos: estadoEquipos,
                    opcionSectorSeleccionada: opcionSectorSeleccionada,
                  ),
              ],
            ),
          ),
        ),

        /// Botón de confirmar (solo si hay al menos 2 equipos preparados)
        if (estadoEquipos.length >= 2 && estadoEquipos.values.every((estado) => estado == EstadoEquipo.preparado))
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Button(
                texto: 'Confirmar',
                color: AppColor.verdeBosque,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PopupResumen(partidaId: partidaActual ?? '', direccion: DireccionR.vertical);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  /// ------------------------------------------------------------
  /// * Layout para orientación **horizontal (landscape)**.
  /// * Muestra los desplegables en fila y las tarjetas debajo.
  /// ------------------------------------------------------------
  Widget _landscapeHorizontal() {
    return Column(
      children: [
        /// Desplegables en fila
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: DesplegableSector(
                titulo: 'Sector',
                icon: const Icon(Icons.widgets, color: Colors.lightBlueAccent),
                opciones: opcionesSectores,
                valorSeleccionado: opcionSectorSeleccionada,
                partidaId: partidaActual ?? '',
                onChanged: (nuevaOpcion) async {
                  if (partidaActual != null) {
                    await _eliminarTodosEquipos(partidaActual!);
                    setState(() {
                      tarjetas.clear();
                      tarjetasDisponibles.clear();
                      seleccionTarjetas.clear();
                      estadoEquipos.clear();
                    });
                  }
                  setState(() {
                    opcionSectorSeleccionada = nuevaOpcion;
                  });
                  _guardarSector(nuevaOpcion);
                },
                onClear: () async {
                  if (partidaActual != null) {
                    await _eliminarTodosEquipos(partidaActual!);
                    setState(() {
                      tarjetas.clear();
                      tarjetasDisponibles.clear();
                      seleccionTarjetas.clear();
                      estadoEquipos.clear();
                    });
                  }
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
          ],
        ),

        /// Tarjetas de equipos (condicional)
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                (opcionSectorSeleccionada != null && opcionTiempoSeleccionada != null)
                    ? CardEquipo(
                      partidaId: partidaActual ?? '',
                      direccion: Direccion.horizontal,
                      onSeleccion: (nuevaSeleccionTarjetas) {
                        setState(() {
                          seleccionTarjetas = nuevaSeleccionTarjetas;
                        });
                      },
                      tarjetas: tarjetas,
                      tarjetasDisponibles: tarjetasDisponibles,
                      seleccionTarjetas: seleccionTarjetas,
                      estadoEquipos: estadoEquipos,
                      opcionSectorSeleccionada: opcionSectorSeleccionada,
                    )
                    : const SizedBox.shrink(),
          ),
        ),

        /// Botón en la parte inferior
        if (estadoEquipos.length >= 2 && estadoEquipos.values.every((estado) => estado == EstadoEquipo.preparado))
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Button(
                texto: 'Confirmar',
                color: AppColor.verdeBosque,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return PopupResumen(partidaId: partidaActual ?? '', direccion: DireccionR.horizontal);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
