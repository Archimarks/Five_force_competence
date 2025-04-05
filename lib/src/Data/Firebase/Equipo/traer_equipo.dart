import 'package:firebase_database/firebase_database.dart';

/// Clase encargada de la gestión de equipos en Firebase Realtime Database.
class GestionEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  GestionEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para obtener todos los equipos de una partida específica.
  Future<Map<String, dynamic>?> obtenerEquipos(String partidaActual) async {
    final DatabaseReference equiposRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS',
    );
    DataSnapshot snapshot = await equiposRef.get();

    if (snapshot.value != null && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null; // No hay equipos en la partida
  }

  /// Método para obtener un equipo específico dentro de una partida dado su código.
  Future<Map<String, dynamic>?> obtenerEquipoPorCodigo(
    String partidaActual,
    String equipoCodigo,
  ) async {
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoCodigo',
    );
    DataSnapshot snapshot = await equipoRef.get();

    if (snapshot.exists && snapshot.value != null) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null; // El equipo no existe
  }
}
