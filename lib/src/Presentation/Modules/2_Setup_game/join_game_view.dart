import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Core/Utils/injector.dart';
import '../../../Data/Firebase/Equipo/equipo_codigo.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Routes/routes.dart';

//--------------------------------------------------------
String titulo = 'Ingresa el código de tu equipo';
//--------------------------------------------------------

class JoinGameView extends StatefulWidget {
  const JoinGameView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _JoinGameViewState createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<JoinGameView> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: customAppBar(
        context: context,
        title: titulo,
        onLeadingPressed: () async {
          Injector.of(context).authenticationRepository.signOut();
          Navigator.pushReplacementNamed(context, Routes.home);
        },
      ),
      body: Stack(
        children: [
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
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 70, 70, 70).withAlpha((0.6 * 255).toInt()),
            ),
          ),
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

  Widget _buildButton() {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          String teamCode = _codeController.text.trim();
          if (teamCode.isEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Por favor ingresa un código.')));
            return;
          }

          final equipoCodigo = EquipoCodigo();

          // Mostrar un loader mientras busca en Firebase
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          await equipoCodigo.buscarYGuardarDatosPorCodigo(teamCode);

          // Verificamos si realmente se guardó el código
          final prefs = await SharedPreferences.getInstance();
          String? codigoGuardado = prefs.getString('CODIGO');

          // Cierra el loader
          if (mounted) Navigator.pop(context);

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
