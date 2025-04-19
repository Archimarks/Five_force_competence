/// -----------------------------------------------------------
/// Proyecto: Five Force Competence
/// Archivo: admin_repository.dart
/// Descripción: Repositorio para la gestión de administradores
///              en Firebase Realtime Database.
/// Autores: Marcos Alejandro Collazos Marmolejo & Geraldine Perilla Valderrama
/// -----------------------------------------------------------

library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Repositorio encargado de gestionar la autenticación de administradores.
class AdminRepository {
  /// Referencia a la base de datos en Firebase Realtime Database.
  final DatabaseReference _dbRef;

  /// Constructor que permite inyección de dependencias para facilitar pruebas unitarias.
  AdminRepository({DatabaseReference? databaseReference}) : _dbRef = databaseReference ?? FirebaseDatabase.instance.ref('Five Force Competence/ADMINISTRADORES');

  /// Verifica si el correo pertenece a un administrador activo en la base de datos.
  ///
  /// Retorna `true` si el administrador está registrado y activo, de lo contrario, `false`.
  Future<bool> isAdmin(String email) async {
    try {
      final DataSnapshot snapshot = await _dbRef.get();

      if (!snapshot.exists || snapshot.children.isEmpty) return false;

      return snapshot.children.any((child) {
        final adminData = child.value as Map<dynamic, dynamic>?;

        if (adminData == null) return false;

        final String? adminEmail = adminData['AD_CORREO'] as String?;
        final bool isActive = adminData['AD_ESTADO'] as bool? ?? false;

        return adminEmail != null && adminEmail == email && isActive;
      });
    } on FirebaseException catch (e) {
      debugPrint('Error de Firebase al verificar administrador: ${e.message}');
      return false;
    } catch (e, stackTrace) {
      debugPrint('Error inesperado al verificar administrador: $e');
      debugPrint(stackTrace.toString());
      return false;
    }
  }
}
