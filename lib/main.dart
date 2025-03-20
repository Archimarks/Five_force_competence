/// -----------------------------------------------------------
/// Proyecto: Five Force Competence
/// Archivo: main.dart
/// Descripción: Punto de entrada principal de la aplicación.
///              Se encarga de inicializar Firebase y configurar
///              las dependencias del inyector de servicios.
/// Autor: Marcos Alejandro Collazos Marmolejo & Geraldine Perilla Valderrama
/// -----------------------------------------------------------
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'src/Core/Utils/injector.dart';
import 'src/Data/Firebase/admin_repository.dart';
import 'src/Data/Remote/internet_checker.dart';
import 'src/Data/Services/authentication_repository_impl.dart';
import 'src/Data/Services/connectivity_repository_impl.dart';
import 'src/my_app.dart';

void main() async {
  /// Asegura la inicialización de los widgets antes de correr la app.
  WidgetsFlutterBinding.ensureInitialized();

  /// Inicializa Firebase antes de lanzar la aplicación.
  await Firebase.initializeApp();

  /// Ejecuta la aplicación con las dependencias inyectadas.
  runApp(
    Injector(
      connectivityRepository: ConnectivityRepositoryImpl(Connectivity(), InternetChecker()),
      authenticationRepository: AuthenticationRepositoryImpl(),
      adminRepository: AdminRepository(), // Inyección del AdminRepository
      child: const MyApp(),
    ),
  );
}
