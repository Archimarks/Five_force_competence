import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Color/color_equipo.dart';

enum DireccionR { horizontal, vertical }

class PopupResumen extends StatefulWidget {
  final String partidaId;
  final DireccionR direccion;

  const PopupResumen({super.key, required this.partidaId, required this.direccion});

  @override
  _PopupResumenState createState() => _PopupResumenState();
}

class _PopupResumenState extends State<PopupResumen> {
  late Future<List<Map<String, dynamic>>> _equiposFuture;

  @override
  void initState() {
    super.initState();
    _equiposFuture = _obtenerEquipos();
  }

  /// Obtiene los equipos desde Firebase
  Future<List<Map<String, dynamic>>> _obtenerEquipos() async {
    final DatabaseReference equiposRef = FirebaseDatabase.instance.ref().child(
      'Five Force Competence/PARTIDAS/${widget.partidaId}/EQUIPOS',
    );
    DataSnapshot snapshot = await equiposRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final equiposMap = Map<String, dynamic>.from(snapshot.value as Map);
      return equiposMap.entries.map((entry) {
        return {
          'nombre': entry.key,
          'codigo': entry.value['CODIGO'] ?? '',
          'color': _getColorFromString(entry.value['COLOR'] ?? ''),
        };
      }).toList();
    }
    return [];
  }

  /// Convierte el valor de color en un color de la paleta definida en AppColorEquipo
  Color _getColorFromString(String colorStr) {
    return AppColorEquipo.values
        .firstWhere(
          (e) => e.name.toUpperCase() == colorStr.toUpperCase(),
          orElse: () => AppColorEquipo.VERDE,
        ) // Color por defecto
        .color;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Equipos creados',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _equiposFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error al cargar los equipos');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay equipos disponibles');
                }
                return _buildTeamsGrid(snapshot.data!);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Iniciar partida', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la cuadrícula de equipos de forma dinámica
  Widget _buildTeamsGrid(List<Map<String, dynamic>> equipos) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      alignment: WrapAlignment.center,
      children:
          equipos
              .map(
                (equipo) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: equipo['color'],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          equipo['nombre'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'COD:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          equipo['codigo'],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
