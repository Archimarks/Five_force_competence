/// *****************************************************************
/// * Nombre del Archivo: my_app.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Clase principal de la aplicación que configura MaterialApp.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Configura las rutas y el título de la aplicación.
/// *      - Usa `GestureDetector` para cerrar el teclado al tocar fuera de un campo de texto.
/// *****************************************************************
library;

import 'package:flutter/material.dart';

import 'Presentation/Routes/app_routes.dart';
import 'Presentation/Routes/routes.dart';

/// Clase `MyApp`.
///
/// Configura la estructura principal de la aplicación y define las rutas de navegación.
class MyApp extends StatelessWidget {
  /// Constructor de `MyApp`.
  const MyApp({super.key});

  /// Construye la interfaz de la aplicación.
  ///
  /// - Utiliza `MaterialApp` como raíz de la aplicación.
  /// - Configura las rutas y oculta la etiqueta de depuración.
  /// - Implementa `GestureDetector` para ocultar el teclado cuando se toca fuera de los campos de texto.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(title: 'Five Force Competence', debugShowCheckedModeBanner: false, initialRoute: Routes.splash, routes: appRoutes),
    );
  }
}
