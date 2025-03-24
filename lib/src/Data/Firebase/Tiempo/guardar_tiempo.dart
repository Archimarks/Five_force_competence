import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Clase para gestionar la selección del tiempo en Firebase**
class GuardarTiempo {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// **Obtiene la partida guardada desde SharedPreferences**
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('partidaId'); // Se usa la clave correcta
  }

  /// **Guarda la selección en Firebase en la partida actual**
  Future<void> guardarSeleccion(String? seleccion) async {
    String? partidaActual = await obtenerPartidaGuardada();

    if (partidaActual == null || partidaActual.isEmpty) {
      debugPrint('❌ Error: No se encontró una partida guardada.');
      return;
    }

    try {
      DatabaseReference ref = _dbRef.child(
        'Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/TIEMPO TURNO',
      );

      await ref
          .set(seleccion)
          .then((_) {
            debugPrint('✅ Selección guardada en Firebase: $seleccion');
          })
          .catchError((error) {
            debugPrint('❌ Error al guardar en Firebase: $error');
          });
    } catch (e) {
      debugPrint('❌ Excepción atrapada: $e');
    }
  }
}
