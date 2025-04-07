// crear_partida.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # CrearPartida
///
/// **Clase encargada de la creación de partidas dentro de Firebase
/// Realtime Database.**
///
/// Este módulo se encarga de generar dinámicamente una nueva partida bajo
/// un identificador único dentro de un rango predefinido, evitando
/// colisiones con partidas existentes y almacenando el ID de la partida
/// creada en `SharedPreferences`.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class CrearPartida {
  /// Referencia raíz a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor que inicializa la conexión con Firebase.
  /// -------------------------------------------------------------------------
  CrearPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Método para crear una nueva partida asegurando un identificador único.
  ///
  /// Intenta generar una partida con IDs del tipo `PARTIDA 1` hasta `PARTIDA 10`.
  /// Si encuentra un ID disponible (sin colisión), crea la partida usando una
  /// plantilla base y guarda el ID en `SharedPreferences`.
  ///
  /// ### Lógica:
  /// - Itera del 1 al 10 buscando el primer `partidaId` disponible.
  /// - Crea la partida si no existe.
  /// - Registra el `partidaId` en persistencia local.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final crearPartida = CrearPartida();
  /// await crearPartida.crearNuevaPartida();
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> crearNuevaPartida() async {
    final DatabaseReference partidasRef = _dbRef.child('Five Force Competence/PARTIDAS');

    for (int i = 1; i <= 10; i++) {
      String partidaId = 'PARTIDA $i';
      DatabaseReference partidaRef = partidasRef.child(partidaId);

      DataSnapshot snapshot = await partidaRef.get();
      if (!snapshot.exists) {
        await partidaRef.set(_crearPlantillaPartida());

        // Guardar partidaId de forma persistente
        await _guardarPartidaId(partidaId);

        debugPrint('Partida creada con éxito: $partidaId');
        return;
      }
    }

    debugPrint('No se pudo crear la partida. Todos los slots están ocupados.');
  }

  /// -------------------------------------------------------------------------
  /// Método privado para guardar el ID de la partida en `SharedPreferences`.
  ///
  /// Se utiliza para que el ID esté disponible localmente en otras vistas
  /// o controladores del juego.
  ///
  /// - [partidaId]: Identificador de la partida a almacenar.
  /// -------------------------------------------------------------------------
  Future<void> _guardarPartidaId(String partidaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partidaId', partidaId);
  }

  /// -------------------------------------------------------------------------
  /// Método privado que retorna la plantilla base de una partida nueva.
  ///
  /// Esta estructura inicializa las configuraciones del juego y define
  /// los contenedores de equipos vacíos.
  ///
  /// ### Estructura generada:
  /// ```json
  /// {
  ///   "TURNO": "",
  ///   "CONFIGURACIONES": {
  ///     "SECTOR": "",
  ///     "ESTADO": "ACTIVO",
  ///     "TIEMPO TURNO": 0,
  ///     "CANTIDAD COMODINES": 2
  ///   },
  ///   "EQUIPOS": {}
  /// }
  /// ```
  /// -------------------------------------------------------------------------
  Map<String, dynamic> _crearPlantillaPartida() {
    return {
      'TURNO': '',
      'CONFIGURACIONES': {
        'SECTOR': '',
        'ESTADO': 'ACTIVO',
        'TIEMPO TURNO': 0,
        'CANTIDAD COMODINES': 2,
      },
      'EQUIPOS': {},
    };
  }
}
