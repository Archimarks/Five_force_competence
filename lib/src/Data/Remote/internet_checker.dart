/// *****************************************************************
/// * Nombre del Archivo: internet_checker.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Clase para verificar la disponibilidad de conexión a internet.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Compatible con plataformas móviles y web.
/// *      - En web, realiza una solicitud HTTP para verificar la conexión.
/// *      - En dispositivos móviles, usa `InternetAddress.lookup`.
/// *****************************************************************
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

/// Clase `InternetChecker`.
///
/// Proporciona un método para verificar si hay conexión a internet.
class InternetChecker {
  /// Verifica la disponibilidad de internet.
  ///
  /// - En web, realiza una solicitud HTTP a `8.8.8.8`.
  /// - En dispositivos móviles, usa `InternetAddress.lookup` para comprobar conectividad.
  /// - Retorna `true` si hay conexión, `false` en caso contrario.
  Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        final response = await get(Uri.parse('https://8.8.8.8'));
        return response.statusCode == 200;
      } else {
        final list = await InternetAddress.lookup('google.com');
        return list.isNotEmpty && list.first.rawAddress.isNotEmpty;
      }
    } catch (e) {
      return false;
    }
  }
}
