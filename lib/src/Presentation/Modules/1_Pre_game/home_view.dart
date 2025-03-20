/// -----------------------------------------------------------
/// Proyecto: Five Force Competence
/// Archivo: home_view.dart
/// Descripción: Vista principal que presenta la interfaz de usuario
///              con opciones para crear una partida, unirse a una
///              partida o cerrar sesión. Además, verifica si el
///              usuario es administrador para habilitar ciertas
///              funcionalidades.
/// Autor: Marcos Alejandro Collazos Marmolejo & Geraldine Perilla Valderrama
/// Notas:
/// -----------------------------------------------------------
library;

import 'package:flutter/material.dart';

// Importación de las utilidades del proyecto, incluidas las dependencias de inyección de dependencias.
import '../../../Core/Utils/injector.dart';
// Importación del widget de botón personalizado.
import '../../Global/Color/color.dart';
import '../../Global/Widgets/button.dart';
// Importación de rutas para la navegación entre vistas.
import '../../Routes/routes.dart';

/// Vista principal de la aplicación donde el usuario puede interactuar
/// con las opciones disponibles como "Crear partida" o "Ingresar a una partida".
/// Esta vista también verifica si el usuario tiene privilegios de administrador.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Variable para determinar si el usuario es administrador
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Se usa addPostFrameCallback para asegurarse de tener el contexto disponible
    // después de que la vista ha sido renderizada.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAdmin();
    });
  }

  /// Método que verifica si el usuario actual tiene permisos de administrador.
  Future<void> _checkIfAdmin() async {
    // Se obtiene la información del usuario actual.
    final user = await Injector.of(context).authenticationRepository.getUserData();
    if (user != null) {
      // Verifica si el correo del usuario corresponde a un administrador.
      // ignore: use_build_context_synchronously
      final isAdmin = await Injector.of(context).adminRepository.isAdmin(user.email ?? '');
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detecta la orientación de la pantalla (vertical u horizontal).
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la pantalla utilizando una imagen de fondo
          Positioned.fill(child: Image.asset('assets/Icon/FONDO PRINCIPAL.jpg', fit: BoxFit.cover)),
          // Capa de superposición semitransparente sobre el fondo
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 130, 130, 130).withAlpha((0.6 * 255).toInt()),
            ),
          ),
          // Diseño centrado que cambia según la orientación de la pantalla
          Center(
            child:
                orientation == Orientation.portrait
                    ? _portraitLayout(context) // Diseño vertical
                    : _landscapeLayout(context), // Diseño horizontal
          ),
        ],
      ),
    );
  }

  // Diseño vertical, se muestra cuando la orientación es vertical
  Widget _portraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/Icon/LOGO.png', width: 250), // Logo de la aplicación
        const SizedBox(height: 40),
        // Si el usuario es administrador, mostrar el botón para crear una partida
        if (_isAdmin) ...[
          Button(
            texto: 'Crear partida',
            color: AppColor.azulClaro,
            onPressed: () => Navigator.pushReplacementNamed(context, Routes.createGame),

            width: 250,
            height: 50,
          ),
          const SizedBox(height: 20),
        ],
        // Botón para unirse a una partida
        Button(
          texto: 'Ingresar a una partida',
          color: AppColor.azul,
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.joinGame),

          width: 250,
          height: 50,
        ),
        const SizedBox(height: 20),
        // Botón para cerrar sesión
        Button(
          texto: 'Cerrar seccion',
          color: AppColor.azulOscuro,
          onPressed: () async {
            await Injector.of(context).authenticationRepository.signOut();
            // Redirige a la vista de inicio de sesión
            Navigator.pushReplacementNamed(context, Routes.signIn);
          },

          width: 250,
          height: 50,
        ),
      ],
    );
  }

  // Diseño horizontal, se muestra cuando la orientación es horizontal
  Widget _landscapeLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80), // Espacio a los lados
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna de botones
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Si el usuario es administrador, mostrar el botón para crear una partida
                if (_isAdmin) ...[
                  Button(
                    texto: 'Crear partida',
                    color: AppColor.azulClaro,
                    onPressed: () => Navigator.pushReplacementNamed(context, Routes.createGame),
                    width: 250,
                    height: 50,
                  ),
                  const SizedBox(height: 20),
                ],
                // Botón para unirse a una partida
                Button(
                  texto: 'Ingresar a una partida',
                  color: AppColor.azul,
                  onPressed: () => Navigator.pushReplacementNamed(context, Routes.joinGame),

                  width: 250,
                  height: 50,
                ),
                const SizedBox(height: 20),
                // Botón para cerrar sesión
                Button(
                  texto: 'Cerrar seccion',
                  color: AppColor.azulOscuro,
                  onPressed: () async {
                    await Injector.of(context).authenticationRepository.signOut();
                    // Redirige a la vista de inicio de sesión
                    Navigator.pushReplacementNamed(context, Routes.signIn);
                  },

                  width: 250,
                  height: 50,
                ),
              ],
            ),
          ),
          const SizedBox(width: 80), // Espacio entre los botones y la imagen
          // Columna de la imagen (logo de la aplicación)
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset('assets/Icon/LOGO.png', width: 250),
            ),
          ),
        ],
      ),
    );
  }
}
