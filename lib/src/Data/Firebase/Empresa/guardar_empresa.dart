import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de traer todos los sectores desde Firebase Realtime Database.
class TraerTodosSectores {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  TraerTodosSectores() : _dbRef = FirebaseDatabase.instance.ref();

  /// **Obtiene la partida guardada desde SharedPreferences**
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('partidaId'); // Se usa la clave correcta
  }

  /// **Obtiene la partida guardada desde SharedPreferences**
  Future<String?> obtenerSectorGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sectorSeleccionado'); // Se usa la clave correcta
  }

  /// Método para obtener todos las empresas desde Firebase.
  Future<Map<String, dynamic>?> obtenerEmpresa() async {
    String? partidaActual = await obtenerPartidaGuardada();
    // ignore: unused_local_variable
    String? sectorActual = await obtenerSectorGuardada();

    final DatabaseReference sectoresRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/SECTOR',
    );

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('No se encontraron sectores en la base de datos.');
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener los sectores: $e');
      return null;
    }
  }
}
