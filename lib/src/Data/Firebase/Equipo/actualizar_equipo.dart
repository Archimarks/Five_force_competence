import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Clase encargada de la actualización de los datos de un equipo en Firebase Realtime Database.
class ActualizarEquipo {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  ActualizarEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para actualizar los campos EMPRESA, COLOR y CODIGO de un equipo,
  /// y copiar las fuerzas de la empresa seleccionada al equipo.
  Future<void> actualizarPreGame(
    String partidaActual,
    int equipoId,
    String empresa,
    String color,
    String sector,
  ) async {
    // Asegurando que partidaActual solo contenga números
    String numeroPartida = partidaActual.replaceAll(RegExp(r'\D'), '');
    // Generando un código donde el primer número es el de la partidaActual, seguido del último dígito del equipoId y dos dígitos aleatorios
    String codigo = '$numeroPartida${equipoId % 10}${_generarCodigoAleatorio(2)}';

    // Refiriéndonos a la ruta del equipo específico
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/EQUIPO $equipoId',
    );

    // Actualizando los datos en Firebase
    await equipoRef.update({'EMPRESA': empresa, 'COLOR': color, 'CODIGO': codigo});

    // Ruta de las fuerzas de la empresa seleccionada
    final DatabaseReference fuerzasEmpresaRef = _dbRef.child(
      'Five Force Competence/DATOS PERSISTENTES/SECTORES/$sector/EMPRESAS/$empresa/FUERZAS',
    );

    final DatabaseReference fuerzasEquipoRef = equipoRef.child('FUERZAS');

    try {
      final fuerzasSnapshot = await fuerzasEmpresaRef.get();
      if (fuerzasSnapshot.exists) {
        await fuerzasEquipoRef.set(fuerzasSnapshot.value);
        debugPrint('Fuerzas copiadas exitosamente de $empresa a EQUIPO $equipoId');
      } else {
        debugPrint('No se encontraron fuerzas para la empresa $empresa');
      }
    } catch (e) {
      debugPrint('Error al copiar las fuerzas: $e');
    }

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
