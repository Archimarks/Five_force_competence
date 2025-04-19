// equipo_codigo.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # EquipoCodigo
///
/// **Clase responsable de buscar un equipo por su código único en todas
/// las partidas registradas en Firebase Realtime Database.**
///
/// Si se encuentra el equipo con el código buscado, guarda sus datos clave
/// localmente usando `SharedPreferences` para su posterior uso dentro de la app.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class EquipoCodigo {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `EquipoCodigo`.
  ///
  /// Inicializa la referencia a la raíz de la base de datos.
  /// -------------------------------------------------------------------------
  EquipoCodigo() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Busca un equipo por su código único en todas las partidas registradas.
  ///
  /// Si encuentra un equipo con el `codigoBuscado`, guarda sus datos y
  /// los niveles de sus fuerzas en `SharedPreferences`.
  ///
  /// ### Parámetro:
  /// - `codigoBuscado`: Código único del equipo que se desea encontrar.
  ///
  /// ### Acciones:
  /// - Recorre todas las partidas y sus equipos.
  /// - Compara el valor del campo `'CODIGO'` con el código buscado.
  /// - Si lo encuentra, guarda los datos relevantes localmente.
  /// -------------------------------------------------------------------------
  Future<void> buscarYGuardarDatosPorCodigo(String codigoBuscado) async {
    try {
      final partidasSnapshot = await _dbRef.child('Five Force Competence/PARTIDAS').get();

      if (partidasSnapshot.exists) {
        final Map partidas = partidasSnapshot.value as Map;

        for (final partidaKey in partidas.keys) {
          final partida = partidas[partidaKey];
          if (partida['EQUIPOS'] != null) {
            final equipos = partida['EQUIPOS'] as Map;

            for (final equipoKey in equipos.keys) {
              final equipo = equipos[equipoKey] as Map;

              if (equipo['CODIGO'] == codigoBuscado) {
                await _guardarEnSharedPreferences(equipo: equipo, equipoKey: equipoKey, partidaKey: partidaKey);
                debugPrint('✅ Datos del equipo guardados exitosamente.');
                return;
              }
            }
          }
        }
      }

      debugPrint('❌ No se encontró ningún equipo con el código $codigoBuscado');
    } catch (e) {
      debugPrint('❗ Error al buscar y guardar datos del equipo: $e');
    }
  }

  /// -------------------------------------------------------------------------
  /// Guarda en `SharedPreferences` los datos del equipo encontrado.
  ///
  /// Incluye campos como:
  /// - Código, estado del turno, puesto, puntos, color, empresa.
  /// - Nivel de cada una de las cinco fuerzas.
  ///
  /// ### Parámetros:
  /// - `equipo`: Mapa con la información del equipo.
  /// - `equipoKey`: ID del equipo dentro de Firebase.
  /// - `partidaKey`: ID de la partida donde fue encontrado.
  /// -------------------------------------------------------------------------
  Future<void> _guardarEnSharedPreferences({required Map equipo, required String equipoKey, required String partidaKey}) async {
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

    await prefs.setString('PODER DE NEGOCIACION DE COMPRADORES', fuerzas['PODER DE NEGOCIACION DE COMPRADORES']?['NIVEL'] ?? '');
    await prefs.setString('PODER DE NEGOCIACION DE PROVEEDORES', fuerzas['PODER DE NEGOCIACION DE PROVEEDORES']?['NIVEL'] ?? '');
    await prefs.setString('POTENCIALES COMPETIDORES', fuerzas['POTENCIALES COMPETIDORES']?['NIVEL'] ?? '');
    await prefs.setString('PRODUCTOS SUSTITUTOS', fuerzas['PRODUCTOS SUSTITUTOS']?['NIVEL'] ?? '');
    await prefs.setString('RIVALIDAD ENTRE COMPETIDORES', fuerzas['RIVALIDAD ENTRE COMPETIDORES']?['NIVEL'] ?? '');
  }
}
