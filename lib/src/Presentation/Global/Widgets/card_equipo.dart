import 'package:flutter/material.dart';

import '../../../Data/Firebase/Empresa/traer_todos_empresa.dart';
import '../Color/color_equipo.dart';

enum Direccion { horizontal, vertical }

late String? partidaActual;

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
  List<int> tarjetas = [];
  Map<int, Map<String, dynamic>> seleccionTarjetas = {};
  List<int> tarjetasDisponibles = [];

  final TraerTodasEmpresas traerEmpresas = TraerTodasEmpresas();
  List<String> opcionesEmpresas = [];

  @override
  void initState() {
    super.initState();
    _cargarEmpresas();
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
        tarjetas.sort();
      });
    }
  }

  void eliminarTarjeta(int index) {
    if (tarjetas.isNotEmpty) {
      setState(() {
        int numeroEliminado = tarjetas.removeAt(index);
        seleccionTarjetas.remove(numeroEliminado);
        tarjetasDisponibles.add(numeroEliminado);
        tarjetasDisponibles.sort();
      });
      widget.onSeleccion(seleccionTarjetas);
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
                          ? () {
                            setState(() {
                              seleccionTarjetas[equipo] = {
                                'empresa': empresaSeleccionada, // Ahora solo el nombre
                                'color': colorSeleccionado,
                              };
                            });
                            widget.onSeleccion(seleccionTarjetas);
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
