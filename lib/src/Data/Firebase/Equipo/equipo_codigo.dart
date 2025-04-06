// equipo_codigo.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase encargada de buscar un equipo por su código en todas las partidas y guardar sus datos localmente.
class EquipoCodigo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  EquipoCodigo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Busca en todas las partidas un equipo que tenga el código proporcionado.
  /// Si lo encuentra, guarda los datos especificados en SharedPreferences.
  Future<void> buscarYGuardarDatosPorCodigo(String codigoBuscado) async {
    try {
      final DataSnapshot partidasSnapshot =
          await _dbRef.child('Five Force Competence/PARTIDAS').get();

      if (partidasSnapshot.exists) {
        final Map partidas = partidasSnapshot.value as Map;

        for (final partidaKey in partidas.keys) {
          final partida = partidas[partidaKey];
          if (partida['EQUIPOS'] != null) {
            final equipos = partida['EQUIPOS'] as Map;

            for (final equipoKey in equipos.keys) {
              final equipo = equipos[equipoKey] as Map;

              if (equipo['CODIGO'] == codigoBuscado) {
                await _guardarEnSharedPreferences(
                  equipo: equipo,
                  equipoKey: equipoKey,
                  partidaKey: partidaKey,
                );
                debugPrint('Datos del equipo guardados exitosamente.');
                return;
              }
            }
          }
        }
      }

      debugPrint('No se encontró ningún equipo con el código $codigoBuscado');
    } catch (e) {
      debugPrint('Error al buscar y guardar datos del equipo: $e');
    }
  }

  /// Guarda los datos del equipo en SharedPreferences.
  Future<void> _guardarEnSharedPreferences({
    required Map equipo,
    required String equipoKey,
    required String partidaKey,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('EQUIPO', equipoKey);
    await prefs.setString('partidaId', partidaKey);
    await prefs.setString('CODIGO', equipo['CODIGO'] ?? '');
    await prefs.setString('ESTADO TURNO', equipo['ESTADO TURNO'] ?? '');
    await prefs.setString('PUESTO', equipo['PUESTO']?.toString() ?? '');
    await prefs.setString('PUNTOS', equipo['PUNTOS']?.toString() ?? '');
    await prefs.setString('COLOR', equipo['COLOR'] ?? '');
    await prefs.setString('EMPRESA', equipo['EMPRESA'] ?? '');

    final fuerzas = equipo['FUERZAS'] as Map? ?? {};
    await prefs.setString(
      'PODER DE NEGOCIACION DE COMPRADORES',
      fuerzas['PODER DE NEGOCIACION DE COMPRADORES']?['NIVEL'] ?? '',
    );
    await prefs.setString(
      'PODER DE NEGOCIACION DE PROVEEDORES',
      fuerzas['PODER DE NEGOCIACION DE PROVEEDORES']?['NIVEL'] ?? '',
    );
    await prefs.setString(
      'POTENCIALES COMPETIDORES',
      fuerzas['POTENCIALES COMPETIDORES']?['NIVEL'] ?? '',
    );
    await prefs.setString('PRODUCTOS SUSTITUTOS', fuerzas['PRODUCTOS SUSTITUTOS']?['NIVEL'] ?? '');
    await prefs.setString(
      'RIVALIDAD ENTRE COMPETIDORES',
      fuerzas['RIVALIDAD ENTRE COMPETIDORES']?['NIVEL'] ?? '',
    );
  }
}
