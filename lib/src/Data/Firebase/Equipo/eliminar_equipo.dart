import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de la eliminación de equipos en Firebase Realtime Database.
class EliminarEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  EliminarEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para eliminar un equipo dentro de una partida específica.
  Future<void> eliminarEquipo(String partidaActual, String equipoId) async {
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId',
    );

    DataSnapshot snapshot = await equipoRef.get();
    if (snapshot.exists) {
      await equipoRef.remove();
      await _eliminarEquipoId();
      debugPrint('Equipo eliminado con éxito: $equipoId');
    } else {
      debugPrint('El equipo no existe y no se puede eliminar.');
    }
  }

  /// Elimina el ID del equipo almacenado en SharedPreferences.
  Future<void> _eliminarEquipoId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipoId');
  }
}
