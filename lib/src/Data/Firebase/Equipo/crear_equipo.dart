import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de la gestión de equipos en Firebase Realtime Database.
class CrearEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  CrearEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para crear los cuatro equipos dentro de una partida específica.
  Future<void> crearEquipos(String partidaActual) async {
    _dbRef.child('Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS');

    for (int i = 1; i <= 4; i++) {
      String equipoId = 'EQUIPO $i';
      await crearEquipoEspecifico(partidaActual, equipoId);
    }
  }

  /// Método para crear un equipo específico dentro de una partida.
  Future<void> crearEquipoEspecifico(String partidaActual, String equipoId) async {
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId',
    );

    DataSnapshot snapshot = await equipoRef.get();
    if (!snapshot.exists) {
      await equipoRef.set(_crearPlantillaEquipo());
      await _guardarEquipoId(equipoId);
      debugPrint('Equipo creado con éxito: $equipoId');
    } else {
      debugPrint('El equipo $equipoId ya existe.');
    }
  }

  /// Método para eliminar un equipo de una partida específica.
  Future<void> eliminarEquipo(String partidaActual, String equipoId) async {
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId',
    );

    await equipoRef.remove();
    debugPrint('Equipo eliminado: $equipoId');
  }

  /// Guarda el ID del equipo en SharedPreferences.
  Future<void> _guardarEquipoId(String equipoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipoId', equipoId);
  }

  /// Retorna la estructura base de un equipo basada en la plantilla.
  Map<String, dynamic> _crearPlantillaEquipo() {
    return {
      'CODIGO': '',
      'ESTADO TURNO': '',
      'NOMBRE': '',
      'PUESTO': '',
      'PUNTOS': '',
      'SECTOR': '',
      'EMPRESA': '',
      'FUERZAS': {
        'PODER DE NEGOCIACION DE COMPRADORES': {'NIVEL': ''},
        'PODER DE NEGOCIACION DE PROVEEDORES': {'NIVEL': ''},
        'POTENCIALES COMPETIDORES': {'NIVEL': ''},
        'PRODUCTOS SUSTITUTOS': {'NIVEL': ''},
        'RIVALIDAD ENTRE COMPETIDORES': {'NIVEL': ''},
      },
    };
  }
}
