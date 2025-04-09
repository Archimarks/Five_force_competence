/// *****************************************************************
/// * Nombre del Archivo: app_routes.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Definición del mapa de rutas para la navegación en la aplicación.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Asocia cada ruta definida en `Routes` con su respectiva vista.
/// *      - Se utiliza en `MaterialApp` para gestionar la navegación.
/// *****************************************************************
library;

import 'package:flutter/material.dart';

import '../Modules/1_Pre_game/home_view.dart';
import '../Modules/1_Pre_game/sign_in_view.dart';
import '../Modules/1_Pre_game/splash_view.dart';
import '../Modules/2_Setup_game/create_game_view.dart';
import '../Modules/2_Setup_game/defined_team_view.dart';
import '../Modules/2_Setup_game/join_game_view.dart';
import '../Modules/2_Setup_game/setup_game_view.dart';
import 'routes.dart';

/// Mapa de rutas de la aplicación.
///
/// Define la relación entre las rutas de `Routes` y sus respectivas vistas.
Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.splash: (context) => const SplashView(),
    Routes.signIn: (context) => const SignInView(),
    Routes.home: (context) => const HomeView(),
    Routes.createGame: (context) => const CreateGameView(),
    Routes.joinGame: (context) => const JoinGameView(),
    Routes.definedTeam: (context) => const DefinedTeamView(),
    Routes.setupGame: (context) => const SetupGameView(),
  };
}
