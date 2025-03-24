import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **Clase encargada de obtener todas las empresas desde Firebase Realtime Database.**
class TraerTodasEmpresas {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  TraerTodasEmpresas() : _dbRef = FirebaseDatabase.instance.ref();

  /// **Obtiene el sector guardado desde SharedPreferences.**
  Future<String?> obtenerSectorGuardado() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sectorSeleccionado'); // Clave corregida
  }

  /// **Obtiene todas las empresas desde Firebase en función del sector guardado.**
  Future<Map<String, dynamic>> obtenerEmpresas() async {
    String? sectorActual = await obtenerSectorGuardado();

    if (sectorActual == null) {
      debugPrint('❌ No se encontró un sector guardado en SharedPreferences.');
      return {};
    }

    final DatabaseReference empresasRef = _dbRef.child(
      '/Five Force Competence/DATOS PERSISTENTES/SECTORES/$sectorActual/EMPRESAS',
    );

    try {
      DataSnapshot snapshot = await empresasRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('⚠️ No se encontraron empresas en Firebase para el sector "$sectorActual".');
        return {};
      }
    } catch (e) {
      debugPrint('❌ Error al obtener las empresas: $e');
      return {};
    }
  }
}
