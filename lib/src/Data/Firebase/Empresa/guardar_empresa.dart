import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------------------------
/// # TraerTodosSectores
///
/// **Clase encargada de traer todos los sectores desde Firebase Realtime Database.**
///
/// Esta clase consulta Firebase utilizando la partida activa guardada localmente
/// para obtener la configuración de sectores asociados.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class TraerTodosSectores {
  /// Referencia principal a la base de datos de Firebase.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `TraerTodosSectores`.
  ///
  /// Inicializa la instancia de la base de datos para realizar las consultas
  /// en tiempo real.
  /// -------------------------------------------------------------------------
  TraerTodosSectores() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Obtiene el ID de la partida guardada en `SharedPreferences`.
  ///
  /// Este valor es necesario para construir la ruta dentro de Firebase
  /// donde se encuentran los datos de configuración del juego.
  ///
  /// ### Clave esperada:
  /// `'partidaId'`
  ///
  /// ### Retorna:
  /// - `String?`: ID de la partida actual o `null` si no existe.
  /// -------------------------------------------------------------------------
  Future<String?> obtenerPartidaGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('partidaId'); // Se usa la clave correcta
  }

  /// -------------------------------------------------------------------------
  /// Obtiene el sector guardado desde `SharedPreferences`.
  ///
  /// Aunque este valor no se utiliza directamente en este archivo, se deja
  /// disponible para posibles validaciones o filtros futuros.
  ///
  /// ### Clave esperada:
  /// `'sectorSeleccionado'`
  ///
  /// ### Retorna:
  /// - `String?`: Nombre del sector actual o `null` si no existe.
  /// -------------------------------------------------------------------------
  Future<String?> obtenerSectorGuardada() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('sectorSeleccionado'); // Se usa la clave correcta
  }

  /// -------------------------------------------------------------------------
  /// Obtiene los sectores configurados en la partida actual desde Firebase.
  ///
  /// Utiliza el ID de la partida actual para acceder a la ruta:
  ///
  /// `Five Force Competence/PARTIDAS/{partidaId}/CONFIGURACIONES/SECTOR`
  ///
  /// Si se encuentran datos en esa ubicación, se retorna un mapa con los sectores.
  /// En caso contrario, devuelve `null` e imprime un mensaje de depuración.
  ///
  /// ### Manejo de errores:
  /// - Captura excepciones al consultar Firebase.
  /// - Imprime errores o advertencias si la ruta no contiene datos válidos.
  ///
  /// ### Retorna:
  /// - `Map<String, dynamic>?`: Mapa con los sectores o `null` si no existen.
  /// -------------------------------------------------------------------------
  Future<Map<String, dynamic>?> obtenerEmpresa() async {
    String? partidaActual = await obtenerPartidaGuardada();

    final DatabaseReference sectoresRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/CONFIGURACIONES/SECTOR',
    );

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        debugPrint('⚠️ No se encontraron sectores en la base de datos.');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error al obtener los sectores: $e');
      return null;
    }
  }
}
