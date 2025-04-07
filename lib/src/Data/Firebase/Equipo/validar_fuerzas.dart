// validar_fuerzas.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// # ValidarFuerzas
///
/// **Clase encargada de validar las fuerzas seleccionadas por un equipo
/// en la interfaz contra las fuerzas correctas definidas en Firebase.**
///
/// Además, guarda los resultados de la comparación en la base de datos
/// bajo el nodo `RESPUESTA FUERZAS`, e inactiva el estado del turno del equipo.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class ValidarFuerzas {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `ValidarFuerzas`.
  ///
  /// Inicializa la conexión con la base de datos.
  /// -------------------------------------------------------------------------
  ValidarFuerzas() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Valida las respuestas seleccionadas por un equipo comparándolas con
  /// las respuestas correctas almacenadas en Firebase.
  ///
  /// ### Parámetros:
  /// - `partidaActual`: ID de la partida actual.
  /// - `equipo`: ID del equipo que responde.
  /// - `respuestasUsuario`: Lista de respuestas seleccionadas por el usuario,
  ///   en el mismo orden que las claves definidas.
  ///
  /// ### Flujo:
  /// - Compara cada fuerza seleccionada por el usuario con la respuesta correcta.
  /// - Guarda en Firebase si el usuario 'ACERTÓ' o 'NO ACERTÓ' en cada fuerza.
  /// - Cambia el estado del turno del equipo a 'INACTIVO'.
  ///
  /// ### Ejemplo de uso:
  /// ```dart
  /// await validarFuerzas.validarSeleccionUsuario(
  ///   partidaActual: 'partida_123',
  ///   equipo: 'equipo_abc',
  ///   respuestasUsuario: ['ALTO', 'BAJO', 'MEDIO', 'BAJO', 'ALTO'],
  /// );
  /// ```
  /// -------------------------------------------------------------------------
  Future<void> validarSeleccionUsuario({
    required String partidaActual,
    required String equipo,
    required List<String?> respuestasUsuario,
  }) async {
    final String basePath = 'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipo';

    final DatabaseReference fuerzasRef = _dbRef.child('$basePath/FUERZAS');
    final DatabaseReference respuestaRef = _dbRef.child('$basePath/RESPUESTA FUERZAS');
    final DatabaseReference estadoTurnoRef = _dbRef.child('$basePath/ESTADO TURNO');

    try {
      // Obtener fuerzas correctas desde Firebase
      final DataSnapshot snapshot = await fuerzasRef.get();

      if (!snapshot.exists) {
        debugPrint('No se encontraron fuerzas para $equipo en la partida $partidaActual');
        return;
      }

      final Map<String, dynamic> fuerzasCorrectas = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      // Claves a validar
      final List<String> claves = [
        'PODER DE NEGOCIACION DE COMPRADORES',
        'PODER DE NEGOCIACION DE PROVEEDORES',
        'POTENCIALES COMPETIDORES',
        'PRODUCTOS SUSTITUTOS',
        'RIVALIDAD ENTRE COMPETIDORES',
      ];

      final Map<String, String> resultado = {};

      for (int i = 0; i < claves.length; i++) {
        final clave = claves[i];
        final respuestaUsuario = respuestasUsuario[i];
        final respuestaCorrecta = fuerzasCorrectas[clave];

        final estado = (respuestaUsuario == respuestaCorrecta) ? 'ACERTÓ' : 'NO ACERTÓ';
        resultado['RESPUESTA $clave'] = estado;

        debugPrint(
          'Comparando $clave: usuario="$respuestaUsuario", correcto="$respuestaCorrecta" => $estado',
        );
      }

      // Guardar resultado en Firebase y desactivar turno
      await respuestaRef.set(resultado);
      await estadoTurnoRef.set('INACTIVO');

      debugPrint('Respuestas guardadas correctamente. ESTADO TURNO actualizado a INACTIVO.');
    } catch (e) {
      debugPrint('Error al validar las respuestas: $e');
    }
  }
}
