import 'package:flutter/material.dart';

import '../../../Data/Firebase/Empresa/traer_todos_empresa.dart';
import '../../../Data/Firebase/Equipo/crear_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../Color/color.dart';
import '../Color/color_equipo.dart';
import 'popup_equipo.dart';

enum Direccion { horizontal, vertical }

enum EstadoEquipo { pendiente, preparado }

class CardEquipo extends StatefulWidget {
  final String partidaId;
  final Direccion direccion;

  final String? opcionSectorSeleccionada;

  final Function(Map<int, Map<String, dynamic>>) onSeleccion;

  final List<int> tarjetas;
  final List<int> tarjetasDisponibles;
  final Map<int, Map<String, dynamic>> seleccionTarjetas;
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

class CardWidgetState extends State<CardEquipo> {
  String? partidaActual;
  int? _loadingIndex; // Nuevo estado para rastrear la tarjeta que está cargando

  final TraerTodasEmpresas traerEmpresas = TraerTodasEmpresas();

  final CrearEquipo crearEquipo = CrearEquipo();

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

  Future<void> _cargarPartidaActual() async {
    CargarPartida cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida(); // Llamamos al método actualizado
    if (cargarPartida.partidaId != null) {
      partidaActual = cargarPartida.partidaId;
    }
  }

  void _cargarEmpresas() async {
    Map<String, dynamic>? empresas = await traerEmpresas.obtenerEmpresas();
    setState(() {
      opcionesEmpresas = empresas.keys.toList();
    });
  }

  Future<void> _agregarTarjeta() async {
    if (widget.tarjetas.length < 4 && _loadingIndex == null) {
      setState(() {
        _loadingIndex = -1; // Usamos -1 para indicar que se está agregando una tarjeta
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
          debugPrint('Error al crear equipo: $e');
        });
      }
      setState(() {
        _loadingIndex = null;
      });
    }
  }

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
          debugPrint('Error al eliminar equipo: $e');
        });
      }
      setState(() {
        _loadingIndex = null;
      });
    }
  }

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
                  color:
                      isCurrentlyLoading
                          ? Colors.grey.shade300
                          : colorTarjeta, // Cambia el color si está cargando
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
