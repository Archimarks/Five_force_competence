import 'package:flutter/material.dart';

import '../../../Data/Firebase/Equipo/actualizar_equipo.dart';
import '../Color/color_equipo.dart';
import 'card_equipo.dart';

/// PopupEquipo: Muestra un cuadro de diálogo para configurar un equipo
class PopupEquipo {
  static void mostrar(
    BuildContext context,
    int equipo,
    Map<int, Map<String, dynamic>> seleccionTarjetas,
    Map<String, EstadoEquipo> estadoEquipos,
    List<String> opcionesEmpresas,
    String partidaActual,
    Function(Map<int, Map<String, dynamic>>) onSeleccion,
  ) {
    Map<String, dynamic>? empresaSeleccionada = seleccionTarjetas[equipo]?['empresa'];
    AppColorEquipo? colorSeleccionado = seleccionTarjetas[equipo]?['color'];

    /// Filtrar empresas y colores ya seleccionados por otros equipos,
    /// pero asegurando que la empresa y color actual del equipo se mantengan en la lista.
    List<String> empresasDisponibles =
        opcionesEmpresas.where((empresa) {
          return empresa == empresaSeleccionada?['nombre'] ||
              !seleccionTarjetas.values.any((e) => e['empresa']?['nombre'] == empresa);
        }).toList();

    List<AppColorEquipo> coloresDisponibles =
        AppColorEquipo.values.where((color) {
          return color == colorSeleccionado ||
              !seleccionTarjetas.values.any((e) => e['color'] == color);
        }).toList();

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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 10,
              title: Text(
                'Configurar Equipo N° $equipo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Dropdown para seleccionar la empresa
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Empresa',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          hint: const Text('Selecciona Empresa'),
                          value: empresaSeleccionada?['nombre'],
                          onChanged: (value) {
                            setStatePopup(() {
                              empresaSeleccionada = {'nombre': value};
                              colorSeleccionado = null;
                            });
                          },
                          items:
                              empresasDisponibles.map((nombreEmpresa) {
                                return DropdownMenuItem(
                                  value: nombreEmpresa,
                                  child: Text(nombreEmpresa),
                                );
                              }).toList(),
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// Dropdown para seleccionar el color
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                          ],
                        ),
                        child: DropdownButtonFormField<AppColorEquipo>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Color',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            fillColor: Colors.white,
                            filled: true,
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
                              coloresDisponibles.map((color) {
                                return DropdownMenuItem(
                                  value: color,
                                  child: Row(
                                    children: [
                                      Container(width: 20, height: 20, color: color.value),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(color.name, overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          disabledHint: const Text('Selecciona primero Empresa y Fuerza'),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed:
                      sePuedeGuardar
                          ? () async {
                            seleccionTarjetas[equipo] = {
                              'empresa': empresaSeleccionada,
                              'color': colorSeleccionado,
                            };
                            estadoEquipos[equipo.toString()] = EstadoEquipo.preparado;
                            await ActualizarEquipo().actualizarPreGame(
                              partidaActual,
                              equipo,
                              empresaSeleccionada?['nombre'],
                              colorSeleccionado!.name,
                            );

                            if (context.mounted) {
                              onSeleccion(seleccionTarjetas);
                              Navigator.pop(context);
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sePuedeGuardar ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                  child: const Text('Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
