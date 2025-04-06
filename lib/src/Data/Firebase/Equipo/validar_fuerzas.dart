import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Clase encargada de validar las fuerzas seleccionadas por el equipo
/// contra las fuerzas correctas almacenadas en Firebase.
class ValidarFuerzas {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  ValidarFuerzas() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para validar las respuestas de un equipo con respecto a las fuerzas reales
  /// y guardar el resultado en Firebase como 'ACERTÓ' o 'NO ACERTÓ'.
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
      final DataSnapshot snapshot = await fuerzasRef.get();

      if (!snapshot.exists) {
        debugPrint('No se encontraron fuerzas para $equipo en la partida $partidaActual');
        return;
      }

      final Map<String, dynamic> fuerzasCorrectas = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

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

      await respuestaRef.set(resultado);
      await estadoTurnoRef.set('INACTIVO');

      debugPrint('Respuestas guardadas correctamente. ESTADO TURNO actualizado a INACTIVO.');
    } catch (e) {
      debugPrint('Error al validar las respuestas: $e');
    }
  }
}
