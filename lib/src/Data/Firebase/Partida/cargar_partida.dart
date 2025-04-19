// cargar_partida.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # CargarPartida
///
/// **Clase encargada de obtener desde Firebase la clave de la partida
/// actual previamente almacenada en `SharedPreferences`.**
///
/// Esta clase permite validar si la clave almacenada localmente corresponde
/// a una partida activa en la base de datos.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class CargarPartida {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// Identificador de la partida actual (clave de Firebase).
  String? _partidaId;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `CargarPartida`.
  ///
  /// Inicializa la conexión con Firebase Realtime Database.
  /// -------------------------------------------------------------------------
  CargarPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Getter para obtener el identificador de la partida actual.
  ///
  /// Devuelve el valor de `_partidaId`, el cual puede ser `null` si
  /// no se ha cargado correctamente.
  /// -------------------------------------------------------------------------
  String? get partidaId => _partidaId;

  /// -------------------------------------------------------------------------
  /// Método asincrónico para cargar la clave de la partida desde almacenamiento
  /// local (`SharedPreferences`) y verificar su existencia en Firebase.
  ///
  /// Si la clave existe en Firebase, se guarda en la variable `_partidaId`.
  /// Si no existe o no hay clave guardada, se registra en consola.
  ///
  /// ### Flujo:
  /// - Lee el valor `partidaId` desde `SharedPreferences`.
  /// - Valida que exista una partida en Firebase con dicha clave.
  /// - Asigna el valor a `_partidaId` si es válido.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// final partida = CargarPartida();
  /// await partida.cargarClavePartida();
  /// String? id = partida.partidaId;
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> cargarClavePartida() async {
    final prefs = await SharedPreferences.getInstance();
    String? partidaId = prefs.getString('partidaId');

    if (partidaId != null) {
      final DatabaseReference partidaRef = _dbRef.child('Five Force Competence/PARTIDAS/$partidaId');

      DataSnapshot snapshot = await partidaRef.get();
      if (snapshot.exists) {
        _partidaId = partidaId;
        debugPrint('Clave de la partida cargada con éxito: $_partidaId');
      } else {
        debugPrint('La partida con clave $partidaId no existe en Firebase.');
        _partidaId = null;
      }
    } else {
      debugPrint('No hay una clave de partida guardada en SharedPreferences.');
      _partidaId = null;
    }
  }
}
