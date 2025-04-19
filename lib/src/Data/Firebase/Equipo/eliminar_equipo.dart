import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # EliminarEquipo
///
/// **Clase responsable de eliminar equipos en Firebase Realtime Database.**
///
/// Permite borrar un equipo individual o todos los equipos de una partida
/// específica. También elimina el identificador localmente guardado
/// en `SharedPreferences`.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class EliminarEquipo {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `EliminarEquipo`.
  ///
  /// Inicializa la referencia a Firebase Realtime Database.
  /// -------------------------------------------------------------------------
  EliminarEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Elimina un equipo específico de una partida.
  ///
  /// Si el equipo existe, se elimina de Firebase y también se borra
  /// el ID almacenado en `SharedPreferences`.
  ///
  /// ### Parámetros:
  /// - `partidaActual`: ID de la partida.
  /// - `equipoId`: Identificador del equipo a eliminar.
  /// -------------------------------------------------------------------------
  Future<void> eliminarEquipo(String partidaActual, String equipoId) async {
    final equipoRef = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId');

    final snapshot = await equipoRef.get();
    if (snapshot.exists) {
      await equipoRef.remove();
      await _eliminarEquipoId();
      debugPrint('🗑️ Equipo eliminado con éxito: $equipoId');
    } else {
      debugPrint('⚠️ El equipo no existe y no se puede eliminar.');
    }
  }

  /// -------------------------------------------------------------------------
  /// Elimina todos los equipos registrados en una partida.
  ///
  /// También elimina el ID del equipo en `SharedPreferences`.
  ///
  /// ### Parámetro:
  /// - `partidaActual`: ID de la partida de la cual se eliminarán todos los equipos.
  /// -------------------------------------------------------------------------
  Future<void> eliminarTodosLosEquipos(String partidaActual) async {
    final equiposRef = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS');

    final snapshot = await equiposRef.get();
    if (snapshot.exists) {
      await equiposRef.remove();
      await _eliminarEquipoId();
      debugPrint('🗑️ Todos los equipos de la partida $partidaActual han sido eliminados.');
    } else {
      debugPrint('⚠️ No hay equipos para eliminar en la partida $partidaActual.');
    }
  }

  /// -------------------------------------------------------------------------
  /// Elimina el ID del equipo almacenado localmente en `SharedPreferences`.
  ///
  /// ### Nota:
  /// Asegúrate de que el identificador se haya guardado previamente con la
  /// clave `'equipoId'`.
  /// -------------------------------------------------------------------------
  Future<void> _eliminarEquipoId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipoId');
  }
}
