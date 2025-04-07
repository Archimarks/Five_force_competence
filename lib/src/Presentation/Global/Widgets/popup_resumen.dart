import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Color/color_equipo.dart';

/// Enum que representa la dirección de organización de los elementos visuales.
/// Puede ser:
/// * `horizontal`
/// * `vertical`
enum DireccionR { horizontal, vertical }

/// PopupResumen muestra un cuadro de diálogo con el resumen de los equipos creados
/// en una partida específica. Actualiza la información cada 2 segundos desde Firebase.
///
/// * `partidaId`: ID de la partida en Firebase.
/// * `direccion`: Dirección en que se mostrarán los elementos visuales.
class PopupResumen extends StatefulWidget {
  final String partidaId;
  final DireccionR direccion;

  const PopupResumen({super.key, required this.partidaId, required this.direccion});

  @override
  PopupResumenState createState() => PopupResumenState();
}

class PopupResumenState extends State<PopupResumen> {
  /// Lista de equipos obtenidos desde Firebase
  List<Map<String, dynamic>> _equipos = [];

  /// Temporizador que actualiza los datos cada 2 segundos
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Carga inicial inmediata de los equipos
    _fetchEquipos();

    // Inicializa el temporizador para actualizar los datos periódicamente
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _fetchEquipos());
  }

  @override
  void dispose() {
    _timer.cancel(); // Detiene el temporizador al cerrar el widget
    super.dispose();
  }

  ///
  /// Obtiene los datos de los equipos desde Firebase Realtime Database
  /// bajo la ruta: `Five Force Competence/PARTIDAS/{partidaId}/EQUIPOS`
  ///
  /// La estructura del equipo esperada contiene:
  /// * `EMPRESA`
  /// * `CODIGO`
  /// * `ESTADO TURNO`
  /// * `COLOR`
  ///
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

            // Si el equipo está inactivo se le asigna su color; si está activo, se le asigna un color neutro
            final color =
                estadoTurno == 'INACTIVO'
                    ? _getColorFromString(data['COLOR'] ?? '')
                    : const Color.fromARGB(255, 48, 85, 117);

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

  ///
  /// Convierte un string con el nombre del color a un `Color` usando la enumeración `AppColorEquipo`.
  ///
  /// Si no se encuentra coincidencia, retorna el color por defecto `AppColorEquipo.VERDE`.
  ///
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
    // Verifica si todos los equipos están listos (estado INACTIVO)
    final todosListos =
        _equipos.isNotEmpty && _equipos.every((equipo) => equipo['estado_turno'] == 'INACTIVO');

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

            // Muestra un indicador de carga si no hay equipos aún
            _equipos.isEmpty ? const CircularProgressIndicator() : _buildTeamsGrid(_equipos),

            const SizedBox(height: 20),

            // Botón visible solo cuando todos los equipos están listos
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

  ///
  /// Construye una grilla con los equipos representados visualmente como tarjetas de color.
  ///
  /// Cada tarjeta muestra:
  /// * El nombre de la empresa
  /// * El código del equipo
  ///
  /// La tarjeta toma el color correspondiente al estado del equipo.
  ///
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
