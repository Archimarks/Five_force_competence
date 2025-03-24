import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de cargar y almacenar la clave de la partida actual desde Firebase Realtime Database.
class CargarPartida {
  final DatabaseReference _dbRef;
  String? _partidaId;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  CargarPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// Getter para acceder a la clave de la partida actual.
  String? get partidaId => _partidaId;

  /// Método para cargar la clave de la partida actual desde `SharedPreferences`.
  Future<void> cargarClavePartida() async {
    final prefs = await SharedPreferences.getInstance();
    String? partidaId = prefs.getString('partidaId');

    if (partidaId != null) {
      final DatabaseReference partidaRef = _dbRef.child(
        'Five Force Competence/PARTIDAS/$partidaId',
      );

      DataSnapshot snapshot = await partidaRef.get();
      if (snapshot.exists) {
        _partidaId = partidaId;
        debugPrint('Clave de la partida cargada con éxito: $_partidaId');
      } else {
        debugPrint('La partida con clave $partidaId no existe en Firebase.');
        _partidaId = null;
      }
    } else {
      debugPrint('No hay una clave de partida guardada en SharedPreferences.');
      _partidaId = null;
    }
  }
}
