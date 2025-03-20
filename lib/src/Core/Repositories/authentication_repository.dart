/// *****************************************************************
/// * Nombre del Archivo: authentication_repository.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Definición de la abstracción para la autenticación de usuarios.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Define un contrato para manejar el inicio de sesión y cierre de sesión.
/// *      - Utiliza la clase `Either` para manejar errores en la autenticación.
/// *****************************************************************
library;

import '../Models/user.dart';
import '../Utils/either.dart';
import '../Utils/enums.dart';

/// Interfaz `AuthenticationRepository`.
///
/// Define métodos para gestionar la autenticación del usuario en la aplicación.
abstract class AuthenticationRepository {
  /// Devuelve `true` si el usuario ha iniciado sesión, `false` en caso contrario.
  Future<bool> get isSignedIn;

  /// Obtiene los datos del usuario autenticado.
  ///
  /// Retorna un `User` si el usuario está autenticado, de lo contrario `null`.
  Future<User?> getUserData();

  /// Cierra la sesión del usuario.
  Future<void> signOut();

  /// Inicia sesión con Google.
  ///
  /// Retorna un `Either` que contiene un `User` en caso de éxito
  /// o un `SignInFailure` en caso de error.
  Future<Either<SignInFailure, User>> signInWithGoogle();
}
