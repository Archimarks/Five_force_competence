import 'package:flutter/material.dart';

import '../../../Data/Firebase/Empresa/traer_todos_empresa.dart';
import '../../../Data/Firebase/Equipo/crear_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../Color/color.dart';
import '../Color/color_equipo.dart';
import 'popup_equipo.dart';

/// ### Enum: `Direccion`
///
/// Define la orientación en la que se deben mostrar las tarjetas del equipo.
///
/// - `horizontal` → Tarjetas en fila horizontal.
/// - `vertical` → Tarjetas apiladas verticalmente.
enum Direccion { horizontal, vertical }

/// ### Enum: `EstadoEquipo`
///
/// Define el estado actual de un equipo:
///
/// - `pendiente` → El equipo no ha sido configurado.
/// - `preparado` → El equipo está listo para jugar.
enum EstadoEquipo { pendiente, preparado }

/// ### Widget: `CardEquipo`
///
/// Widget personalizado para mostrar y administrar tarjetas de equipos dentro
/// de una partida. Permite crear, editar o eliminar hasta **4 equipos**.
///
/// ---
class CardEquipo extends StatefulWidget {
  /// **ID** de la partida actual.
  final String partidaId;

  /// Dirección en la que se visualizan las tarjetas (`horizontal` o `vertical`).
  final Direccion direccion;

  /// Sector que fue seleccionado (puede ser `null`).
  final String? opcionSectorSeleccionada;

  /// Callback que se llama cuando se actualiza una tarjeta.
  final Function(Map<int, Map<String, dynamic>>) onSeleccion;

  /// Lista de tarjetas ya visibles.
  final List<int> tarjetas;

  /// Tarjetas que aún no se han utilizado.
  final List<int> tarjetasDisponibles;

  /// Datos detallados de selección de cada tarjeta.
  final Map<int, Map<String, dynamic>> seleccionTarjetas;

  /// Mapa que contiene el estado actual de cada equipo.
  final Map<String, EstadoEquipo> estadoEquipos;

  const CardEquipo({
    super.key,
    required this.partidaId,
    required this.direccion,
    required this.opcionSectorSeleccionada,
    required this.onSeleccion,
    required this.tarjetas,
    required this.tarjetasDisponibles,
    required this.seleccionTarjetas,
    required this.estadoEquipos,
  });

  @override
  CardWidgetState createState() => CardWidgetState();
}

/// ### Estado: `CardWidgetState`
///
/// Controla la lógica de creación, eliminación y configuración de los equipos.
///
/// También interactúa con Firebase para almacenar la información relevante.
class CardWidgetState extends State<CardEquipo> {
  /// ID de partida cargada desde memoria local.
  String? partidaActual;

  /// Índice de tarjeta que se está cargando actualmente (para mostrar loading).
  int? _loadingIndex;

  /// Servicio para traer empresas desde Firebase.
  final TraerTodasEmpresas traerEmpresas = TraerTodasEmpresas();

  /// Servicio para crear/eliminar equipos en Firebase.
  final CrearEquipo crearEquipo = CrearEquipo();

