/// *****************************************************************
/// * Nombre del Archivo: user.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Modelo de datos para representar un usuario en la aplicación.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Contiene la información básica de un usuario autenticado.
/// *****************************************************************
library;

/// Clase `User`.
///
/// Representa un usuario en la aplicación con un identificador único y un correo electrónico opcional.
class User {
  /// Identificador único del usuario.
  final String uid;

  /// Correo electrónico del usuario (puede ser `null` si no está disponible).
  final String? email;

  /// Constructor de la clase `User`.
  ///
  /// - `uid`: identificador único obligatorio.
  /// - `email`: correo electrónico opcional.
  User({required this.uid, this.email});
}
