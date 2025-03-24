import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Clase para gestionar la selección del sector en Firebase y SharedPreferences**
class GuardarSector {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// **Obtiene la partida guardada desde SharedPreferences**
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? partida = prefs.getString('partidaId');
    debugPrint('📌 Partida obtenida: $partida');
    return partida;
  }

  /// **Guarda la selección del sector en Firebase y SharedPreferences**
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
      DatabaseReference ref = _dbRef.child(
        'Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/SECTOR',
      );

      await ref.set(seleccion);
      debugPrint('✅ Sector guardado en Firebase correctamente: $seleccion');

      // Verificar si se guardó correctamente en Firebase
      String? guardado = (await ref.get()).value as String?;
      debugPrint('🔍 Sector guardado en Firebase (verificado): $guardado');
    } catch (e) {
      debugPrint('❌ Error al guardar en Firebase: $e');
    }
  }

  /// **Obtiene la selección del sector guardada en SharedPreferences**
  Future<String?> obtenerSectorSeleccionado() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sector = prefs.getString('sectorSeleccionado');
    debugPrint('📌 Sector obtenido de SharedPreferences: $sector');
    return sector;
  }
}
