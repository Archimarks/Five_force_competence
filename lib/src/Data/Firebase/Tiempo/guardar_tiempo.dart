// guardar_tiempo.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # GuardarTiempo
///
/// **Clase encargada de gestionar la selección del tiempo de turno para una
/// partida en Firebase Realtime Database.**
///
/// Esta clase permite guardar la duración del turno de juego para una partida
/// específica, utilizando Firebase y persistencia local con `SharedPreferences`.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class GuardarTiempo {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene la clave de la partida actual almacenada localmente.
  ///
  /// ### Retorna:
  /// - `String?`: El ID de la partida guardado en `SharedPreferences`,
  ///   o `null` si no existe.
  ///
  /// ### Uso:
  /// ```dart
  /// String? partida = await GuardarTiempo().obtenerPartidaGuardada();
  /// ```
  /// -------------------------------------------------------------------------
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('partidaId');
  }

  /// -------------------------------------------------------------------------
  /// Guarda la selección del tiempo de turno en Firebase.
  ///
  /// ### Parámetros:
  /// - `seleccion` (`String?`): Valor de tiempo seleccionado que se desea guardar.
  ///
  /// ### Comportamiento:
  /// - Verifica si hay una partida activa guardada localmente.
  /// - Guarda el valor en la ruta:
  ///   `Five Force Competence/PARTIDAS/{partida}/CONFIGURACIONES/TIEMPO TURNO`.
  ///
  /// ### Validaciones:
  /// - Si no se encuentra una partida activa, muestra un error.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// await GuardarTiempo().guardarSeleccion('30');
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> guardarSeleccion(String? seleccion) async {
    String? partidaActual = await obtenerPartidaGuardada();

    if (partidaActual == null || partidaActual.isEmpty) {
      debugPrint('❌ Error: No se encontró una partida guardada.');
      return;
    }

    try {
      DatabaseReference ref = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/TIEMPO TURNO');

      await ref
          .set(seleccion)
          .then((_) {
            debugPrint('✅ Selección guardada en Firebase: $seleccion');
          })
          .catchError((error) {
            debugPrint('❌ Error al guardar en Firebase: $error');
          });
    } catch (e) {
      debugPrint('❌ Excepción atrapada: $e');
    }
  }
}
