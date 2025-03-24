import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de eliminar una partida en Firebase Realtime Database.
class EliminarPartida {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  EliminarPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para eliminar la partida almacenada en `SharedPreferences`.
  Future<void> eliminarPartidaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    String? partidaId = prefs.getString('partidaId');

    if (partidaId != null) {
      final DatabaseReference partidaRef = _dbRef.child(
        'Five Force Competence/PARTIDAS/$partidaId',
      );

      // Eliminar la partida de Firebase
      await partidaRef.remove();

      // Eliminar la partida de SharedPreferences
      await prefs.remove('partidaId');

      debugPrint('Partida eliminada con éxito: $partidaId');
    } else {
      debugPrint('No hay una partida guardada para eliminar.');
    }
  }
}
