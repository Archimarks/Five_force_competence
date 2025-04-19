import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # TraerTodasEmpresas
///
/// **Clase encargada de obtener todas las empresas desde Firebase Realtime Database,**
/// en función del sector previamente guardado en `SharedPreferences`.
///
/// Esta clase centraliza la lógica de acceso a la base de datos de Firebase
/// para recuperar la información de las empresas relacionadas con un sector
/// específico.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class TraerTodasEmpresas {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `TraerTodasEmpresas`.
  ///
  /// Inicializa la referencia a la base de datos utilizando la instancia global
  /// de `FirebaseDatabase`.
  /// -------------------------------------------------------------------------
  TraerTodasEmpresas() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene el sector guardado previamente desde `SharedPreferences`.
  ///
  /// Devuelve el nombre del sector almacenado bajo la clave `'sectorSeleccionado'`.
  /// Si no se encuentra ningún valor, retorna `null`.
  ///
  /// ### Ejemplo de clave en `SharedPreferences`:
  /// `'sectorSeleccionado': 'Sector A'`
  /// -------------------------------------------------------------------------
  Future<String?> obtenerSectorGuardado() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sectorSeleccionado'); // Clave corregida
  }

  /// -------------------------------------------------------------------------
  /// Obtiene todas las empresas del sector actual desde Firebase.
  ///
  /// Este método primero consulta el sector actualmente guardado en
  /// `SharedPreferences`, y luego accede a la ruta:
  ///
  /// `/Five Force Competence/DATOS PERSISTENTES/SECTORES/{sector}/EMPRESAS`
  ///
  /// Si encuentra empresas, las devuelve como un `Map<String, dynamic>`.
  /// En caso contrario, retorna un mapa vacío.
  ///
  /// ### Manejo de errores:
  /// - Imprime mensajes de depuración si no hay sector o si ocurre un error.
  ///
  /// ### Retorna:
  /// `Map<String, dynamic>` con los datos de las empresas o `{}` si no hay datos.
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>> obtenerEmpresas() async {
    String? sectorActual = await obtenerSectorGuardado();

    if (sectorActual == null) {
      debugPrint('❌ No se encontró un sector guardado en SharedPreferences.');
      return {};
    }

    final DatabaseReference empresasRef = _dbRef.child('/Five Force Competence/DATOS PERSISTENTES/SECTORES/$sectorActual/EMPRESAS');

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
