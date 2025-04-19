/// *****************************************************************
/// * Nombre del Archivo: authentication_repository_impl.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Implementación del repositorio de autenticación.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Utiliza Firebase Authentication y Google Sign-In.
/// *      - Implementa la interfaz `AuthenticationRepository`.
/// *****************************************************************
library;

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../../Core/Models/user.dart' as app_user;
import '../../Core/Repositories/authentication_repository.dart';
import '../../Core/Utils/either.dart';
import '../../Core/Utils/enums.dart';

/// Implementación del repositorio de autenticación.
///
/// Gestiona la autenticación del usuario utilizando Firebase y Google Sign-In.
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  /// Instancia de Firebase Authentication.
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  /// Instancia de Google Sign-In.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Obtiene los datos del usuario autenticado.
  ///
  /// Retorna un objeto `User` si hay un usuario autenticado, de lo contrario `null`.
  @override
  Future<app_user.User?> getUserData() async {
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser != null ? app_user.User(uid: firebaseUser.uid, email: firebaseUser.email) : null;
  }

  /// Verifica si hay un usuario autenticado.
  ///
  /// Retorna `true` si el usuario ha iniciado sesión, `false` en caso contrario.
  @override
  Future<bool> get isSignedIn async {
    return _firebaseAuth.currentUser != null;
  }

  /// Inicia sesión con Google.
  ///
  /// - Si la autenticación es exitosa, retorna un `User`.
  /// - Si ocurre un error, retorna un `SignInFailure` encapsulado en `Either`.
  @override
  Future<Either<SignInFailure, app_user.User>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Either.left(SignInFailure.unknown);

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final firebase_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) return Either.left(SignInFailure.unknown);

      return Either.right(app_user.User(uid: firebaseUser.uid, email: firebaseUser.email));
    } catch (e) {
      return Either.left(SignInFailure.unknown);
    }
  }

  /// Cierra la sesión del usuario.
  ///
  /// Desconecta la sesión en Google y Firebase Authentication.
  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
