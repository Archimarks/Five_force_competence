import 'package:flutter/material.dart';

enum Direccion { horizontal, vertical }

class CardEquipo extends StatefulWidget {
  final Direccion direccion;
  final List<Map<String, dynamic>> opcionesEmpresa;
  final List<Map<String, dynamic>> opcionesFuerza;
  final List<Map<String, dynamic>> opcionesColores;
  final Function(Map<int, Map<String, dynamic>>) onSeleccion;
  // Add parameter for initial selections
  final Map<int, Map<String, dynamic>> seleccionesIniciales;

  const CardEquipo({
    super.key,
    required this.direccion,
    required this.opcionesEmpresa,
    required this.opcionesFuerza,
    required this.opcionesColores,
    required this.onSeleccion,
    this.seleccionesIniciales = const {},
  });

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardEquipo> {
  List<int> tarjetas = [1, 2]; // Equipos iniciales
  Map<int, Map<String, dynamic>> seleccionTarjetas = {};
  List<int> tarjetasDisponibles = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFromProps();
  }

  @override
  void didUpdateWidget(CardEquipo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If direction changed but we have the same selections, preserve state
    if (oldWidget.direccion != widget.direccion && !_initialized) {
      _initializeFromProps();
    }
  }

  void _initializeFromProps() {
    if (widget.seleccionesIniciales.isNotEmpty) {
      setState(() {
        seleccionTarjetas = Map.from(widget.seleccionesIniciales);

        // Update tarjetas list based on seleccionTarjetas
        List<int> tarjetasSeleccionadas = seleccionTarjetas.keys.toList();
        if (tarjetasSeleccionadas.isNotEmpty) {
          // Keep at least two cards
          if (tarjetasSeleccionadas.length < 2) {
            tarjetasSeleccionadas.addAll(
              [1, 2]
                  .where((n) => !tarjetasSeleccionadas.contains(n))
                  .take(2 - tarjetasSeleccionadas.length),
            );
          }
          tarjetas = [...tarjetasSeleccionadas];
          tarjetas.sort();
        }

        _initialized = true;
      });
    }
  }

  void _agregarTarjeta() {
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

  void _eliminarTarjeta(int index) {
    if (tarjetas.length > 2) {
      setState(() {
        int numeroEliminado = tarjetas.removeAt(index);
        seleccionTarjetas.remove(numeroEliminado);
        tarjetasDisponibles.add(numeroEliminado);
        tarjetasDisponibles.sort();
      });
      widget.onSeleccion(seleccionTarjetas);
    }
  }

  void _mostrarPopup(int equipo) {
    Map<String, dynamic>? empresaSeleccionada = seleccionTarjetas[equipo]?['empresa'];
    Map<String, dynamic>? fuerzaSeleccionada = seleccionTarjetas[equipo]?['fuerza'];
    Map<String, dynamic>? colorSeleccionado = seleccionTarjetas[equipo]?['color'];

    List<Map<String, dynamic>> empresasDisponibles =
        widget.opcionesEmpresa
            .where(
              (e) =>
                  !seleccionTarjetas.values.any((t) => t['empresa'] == e) ||
                  e == empresaSeleccionada,
            )
            .toList();

    List<Map<String, dynamic>> fuerzasDisponibles =
        widget.opcionesFuerza
            .where(
              (f) =>
                  !seleccionTarjetas.values.any((t) => t['fuerza'] == f) || f == fuerzaSeleccionada,
            )
            .toList();

    List<Map<String, dynamic>> coloresDisponibles =
        widget.opcionesColores
            .where(
              (c) =>
                  !seleccionTarjetas.values.any((t) => t['color'] == c) || c == colorSeleccionado,
            )
            .toList();

    // Get screen width to adjust dialog width
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            bool esValidoParaColor = empresaSeleccionada != null && fuerzaSeleccionada != null;
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
                      DropdownButtonFormField<Map<String, dynamic>>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Empresa',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        hint: const Text('Selecciona Empresa'),
                        value: empresaSeleccionada,
                        onChanged: (value) {
                          setStatePopup(() {
                            empresaSeleccionada = value;
                            fuerzaSeleccionada = null;
                            colorSeleccionado = null;
                          });
                        },
                        items:
                            empresasDisponibles.map((opcion) {
                              return DropdownMenuItem(value: opcion, child: Text(opcion['nombre']));
                            }).toList(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Fuerza',
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        hint: const Text('Selecciona Fuerza'),
                        value: fuerzaSeleccionada,
                        onChanged:
                            empresaSeleccionada != null
                                ? (value) {
                                  setStatePopup(() {
                                    fuerzaSeleccionada = value;
                                    colorSeleccionado = null;
                                  });
                                }
                                : null,
                        items:
                            fuerzasDisponibles.map((opcion) {
                              return DropdownMenuItem(value: opcion, child: Text(opcion['nombre']));
                            }).toList(),
                        disabledHint: const Text('Selecciona primero Empresa'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
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
                            coloresDisponibles.map((opcion) {
                              return DropdownMenuItem(
                                value: opcion,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 20, height: 20, color: opcion['color']),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        opcion['nombre'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
                                'empresa': empresaSeleccionada,
                                'fuerza': fuerzaSeleccionada,
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
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: _buildTarjetas()),
              )
              : Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildTarjetas(isVertical: true),
              ),
    );
  }

  List<Widget> _buildTarjetas({bool isVertical = false}) {
    List<Widget> cardWidgets =
        tarjetas.asMap().entries.map((entry) {
          int index = entry.key;
          int numeroEquipo = entry.value;

          Color colorTarjeta =
              seleccionTarjetas[numeroEquipo]?['color']?['color'] ??
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
                      if (tarjetas.isNotEmpty)
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

    if (tarjetas.length < 4) {
      cardWidgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            // Use maximum width when vertical
            width: isVertical ? double.infinity : 140,
            height: 50,
            child: ElevatedButton(
              onPressed: _agregarTarjeta,
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
