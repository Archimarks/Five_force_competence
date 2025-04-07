import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// # ActualizarEquipo
///
/// **Clase encargada de actualizar los datos de un equipo específico en**
/// **Firebase Realtime Database**, incluyendo su empresa, color, código y
/// copia de las fuerzas correspondientes.
///
/// Esta clase forma parte del flujo de configuración previa al inicio de la
/// partida, garantizando que cada equipo quede correctamente asociado con una
/// empresa y sus atributos.
///
/// ### Autor:
/// *Marcos Alejandro Collazos Marmolejo*
///
/// ### Fecha:
/// *2025*
/// ---------------------------------------------------------------------------
class ActualizarEquipo {
  /// Referencia principal a Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// -------------------------------------------------------------------------
  /// Constructor de la clase `ActualizarEquipo`.
  ///
  /// Inicializa la referencia a la base de datos utilizando la instancia
  /// principal de `FirebaseDatabase`.
  /// -------------------------------------------------------------------------
  ActualizarEquipo() : _dbRef = FirebaseDatabase.instance.ref();

  /// -------------------------------------------------------------------------
  /// Actualiza los datos del equipo en Firebase y copia las fuerzas de la empresa.
  ///
  /// Este método realiza las siguientes acciones:
  /// - Genera un código único para el equipo basado en el ID de la partida.
  /// - Actualiza los campos `EMPRESA`, `COLOR` y `CODIGO` del equipo.
  /// - Copia las fuerzas desde la empresa seleccionada al nodo del equipo.
  ///
  /// ### Parámetros:
  /// - `partidaActual`: ID de la partida actual.
  /// - `equipoId`: Número identificador del equipo.
  /// - `empresa`: Nombre de la empresa asignada al equipo.
  /// - `color`: Color del equipo.
  /// - `sector`: Sector al que pertenece la empresa.
  ///
  /// ### Ejemplo de ruta afectada:
  /// `Five Force Competence/PARTIDAS/{partidaId}/EQUIPOS/EQUIPO {equipoId}`
  ///
  /// ### Logs:
  /// - Imprime en consola el estado de la actualización y si hubo errores.
  /// -------------------------------------------------------------------------
  Future<void> actualizarPreGame(
    String partidaActual,
    int equipoId,
    String empresa,
    String color,
    String sector,
  ) async {
    // Extrae solo números del ID de partida para generar el código
    String numeroPartida = partidaActual.replaceAll(RegExp(r'\D'), '');

    // Genera un código único: ID partida + último dígito equipoId + 2 dígitos aleatorios
    String codigo = '$numeroPartida${equipoId % 10}${_generarCodigoAleatorio(2)}';

    // Referencia al equipo específico
    final DatabaseReference equipoRef = _dbRef.child(
      'Five Force Competence/PARTIDAS/$partidaActual/EQUIPOS/EQUIPO $equipoId',
    );

    // Actualiza los campos del equipo en Firebase
    await equipoRef.update({'EMPRESA': empresa, 'COLOR': color, 'CODIGO': codigo});

    // Referencias a las fuerzas de la empresa y del equipo
    final DatabaseReference fuerzasEmpresaRef = _dbRef.child(
      'Five Force Competence/DATOS PERSISTENTES/SECTORES/$sector/EMPRESAS/$empresa/FUERZAS',
    );
    final DatabaseReference fuerzasEquipoRef = equipoRef.child('FUERZAS');

    try {
      final fuerzasSnapshot = await fuerzasEmpresaRef.get();
      if (fuerzasSnapshot.exists) {
        await fuerzasEquipoRef.set(fuerzasSnapshot.value);
        debugPrint('✅ Fuerzas copiadas exitosamente de "$empresa" a EQUIPO $equipoId');
      } else {
        debugPrint('⚠️ No se encontraron fuerzas para la empresa "$empresa"');
      }
    } catch (e) {
      debugPrint('❌ Error al copiar las fuerzas: $e');
    }

    debugPrint(
      '✅ Equipo actualizado: $equipoId | CODIGO: $codigo | EMPRESA: $empresa | COLOR: $color',
    );
  }

  /// -------------------------------------------------------------------------
  /// Genera un código aleatorio numérico con una cantidad específica de dígitos.
  ///
  /// Este código se utiliza como parte del identificador único del equipo.
  ///
  /// ### Parámetros:
  /// - `cantidad`: Número de dígitos que debe tener el código generado.
  ///
  /// ### Retorna:
  /// - `String`: Código numérico aleatorio.
  ///
  /// ### Ejemplo:
  /// ```dart
  /// final codigo = _generarCodigoAleatorio(2); // "84"
  /// ```
  /// -------------------------------------------------------------------------
  String _generarCodigoAleatorio(int cantidad) {
    final random = Random();
    String codigo = '';
    for (int i = 0; i < cantidad; i++) {
      codigo += random.nextInt(10).toString(); // Genera un dígito entre 0 y 9
    }
    return codigo;
  }
}
