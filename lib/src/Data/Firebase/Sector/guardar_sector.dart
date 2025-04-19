// guardar_sector.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # GuardarSector
///
/// **Clase encargada de gestionar la selección del sector para una partida,
/// almacenando esta información tanto en Firebase Realtime Database como en
/// `SharedPreferences`.**
///
/// Esta clase permite:
/// - Guardar el sector seleccionado por el usuario.
/// - Recuperar el ID de la partida actual.
/// - Consultar el sector previamente guardado.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class GuardarSector {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene el ID de la partida guardada desde `SharedPreferences`.
  ///
  /// ### Retorna:
  /// - `String?` con el ID de la partida o `null` si no se encuentra.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// String? partida = await GuardarSector().obtenerPartidaGuardada();
  /// ```
  /// -------------------------------------------------------------------------
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? partida = prefs.getString('partidaId');
    debugPrint('📌 Partida obtenida: $partida');
    return partida;
  }

  /// -------------------------------------------------------------------------
  /// Guarda la selección de sector en Firebase y localmente en `SharedPreferences`.
  ///
  /// ### Parámetros:
  /// - [seleccion]: Nombre del sector seleccionado (no puede ser nulo ni vacío).
  ///
  /// ### Validaciones:
  /// - Verifica que `seleccion` no sea nula ni vacía.
  /// - Verifica que exista una partida activa antes de guardar en Firebase.
  ///
  /// ### Comportamiento:
  /// - Guarda el sector en `SharedPreferences`.
  /// - Luego lo sincroniza en la base de datos bajo la ruta:
  ///   `'Five Force Competence/PARTIDAS/{partida}/CONFIGURACIONES/SECTOR'`
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// await GuardarSector().guardarSeleccion('Sector A');
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> guardarSeleccion(String? seleccion) async {
    if (seleccion == null || seleccion.isEmpty) {
      debugPrint('❌ Error: La selección de sector es nula o vacía.');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sectorSeleccionado', seleccion);
    debugPrint('✅ Sector guardado en SharedPreferences: $seleccion');

    String? partidaActual = await obtenerPartidaGuardada();
    if (partidaActual == null || partidaActual.isEmpty) {
      debugPrint('❌ Error: No se encontró una partida guardada.');
      return;
    }

    try {
      DatabaseReference ref = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/SECTOR');

      await ref.set(seleccion);
      debugPrint('✅ Sector guardado en Firebase correctamente: $seleccion');

      // Verificación del guardado en Firebase
      String? guardado = (await ref.get()).value as String?;
      debugPrint('🔍 Sector guardado en Firebase (verificado): $guardado');
    } catch (e) {
      debugPrint('❌ Error al guardar en Firebase: $e');
    }
  }

  /// -------------------------------------------------------------------------
  /// Obtiene la selección de sector almacenada en `SharedPreferences`.
  ///
  /// ### Retorna:
  /// - `String?` con el nombre del sector o `null` si no se ha guardado.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// String? sector = await GuardarSector().obtenerSectorSeleccionado();
  /// ```
  /// -------------------------------------------------------------------------
  Future<String?> obtenerSectorSeleccionado() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sector = prefs.getString('sectorSeleccionado');
    debugPrint('📌 Sector obtenido de SharedPreferences: $sector');
    return sector;
  }
}
