// traer_todos_sectores.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// # TraerTodosSectores
///
/// **Clase encargada de consultar y obtener la lista de sectores almacenados
/// en Firebase Realtime Database.**
///
/// Esta clase permite recuperar todos los sectores definidos en la ruta:
/// `Five Force Competence/DATOS PERSISTENTES/SECTORES`.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class TraerTodosSectores {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a la base de datos.
  TraerTodosSectores() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene todos los sectores disponibles desde Firebase.
  ///
  /// ### Retorna:
  /// - `Map<String, dynamic>?`: Un mapa con la información de los sectores,
  ///   o `null` si no se encuentra información o ocurre un error.
  ///
  /// ### Comportamiento:
  /// - Accede a la ruta `'Five Force Competence/DATOS PERSISTENTES/SECTORES'`.
  /// - Verifica si los datos existen y son de tipo `Map`.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final sectores = await TraerTodosSectores().obtenerSectores();
  /// if (sectores != null) {
  ///   sectores.forEach((clave, valor) {
  ///     print('Clave: $clave, Valor: $valor');
  ///   });
  /// }
  /// ```
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerSectores() async {
    final DatabaseReference sectoresRef = _dbRef.child('Five Force Competence/DATOS PERSISTENTES/SECTORES');

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('⚠️ No se encontraron sectores en la base de datos.');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al obtener los sectores: $e');
      return null;
    }
  }
}
