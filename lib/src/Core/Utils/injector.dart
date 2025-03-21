/// *****************************************************************
/// * Nombre del Archivo: injector.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Clase `Injector` para la inyección de dependencias.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Permite acceder a los repositorios de autenticación, conectividad
/// *        y administración desde cualquier parte de la aplicación.
/// *****************************************************************
library;

import 'package:flutter/material.dart';

import '../../Core/Repositories/authentication_repository.dart';
import '../../Core/Repositories/connectivity_repository.dart';
import '../../Data/Firebase/Admin/admin_repository.dart';

/// Clase `Injector` para la gestión de dependencias en la aplicación.
///
/// Extiende `InheritedWidget` y proporciona acceso a los
/// repositorios esenciales en la aplicación.
class Injector extends InheritedWidget {
  /// Constructor de `Injector`, requiere los repositorios y el widget hijo.
  const Injector({
    super.key,
    required super.child,
    required this.connectivityRepository,
    required this.authenticationRepository,
    required this.adminRepository,
  });

  /// Repositorio de conectividad.
  final ConnectivityRepository connectivityRepository;

  /// Repositorio de autenticación.
  final AuthenticationRepository authenticationRepository;

  /// Repositorio de administradores.
  final AdminRepository adminRepository;

  /// Determina si los widgets dependientes deben reconstruirse al cambiar `Injector`.
  @override
  bool updateShouldNotify(_) => false;

  /// Obtiene el `Injector` desde el árbol de widgets.
  static Injector of(BuildContext context) {
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(injector != null, 'Injector could not be found');
    return injector!;
  }
}
