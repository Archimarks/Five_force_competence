/// *****************************************************************
/// * Nombre del Archivo: connectivity_repository.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Definición de la abstracción para la verificación de conectividad.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Define un contrato para verificar la conexión a internet.
/// *****************************************************************
library;

/// Interfaz `ConnectivityRepository`.
///
/// Esta clase abstracta define un método para comprobar si hay conexión a internet.
abstract class ConnectivityRepository {
  /// Devuelve `true` si hay conexión a internet, `false` en caso contrario.
  Future<bool> get hasInternet;
}
