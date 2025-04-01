import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de la gestión de equipos en Firebase Realtime Database.
class CrearEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  CrearEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para crear un equipo con el siguiente identificador disponible dentro de una partida,
  /// con un límite máximo de 4 equipos.
  Future<void> crearEquipoDisponible(String partidaActual) async {
    int equipoId = 1;
    // Verificar si ya existen 4 equipos
    if (await _contarEquipos(partidaActual) >= 4) {
      debugPrint('Límite de equipos alcanzado (máximo 4). No se puede crear más.');
      return;
    }

    while (await _equipoExiste(partidaActual, 'EQUIPO $equipoId')) {
      equipoId++;
      // Asegurarse de no intentar crear más de 4 equipos
      if (equipoId > 4) {
        debugPrint('No se pudo encontrar un ID disponible dentro del límite de 4 equipos.');
        return;
      }
    }
    await crearEquipoEspecifico(partidaActual, 'EQUIPO $equipoId');
  }

  /// Método para verificar si un equipo ya existe en la partida.
  Future<bool> _equipoExiste(String partidaActual, String equipoId) async {
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId',
    );
    DataSnapshot snapshot = await equipoRef.get();
    return snapshot.exists;
  }

  /// Método para contar la cantidad de equipos existentes en la partida.
  Future<int> _contarEquipos(String partidaActual) async {
    final DatabaseReference equiposRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS',
    );
    DataSnapshot snapshot = await equiposRef.get();
    if (snapshot.value != null && snapshot.value is Map) {
      return (snapshot.value as Map).length;
    }
    return 0;
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
    await prefs.setString('EQUIPO', equipoId);
  }

  /// Retorna la estructura base de un equipo basada en la plantilla.
  Map<String, dynamic> _crearPlantillaEquipo() {
    return {
      'CODIGO': '',
      'ESTADO TURNO': '',
      'NOMBRE': '',
      'PUESTO': '',
      'PUNTOS': '',
      'COLOR': '',
      'EMPRESA': '',
      'FUERZAS': {
        'PODER DE NEGOCIACION DE COMPRADORES': {'NIVEL': ''},
        'PODER DE NEGOCIACION DE PROVEEDORES': {'NIVEL': ''},
        'POTENCIALES COMPETIDORES': {'NIVEL': ''},
        'PRODUCTOS SUSTITUTOS': {'NIVEL': ''},
        'RIVALIDAD ENTRE COMPETIDORES': {'NIVEL': ''},
      },
      'TABLERO': {
        'FUERZA': '',
        'VALOR INICIAL X': '',
        'VALOR INICIAL Y': '',
        'CUADRANTE A': {
          'ENTIDAD': {
            'DIRECCION': '',
            'ESTADO': '',
            'NOMBRE': '',
            'PINES': '',
            'POS 1': '',
            'POS 2': '',
            'POS 3': '',
            'POS 4': '',
            'POS 5': '',
            'PUNTOS': '',
            'PUNTOS ATAQUE': '',
          },
          'CELDA 0 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
        },
        'CUADRANTE B': {
          'ENTIDAD': {
            'DIRECCION': '',
            'ESTADO': '',
            'NOMBRE': '',
            'PINES': '',
            'POS 1': '',
            'POS 2': '',
            'POS 3': '',
            'POS 4': '',
            'POS 5': '',
            'PUNTOS': '',
            'PUNTOS ATAQUE': '',
          },
          'CELDA 0 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 0 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 1 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 2 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
        },
        'CUADRANTE C': {
          'ENTIDAD': {
            'DIRECCION': '',
            'ESTADO': '',
            'NOMBRE': '',
            'PINES': '',
            'POS 1': '',
            'POS 2': '',
            'POS 3': '',
            'POS 4': '',
            'POS 5': '',
            'PUNTOS': '',
            'PUNTOS ATAQUE': '',
          },
          'CELDA 6 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 0': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 1': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 2': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 11 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
        },
        'CUADRANTE D': {
          'ENTIDAD': {
            'DIRECCION': '',
            'ESTADO': '',
            'NOMBRE': '',
            'PINES': '',
            'POS 1': '',
            'POS 2': '',
            'POS 3': '',
            'POS 4': '',
            'POS 5': '',
            'PUNTOS': '',
            'PUNTOS ATAQUE': '',
          },
          'CELDA 6 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 8 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 9 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 9': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 10': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 10 11': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
        },
        'CUADRANTE E': {
          'ENTIDAD': {
            'DIRECCION': '',
            'ESTADO': '',
            'NOMBRE': '',
            'PINES': '',
            'POS 1': '',
            'POS 2': '',
            'POS 3': '',
            'POS 4': '',
            'POS 5': '',
            'PUNTOS': '',
            'PUNTOS ATAQUE': '',
          },
          'CELDA 3 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 3 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 4 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 5 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 6 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 3': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 4': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 5': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 6': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 7': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
          'CELDA 7 8': {'COMODIN': '', 'EQUIPO ACCION': '', 'ESTADO': '', 'PUNTO': ''},
        },
      },
    };
  }
}
