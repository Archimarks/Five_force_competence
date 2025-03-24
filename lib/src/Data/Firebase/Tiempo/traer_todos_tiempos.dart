import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Clase encargada de traer todos los tiempos desde Firebase Realtime Database.
class TraerTodosTiempos {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  TraerTodosTiempos() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para obtener todos los tiempos desde Firebase.
  Future<Map<String, dynamic>?> obtenerSectores() async {
    final DatabaseReference sectoresRef = _dbRef.child(
      'Five Force Competence/DATOS PERSISTENTES/TIEMPOS',
    );

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('No se encontraron tiempos en la base de datos.');
        return null;
      }
    } catch (e) {
      debugPrint('Error al obtener los tiempos: $e');
      return null;
    }
  }
}
