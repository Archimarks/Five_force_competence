import 'package:flutter/material.dart';

import '../../../Data/Firebase/Equipo/actualizar_equipo.dart';
import '../Color/color_equipo.dart';
import 'card_equipo.dart';

///
/// * Clase: `PopupEquipo`
/// * Descripción: Muestra un cuadro de diálogo personalizado para configurar la empresa y el color asignado a un equipo en la vista previa del juego.
///
class PopupEquipo {
  ///
  /// Muestra un `AlertDialog` para configurar un equipo específico dentro del juego.
  ///
  /// * `context`: Contexto de la aplicación.
  /// * `equipo`: Número del equipo a configurar.
  /// * `seleccionTarjetas`: Mapa con las configuraciones de todos los equipos (empresa y color).
  /// * `estadoEquipos`: Mapa con el estado actual de cada equipo.
  /// * `opcionesEmpresas`: Lista de nombres de empresas disponibles.
  /// * `partidaActual`: ID de la partida activa.
  /// * `onSeleccion`: Callback que se ejecuta tras guardar la configuración.
  /// * `opcionSectorSeleccionada`: Sector seleccionado por el equipo.
  ///
  static void mostrar(
    BuildContext context,
    int equipo,
    Map<int, Map<String, dynamic>> seleccionTarjetas,
    Map<String, EstadoEquipo> estadoEquipos,
    List<String> opcionesEmpresas,
    String partidaActual,
    Function(Map<int, Map<String, dynamic>>) onSeleccion,
    String? opcionSectorSeleccionada,
  ) {
    // Obtener empresa y color actualmente seleccionados por el equipo
    Map<String, dynamic>? empresaSeleccionada = seleccionTarjetas[equipo]?['empresa'];
    AppColorEquipo? colorSeleccionado = seleccionTarjetas[equipo]?['color'];

    ///
    /// Filtrar empresas ya seleccionadas por otros equipos,
    /// pero mantener la opción actual del equipo disponible.
    ///
    List<String> empresasDisponibles =
        opcionesEmpresas.where((empresa) {
          return empresa == empresaSeleccionada?['nombre'] ||
              !seleccionTarjetas.values.any((e) => e['empresa']?['nombre'] == empresa);
        }).toList();

    ///
    /// Filtrar colores ya seleccionados por otros equipos,
    /// excepto el del equipo actual para permitir su edición.
    ///
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
            // Validaciones para habilitar el botón de guardar
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
                      ///
                      /// * Dropdown de selección de empresa *
                      ///
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
                              colorSeleccionado = null; // Reiniciar color al cambiar empresa
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

                      ///
                      /// * Dropdown de selección de color *
                      ///
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

              ///
              /// Botones de acción: Cancelar y Guardar
              ///
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed:
                      sePuedeGuardar
                          ? () async {
                            // Guardar selección del equipo
                            seleccionTarjetas[equipo] = {
                              'empresa': empresaSeleccionada,
                              'color': colorSeleccionado,
                            };

                            // Marcar equipo como preparado
                            estadoEquipos[equipo.toString()] = EstadoEquipo.preparado;

                            // Actualizar datos en Firebase
                            await ActualizarEquipo().actualizarPreGame(
                              partidaActual,
                              equipo,
                              empresaSeleccionada?['nombre'],
                              colorSeleccionado!.name,
                              opcionSectorSeleccionada!,
                            );

                            // Cerrar el popup y devolver las selecciones actualizadas
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
