/// *****************************************************************
/// * Nombre del Archivo: routes.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Definición de rutas de navegación dentro de la aplicación.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Contiene las rutas principales utilizadas en la aplicación.
/// *      - Se accede a ellas mediante `Routes.nombreRuta`.
/// *****************************************************************
library;

/// Clase `Routes`.
///
/// Contiene las constantes con las rutas de navegación de la aplicación.
class Routes {
  /// Constructor privado para evitar instancias de la clase.
  Routes._();

  /// Ruta de la pantalla de carga (Splash Screen).
  static const splash = '/splash';

  /// Ruta de la pantalla de inicio de sesión.
  static const signIn = '/Sign-In';

  /// Ruta de la pantalla principal (Home).
  static const home = '/Home';

  /// Ruta para la pantalla de creación de juego.
  static const createGame = '/Create-Game';

  /// Ruta para la pantalla de unirse a un juego.
  static const joinGame = '/Join-Game';
}