  /// Lista de nombres de empresas disponibles para asociar a equipos.
  List<String> opcionesEmpresas = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await _cargarPartidaActual();
      if (partidaActual != null) {
        _cargarEmpresas();
      }
    });
  }

  /// ### Función: `_cargarPartidaActual`
  ///
  /// Carga el ID de la partida actual desde almacenamiento local (SharedPreferences).
  Future<void> _cargarPartidaActual() async {
    CargarPartida cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida();
    if (cargarPartida.partidaId != null) {
      partidaActual = cargarPartida.partidaId;
    }
  }

  /// ### Función: `_cargarEmpresas`
  ///
  /// Consulta en Firebase todas las empresas disponibles y actualiza el estado.
  void _cargarEmpresas() async {
    Map<String, dynamic>? empresas = await traerEmpresas.obtenerEmpresas();
    setState(() {
      opcionesEmpresas = empresas.keys.toList();
    });
  }

  /// ### Función: `_agregarTarjeta`
  ///
  /// Agrega una nueva tarjeta al listado actual, respetando el límite de 4.
  ///
  /// También actualiza Firebase creando una entrada vacía del equipo.
  Future<void> _agregarTarjeta() async {
    if (widget.tarjetas.length < 4 && _loadingIndex == null) {
      setState(() {
        _loadingIndex = -1; // Mostramos indicador de carga
      });

      _cargarEmpresas();

      int nuevoNumero;
      if (widget.tarjetasDisponibles.isNotEmpty) {
        nuevoNumero = widget.tarjetasDisponibles.removeAt(0);
      } else {
        nuevoNumero = (widget.tarjetas.isEmpty) ? 1 : (widget.tarjetas.last + 1);
      }

      setState(() {
        widget.tarjetas.add(nuevoNumero);
        widget.tarjetas.sort();
        widget.estadoEquipos[nuevoNumero.toString()] = EstadoEquipo.pendiente;
      });

      widget.onSeleccion(widget.seleccionTarjetas);

      if (partidaActual != null) {
        await crearEquipo.crearEquipoDisponible(partidaActual!).catchError((e) {
          debugPrint('❌ Error al crear equipo: $e');
        });
      }

      setState(() {
        _loadingIndex = null;
      });
    }
  }

  /// ### Función: `_eliminarTarjeta`
  ///
  /// Elimina una tarjeta del listado y borra su información de Firebase.
  ///
  /// - También libera el número para reutilizarlo luego.
  Future<void> _eliminarTarjeta(int index) async {
    if (widget.tarjetas.isNotEmpty && _loadingIndex == null) {
      setState(() {
        _loadingIndex = index;
      });

      int numeroEliminado = widget.tarjetas[index];

      setState(() {
        widget.tarjetas.removeAt(index);
        widget.seleccionTarjetas.remove(numeroEliminado);
        widget.tarjetasDisponibles.add(numeroEliminado);
        widget.tarjetasDisponibles.sort();
        widget.estadoEquipos.remove(numeroEliminado.toString());
      });

      widget.onSeleccion(widget.seleccionTarjetas);

      if (partidaActual != null) {
        String equipoId = 'EQUIPO $numeroEliminado';
        await crearEquipo.eliminarEquipo(partidaActual!, equipoId).catchError((e) {
          debugPrint('❌ Error al eliminar equipo: $e');
        });
      }

      setState(() {
        _loadingIndex = null;
      });
    }
  }

  /// ### Función: `_mostrarPopup`
  ///
  /// Abre el popup de configuración del equipo.
  void _mostrarPopup(int equipo) {
    if (_loadingIndex == null) {
      PopupEquipo.mostrar(
        context,
        equipo,
        widget.seleccionTarjetas,
        widget.estadoEquipos,
        opcionesEmpresas,
        partidaActual!,
        widget.onSeleccion,
        widget.opcionSectorSeleccionada,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child:
          widget.direccion == Direccion.horizontal
              ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: buildTarjetas(),
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: buildTarjetas(isVertical: true),
                ),
              ),
    );
  }

  /// ### Función: `buildTarjetas`
  ///
  /// Construye la interfaz visual para cada tarjeta, incluyendo botón de agregar.
  ///
  /// - Si la tarjeta está cargando, se muestra un `CircularProgressIndicator`.
  /// - Si hay menos de 4 tarjetas, se muestra un botón para agregar más.
  List<Widget> buildTarjetas({bool isVertical = false}) {
    List<Widget> cardWidgets =
        widget.tarjetas.asMap().entries.map((entry) {
          int index = entry.key;
          int numeroEquipo = entry.value;

          Color colorTarjeta =
              (widget.seleccionTarjetas[numeroEquipo]?['color'] as AppColorEquipo?)?.color ??
              AppColor.azulGris.value;

          final isCurrentlyLoading = _loadingIndex == index;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: isCurrentlyLoading ? null : () => _mostrarPopup(numeroEquipo),
              child: Container(
                width: isVertical ? double.infinity : 140,
                height: 50,
                decoration: BoxDecoration(
                  color: isCurrentlyLoading ? Colors.grey.shade300 : colorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child:
                      isCurrentlyLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Equipo N° $numeroEquipo',
                                style: const TextStyle(color: Colors.white),
                              ),
                              if (widget.tarjetas.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.white),
                                  onPressed: () => _eliminarTarjeta(index),
                                ),
                            ],
                          ),
                ),
              ),
            ),
          );
        }).toList();

    if (widget.tarjetas.length < 4) {
      final isAddingLoading = _loadingIndex == -1;
      cardWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: isVertical ? double.infinity : 140,
            height: 50,
            child: ElevatedButton(
              onPressed: isAddingLoading ? null : _agregarTarjeta,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddingLoading ? Colors.grey.shade100 : AppColor.azulAcero.value,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  isAddingLoading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      );
    }
    return cardWidgets;
  }
}
