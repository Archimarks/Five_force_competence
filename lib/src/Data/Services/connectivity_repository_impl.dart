/// *****************************************************************
/// * Nombre del Archivo: connectivity_repository_impl.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Implementación del repositorio de conectividad.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Utiliza `connectivity_plus` para verificar el estado de la conexión.
/// *      - Utiliza `InternetChecker` para comprobar si hay acceso real a internet.
/// *****************************************************************
library;

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../Core/Repositories/connectivity_repository.dart';
import '../Remote/internet_checker.dart';

/// Implementación del repositorio de conectividad.
///
/// Permite verificar si el dispositivo tiene conexión a internet utilizando
/// `connectivity_plus` y `InternetChecker` para una verificación más precisa.
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  /// Instancia de `Connectivity` para verificar el tipo de conexión.
  final Connectivity _connectivity;

  /// Instancia de `InternetChecker` para comprobar el acceso real a internet.
  final InternetChecker _internetChecker;

  /// Constructor de `ConnectivityRepositoryImpl`.
  ConnectivityRepositoryImpl(this._connectivity, this._internetChecker);

  /// Verifica si el dispositivo tiene conexión a internet.
  ///
  /// - Primero, revisa si hay algún tipo de conexión disponible.
  /// - Luego, confirma si hay acceso real a internet mediante `InternetChecker`.
  @override
  Future<bool> get hasInternet async {
    final result = await _connectivity.checkConnectivity();
    // ignore: unrelated_type_equality_checks
    if (result == ConnectivityResult.none) {
      return false;
    }
    return _internetChecker.hasInternet();
  }
}
