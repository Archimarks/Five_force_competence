import 'package:flutter/material.dart';

import '../../../Data/Firebase/Empresa/traer_todos_empresa.dart';
import '../../../Data/Firebase/Equipo/crear_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../Color/color_equipo.dart';
import 'popup_equipo.dart';

enum Direccion { horizontal, vertical }

enum EstadoEquipo { pendiente, preparado }

class CardEquipo extends StatefulWidget {
  final String partidaId;
  final Direccion direccion;
  final Function(Map<int, Map<String, dynamic>>) onSeleccion;

  final List<int> tarjetas;
  final List<int> tarjetasDisponibles;
  final Map<int, Map<String, dynamic>> seleccionTarjetas;
  final Map<String, EstadoEquipo> estadoEquipos;

  const CardEquipo({
    super.key,
    required this.partidaId,
    required this.direccion,
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

  void agregarTarjeta() {
    if (widget.tarjetas.length < 4) {
      _cargarEmpresas();
      setState(() {
        int nuevoNumero;
        if (widget.tarjetasDisponibles.isNotEmpty) {
          nuevoNumero = widget.tarjetasDisponibles.removeAt(0);
        } else {
          nuevoNumero = (widget.tarjetas.isEmpty) ? 1 : (widget.tarjetas.last + 1);
        }
        widget.tarjetas.add(nuevoNumero);
        // Ordenamos las tarjetas
        widget.tarjetas.sort();
        // Agregamos el equipo al mapa con el nombre de la tarjeta y el estado 'Inactivo'
        widget.estadoEquipos[nuevoNumero.toString()] = EstadoEquipo.pendiente;
      });

      if (partidaActual != null) {
        crearEquipo.crearEquipoDisponible(partidaActual!).catchError((e) {
          debugPrint('Error al crear equipo: $e');
        });
      }
    }
  }

  void eliminarTarjeta(int index) {
    if (widget.tarjetas.isNotEmpty) {
      int numeroEliminado = widget.tarjetas[index]; // Obtener el número antes de eliminarlo

      setState(() {
        widget.tarjetas.removeAt(index);
        widget.seleccionTarjetas.remove(numeroEliminado);
        widget.tarjetasDisponibles.add(numeroEliminado);
        widget.tarjetasDisponibles.sort();

        // Eliminar el equipo de estadoEquipos cuando se elimina la tarjeta
        widget.estadoEquipos.remove(numeroEliminado.toString());
      });

      widget.onSeleccion(widget.seleccionTarjetas);

      // Eliminar el equipo en Firebase usando el número de la tarjeta como equipoId
      if (partidaActual != null) {
        String equipoId = 'EQUIPO $numeroEliminado';
        crearEquipo.eliminarEquipo(partidaActual!, equipoId).catchError((e) {
          debugPrint('Error al eliminar equipo: $e');
        });
      }
    }
  }

  void eliminarTodasLasTarjetas() {
    if (widget.tarjetas.isNotEmpty) {
      setState(() {
        for (int numeroEliminado in widget.tarjetas) {
          widget.seleccionTarjetas.remove(numeroEliminado);
          widget.tarjetasDisponibles.add(numeroEliminado);
          widget.estadoEquipos.remove(numeroEliminado.toString());
        }
        widget.tarjetasDisponibles.sort();
        widget.tarjetas.clear(); // Vaciar la lista de tarjetas
      });

      widget.onSeleccion(widget.seleccionTarjetas);

      // Eliminar equipos en Firebase
      if (partidaActual != null) {
        for (int numeroEliminado in widget.tarjetas) {
          String equipoId = 'EQUIPO $numeroEliminado';
          crearEquipo.eliminarEquipo(partidaActual!, equipoId).catchError((e) {
            debugPrint('Error al eliminar equipo: $e');
          });
        }
      }
    }
  }

  void _mostrarPopup(int equipo) {
    PopupEquipo.mostrar(
      context,
      equipo,
      widget.seleccionTarjetas,
      widget.estadoEquipos,
      opcionesEmpresas,
      partidaActual!,
      widget.onSeleccion,
    );
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
              const Color.fromARGB(255, 78, 97, 129);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _mostrarPopup(numeroEquipo),
              child: Container(
                // Use maximum width when vertical
                width: isVertical ? double.infinity : 140,
                height: 50,
                decoration: BoxDecoration(
                  color: colorTarjeta,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 78, 97, 129).withAlpha((0.6 * 255).toInt()),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Equipo N° $numeroEquipo', style: const TextStyle(color: Colors.white)),
                      if (widget.tarjetas.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () => eliminarTarjeta(index),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList();

    if (widget.tarjetas.length < 4) {
      cardWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            // Use maximum width when vertical
            width: isVertical ? double.infinity : 140,
            height: 50,
            child: ElevatedButton(
              onPressed: agregarTarjeta,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 51, 97, 134),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      );
    }
    return cardWidgets;
  }
}
