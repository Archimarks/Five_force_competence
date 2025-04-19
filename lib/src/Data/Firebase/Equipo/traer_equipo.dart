// gestion_equipo.dart

import 'package:firebase_database/firebase_database.dart';

/// ---------------------------------------------------------------------------
/// # GestionEquipo
///
/// **Clase encargada de gestionar la consulta de equipos dentro de una
/// partida específica en Firebase Realtime Database.**
///
/// Permite obtener la lista completa de equipos o consultar un equipo
/// individual por su código identificador.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class GestionEquipo {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `GestionEquipo`.
  ///
  /// Inicializa la conexión a la base de datos.
  /// -------------------------------------------------------------------------
  GestionEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene todos los equipos asociados a una partida específica.
  ///
  /// ### Parámetro:
  /// - `partidaActual`: ID de la partida de la cual se desean obtener los equipos.
  ///
  /// ### Retorna:
  /// - Un `Map<String, dynamic>` con los equipos si existen.
  /// - `null` si no se encontraron equipos.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final equipos = await gestionEquipo.obtenerEquipos('partida_123');
  /// ```
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerEquipos(String partidaActual) async {
    final DatabaseReference equiposRef = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS');
    DataSnapshot snapshot = await equiposRef.get();

    if (snapshot.value != null && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null; // No hay equipos en la partida
  }

  /// -------------------------------------------------------------------------
  /// Obtiene los datos de un equipo específico dentro de una partida.
  ///
  /// ### Parámetros:
  /// - `partidaActual`: ID de la partida.
  /// - `equipoCodigo`: Clave única del equipo dentro de esa partida.
  ///
  /// ### Retorna:
  /// - Un `Map<String, dynamic>` con la información del equipo si existe.
  /// - `null` si el equipo no fue encontrado.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final equipo = await gestionEquipo.obtenerEquipoPorCodigo('partida_123', 'equipo_001');
  /// ```
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerEquipoPorCodigo(String partidaActual, String equipoCodigo) async {
    final DatabaseReference equipoRef = _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoCodigo');
    DataSnapshot snapshot = await equipoRef.get();

    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null; // El equipo no existe
  }
}
