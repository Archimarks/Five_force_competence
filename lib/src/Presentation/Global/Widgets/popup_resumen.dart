import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Color/color_equipo.dart';

enum DireccionR { horizontal, vertical }

class PopupResumen extends StatefulWidget {
  final String partidaId;
  final DireccionR direccion;

  const PopupResumen({super.key, required this.partidaId, required this.direccion});

  @override
  PopupResumenState createState() => PopupResumenState();
}

class PopupResumenState extends State<PopupResumen> {
  List<Map<String, dynamic>> _equipos = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fetchEquipos(); // primera carga inmediata
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchEquipos());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Obtiene los equipos desde Firebase
  Future<void> _fetchEquipos() async {
    final DatabaseReference equiposRef = FirebaseDatabase.instance.ref().child(
      'Five Force Competence/PARTIDAS/${widget.partidaId}/EQUIPOS',
    );
    DataSnapshot snapshot = await equiposRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final equiposMap = Map<String, dynamic>.from(snapshot.value as Map);
      final equiposList =
          equiposMap.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value);
            final estadoTurno = data['ESTADO TURNO'] ?? '';
            final color =
                estadoTurno == ''
                    ? const Color.fromARGB(255, 48, 85, 117)
                    : _getColorFromString(data['COLOR'] ?? '');
            return {
              'empresa': data['EMPRESA'] ?? '',
              'codigo': data['CODIGO'] ?? '',
              'estado_turno': estadoTurno,
              'color': color,
            };
          }).toList();

      setState(() {
        _equipos = equiposList;
      });
    }
  }

  /// Convierte el valor de color en un color de la paleta definida en AppColorEquipo
  Color _getColorFromString(String colorStr) {
    return AppColorEquipo.values
        .firstWhere(
          (e) => e.name.toUpperCase() == colorStr.toUpperCase(),
          orElse: () => AppColorEquipo.VERDE,
        )
        .color;
  }

  @override
  Widget build(BuildContext context) {
    final todosListos =
        _equipos.isNotEmpty &&
        _equipos.every((equipo) => equipo['estado_turno'].toString().isNotEmpty);

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
            _equipos.isEmpty ? const CircularProgressIndicator() : _buildTeamsGrid(_equipos),
            const SizedBox(height: 20),
            if (todosListos)
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
          equipos.map((equipo) {
            return Container(
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
                      equipo['empresa'],
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      equipo['codigo'],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
