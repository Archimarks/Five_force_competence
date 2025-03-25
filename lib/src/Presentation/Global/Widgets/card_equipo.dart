import 'package:flutter/material.dart';

import '../../../Data/Firebase/Empresa/traer_todos_empresa.dart';
import '../../../Data/Firebase/Equipo/actualizar_equipo.dart';
import '../../../Data/Firebase/Equipo/crear_equipo.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../Color/color_equipo.dart';

enum Direccion { horizontal, vertical }

enum EstadoEquipo { pendiente, preparado }

class CardEquipo extends StatefulWidget {
  final String partidaId;
  final Direccion direccion;
  final Function(Map<int, Map<String, dynamic>>) onSeleccion;
  final Map<int, Map<String, dynamic>> seleccionesIniciales;

  const CardEquipo({
    super.key,
    required this.partidaId,
    required this.direccion,
    required this.onSeleccion,
    this.seleccionesIniciales = const {},
  });

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardEquipo> {
  String? partidaActual;

  List<int> tarjetas = [];

  List<int> tarjetasDisponibles = [];

  Map<int, Map<String, dynamic>> seleccionTarjetas = {};

  Map<String, EstadoEquipo> estadoEquipos = {};

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
    if (tarjetas.length < 4) {
      setState(() {
        int nuevoNumero;
        if (tarjetasDisponibles.isNotEmpty) {
          nuevoNumero = tarjetasDisponibles.removeAt(0);
        } else {
          nuevoNumero = (tarjetas.isEmpty) ? 1 : (tarjetas.last + 1);
        }
        tarjetas.add(nuevoNumero);
        // Ordenamos las tarjetas
        tarjetas.sort();
        // Agregamos el equipo al mapa con el nombre de la tarjeta y el estado 'Inactivo'
        estadoEquipos[nuevoNumero.toString()] = EstadoEquipo.pendiente;
      });

      if (partidaActual != null) {
        crearEquipo.crearEquipoDisponible(partidaActual!).catchError((e) {
          debugPrint('Error al crear equipo: $e');
        });
      }
    }
  }

  void eliminarTarjeta(int index) {
    if (tarjetas.isNotEmpty) {
      int numeroEliminado = tarjetas[index]; // Obtener el número antes de eliminarlo

      setState(() {
        tarjetas.removeAt(index);
        seleccionTarjetas.remove(numeroEliminado);
        tarjetasDisponibles.add(numeroEliminado);
        tarjetasDisponibles.sort();

        // Eliminar el equipo de estadoEquipos cuando se elimina la tarjeta
        estadoEquipos.remove(numeroEliminado.toString());
      });

      widget.onSeleccion(seleccionTarjetas);

      // Eliminar el equipo en Firebase usando el número de la tarjeta como equipoId
      if (partidaActual != null) {
        String equipoId = 'EQUIPO $numeroEliminado';
        crearEquipo.eliminarEquipo(partidaActual!, equipoId).catchError((e) {
          debugPrint('Error al eliminar equipo: $e');
        });
      }
    }
  }

  void mostrarPopup(int equipo) {
    Map<String, dynamic>? empresaSeleccionada = seleccionTarjetas[equipo]?['empresa'];
    AppColorEquipo? colorSeleccionado = seleccionTarjetas[equipo]?['color'];

    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            bool esValidoParaColor = empresaSeleccionada != null;
            bool sePuedeGuardar = esValidoParaColor && colorSeleccionado != null;

            return AlertDialog(
              title: Text('Configurar Equipo N° $equipo'),
              content: SizedBox(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Empresa',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        hint: const Text('Selecciona Empresa'),
                        value: empresaSeleccionada?['nombre'], // Solo tomamos el nombre como String
                        onChanged: (value) {
                          setStatePopup(() {
                            empresaSeleccionada = {
                              'nombre': value,
                            }; // Guardamos como un Map para mantener la estructura
                            colorSeleccionado = null;
                          });
                        },
                        items:
                            opcionesEmpresas.map((nombreEmpresa) {
                              return DropdownMenuItem(
                                value: nombreEmpresa, // Usamos solo el String del nombre
                                child: Text(nombreEmpresa),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 16),
                      DropdownButtonFormField<AppColorEquipo>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        hint: const Text('Selecciona Color'),
                        value: colorSeleccionado,
                        onChanged:
                            esValidoParaColor
                                ? (value) {
                                  setStatePopup(() {
                                    colorSeleccionado = value;
                                  });
                                }
                                : null,
                        items:
                            AppColorEquipo.values.map((color) {
                              return DropdownMenuItem(
                                value: color,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 20, height: 20, color: color.value),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(color.name, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                        disabledHint: const Text('Selecciona primero Empresa y Fuerza'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      sePuedeGuardar
                          ? () async {
                            setState(() {
                              // Actualiza la información de la tarjeta seleccionada
                              seleccionTarjetas[equipo] = {
                                'empresa': empresaSeleccionada, // Ahora solo el nombre
                                'color': colorSeleccionado,
                              };

                              // Cambia el estado del equipo a 'Preparado'
                              estadoEquipos[equipo.toString()] = EstadoEquipo.preparado;
                            });

                            // Crear una instancia de ActualizarEquipo
                            ActualizarEquipo actualizarEquipo = ActualizarEquipo();

                            // Llamar al método para actualizar los datos del equipo en la base de datos
                            await actualizarEquipo.actualizarPreGame(
                              partidaActual!, // Asumiendo que tienes el valor de la partida actual
                              equipo, // El equipo que estás actualizando, como "EQUIPO 1"
                              empresaSeleccionada?['nombre'], // El valor de la empresa seleccionada
                              colorSeleccionado!.name, // El valor del color seleccionado
                            );

                            // Luego de actualizar, pasa los datos al callback onSeleccion
                            widget.onSeleccion(seleccionTarjetas);

                            // Cierra el modal o pantalla actual
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          }
                          : null,
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
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
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: buildTarjetas()),
              )
              : Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildTarjetas(isVertical: true),
              ),
    );
  }

  List<Widget> buildTarjetas({bool isVertical = false}) {
    List<Widget> cardWidgets =
        tarjetas.asMap().entries.map((entry) {
          int index = entry.key;
          int numeroEquipo = entry.value;

          Color colorTarjeta =
              (seleccionTarjetas[numeroEquipo]?['color'] as AppColorEquipo?)?.color ??
              const Color.fromARGB(255, 78, 97, 129);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => mostrarPopup(numeroEquipo),
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
                      if (tarjetas.isNotEmpty)
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

    if (tarjetas.length < 4) {
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
