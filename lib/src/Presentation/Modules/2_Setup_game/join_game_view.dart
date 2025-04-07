import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Utils/injector.dart';
import '../../../Data/Firebase/Equipo/equipo_codigo.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Routes/routes.dart';

/// ------------------------------------------------------------
/// Título que se muestra en el `AppBar` de la vista de ingreso
/// del código de equipo.
/// ------------------------------------------------------------
String titulo = 'Ingresa el código de tu equipo';

/// Vista encargada de permitir que un usuario ingrese
/// el código de su equipo para unirse a la partida.
class JoinGameView extends StatefulWidget {
  const JoinGameView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _JoinGameViewState createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<JoinGameView> {
  /// Controlador del campo de texto donde se escribe el código del equipo.
  final TextEditingController _codeController = TextEditingController();

  /// Liberamos el controlador al destruir la vista.
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Construcción principal de la vista `JoinGameView`.
  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: titulo,
        onLeadingPressed: () async {
          // Cierra sesión y vuelve a la pantalla de inicio.
          Injector.of(context).authenticationRepository.signOut();
          Navigator.pushReplacementNamed(context, Routes.home);
        },
      ),
      body: Stack(
        children: [
          /// Fondo de imagen personalizado
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Icon/FONDO GENERAL.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// Capa semitransparente encima del fondo
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 70, 70, 70).withAlpha((0.6 * 255).toInt()),
            ),
          ),

          /// Contenido central con diseño responsive
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: orientation == Orientation.portrait ? _portraitLayout() : _landscapeLayout(),
            ),
          ),
        ],
      ),
    );
  }

  /// Layout mostrado cuando el dispositivo está en orientación vertical.
  Widget _portraitLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/Icon/LOGO.png', width: 220, fit: BoxFit.contain),
        const SizedBox(height: 30),
        _buildTextField(),
        const SizedBox(height: 20),
        _buildButton(),
      ],
    );
  }

  /// Layout mostrado cuando el dispositivo está en orientación horizontal.
  Widget _landscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Image.asset('assets/Icon/LOGO.png', width: 200, fit: BoxFit.contain)),
            const SizedBox(width: 20),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [_buildTextField(), const SizedBox(height: 20), _buildButton()],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye el campo de texto para ingresar el código del equipo.
  Widget _buildTextField() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 130, 130, 130).withAlpha((0.6 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _codeController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Código del equipo',
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Botón que valida el código ingresado y redirige a la vista del equipo.
  ///
  /// * Si el código es correcto, guarda la información del equipo y navega.
  /// * Si es incorrecto, muestra un `SnackBar` de error.
  Widget _buildButton() {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          String teamCode = _codeController.text.trim();

          // Validación de campo vacío
          if (teamCode.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Por favor ingresa un código.')));
            return;
          }

          final equipoCodigo = EquipoCodigo();

          // Mostrar un loader mientras se busca el código en Firebase
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          // Buscar y guardar los datos del equipo
          await equipoCodigo.buscarYGuardarDatosPorCodigo(teamCode);

          // Verificar si el código fue guardado correctamente
          final prefs = await SharedPreferences.getInstance();
          String? codigoGuardado = prefs.getString('CODIGO');

          // Cerrar el loader
          if (mounted) Navigator.pop(context);

          // Redirigir si el código es válido
          if (codigoGuardado == teamCode) {
            Navigator.pushReplacementNamed(context, Routes.definedTeam);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Código no encontrado. Intenta nuevamente.')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
