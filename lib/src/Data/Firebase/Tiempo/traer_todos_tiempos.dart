import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// # TraerTodosTiempos
///
/// **Clase encargada de obtener todos los tiempos configurables desde Firebase
/// Realtime Database.**
///
/// Esta clase accede a la ruta correspondiente en la base de datos para
/// recuperar los valores definidos como tiempos disponibles para configurar
/// los turnos del juego.
///
/// ### Ruta en Firebase:
/// `Five Force Competence/DATOS PERSISTENTES/TIEMPOS`
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class TraerTodosTiempos {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  TraerTodosTiempos() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene todos los tiempos disponibles desde Firebase.
  ///
  /// ### Retorna:
  /// - `Map<String, dynamic>?`: Un mapa con los tiempos disponibles si existen,
  ///   o `null` si no hay datos o ocurre un error.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final tiempos = await TraerTodosTiempos().obtenerTiempos();
  /// ```
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerSectores() async {
    final DatabaseReference sectoresRef = _dbRef.child(
      'Five Force Competence/DATOS PERSISTENTES/TIEMPOS',
    );

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('⚠️ No se encontraron tiempos en la base de datos.');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al obtener los tiempos: $e');
      return null;
    }
  }
}
