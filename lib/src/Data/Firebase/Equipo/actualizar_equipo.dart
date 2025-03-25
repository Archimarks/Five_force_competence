import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Clase encargada de la actualización de los datos de un equipo en Firebase Realtime Database.
class ActualizarEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  ActualizarEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para actualizar los campos EMPRESA, COLOR y CODIGO de un equipo.
  Future<void> actualizarPreGame(
    String partidaActual,
    String equipoId,
    String empresa,
    String color,
  ) async {
    // Verificar si equipoId tiene al menos un espacio
    if (!equipoId.contains(' ')) {
      throw const FormatException(
        'El equipoId no tiene el formato esperado. Se requiere un espacio en el ID.',
      );
    }

    // Extrayendo el último número del equipoId
    int ultimoNumeroEquipo = int.parse(equipoId.split(' ')[1]);

    // Generando un código de 4 dígitos donde el primer número es el último número del equipoId
    String codigo = '$ultimoNumeroEquipo${_generarCodigoAleatorio(3)}';

    // Refiriéndonos a la ruta del equipo específico
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/$equipoId',
    );

    // Actualizando los datos en Firebase
    await equipoRef.update({'EMPRESA': empresa, 'COLOR': color, 'CODIGO': codigo});

    debugPrint('Equipo actualizado: $equipoId con CODIGO $codigo, EMPRESA $empresa y COLOR $color');
  }

  /// Método para generar un número aleatorio con una cantidad específica de dígitos.
  String _generarCodigoAleatorio(int cantidad) {
    final random = Random();
    String codigo = '';
    for (int i = 0; i < cantidad; i++) {
      codigo += random.nextInt(10).toString(); // Genera un dígito aleatorio entre 0 y 9
    }
    return codigo;
  }
}
