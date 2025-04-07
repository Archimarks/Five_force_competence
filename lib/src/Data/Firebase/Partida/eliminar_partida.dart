// eliminar_partida.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # EliminarPartida
///
/// **Clase encargada de eliminar una partida existente de Firebase Realtime
/// Database y borrar su referencia local almacenada en `SharedPreferences`.**
///
/// Esta clase es útil para limpiar partidas que ya no se utilizan o para
/// reiniciar el flujo del juego desde cero.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class EliminarPartida {
  /// Referencia raíz a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor que inicializa la conexión con Firebase.
  /// -------------------------------------------------------------------------
  EliminarPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Método para eliminar la partida actualmente guardada en `SharedPreferences`.
  ///
  /// ### Comportamiento:
  /// - Obtiene el `partidaId` almacenado localmente.
  /// - Si existe:
  ///   - Elimina la partida correspondiente de Firebase.
  ///   - Borra la referencia local (`partidaId`) de `SharedPreferences`.
  ///   - Muestra mensajes de confirmación mediante `debugPrint`.
  /// - Si no existe:
  ///   - Muestra un mensaje indicando que no hay partida guardada.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final eliminador = EliminarPartida();
  /// await eliminador.eliminarPartidaGuardada();
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> eliminarPartidaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    String? partidaId = prefs.getString('partidaId');

    if (partidaId != null) {
      final DatabaseReference partidaRef = _dbRef.child(
        'Five Force Competence/PARTIDAS/$partidaId',
      );

      // Eliminar la partida de Firebase
      await partidaRef.remove();

      // Eliminar el ID local de la partida
      await prefs.remove('partidaId');

      debugPrint('Partida eliminada con éxito: $partidaId');
    } else {
      debugPrint('No hay una partida guardada para eliminar.');
    }
  }
}
