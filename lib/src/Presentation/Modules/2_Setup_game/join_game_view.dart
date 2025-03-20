import 'package:flutter/material.dart';

import '../../../Core/Utils/injector.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Routes/routes.dart';

//--------------------------------------------------------
String titulo = 'Ingresa el código de tu equipo';
//--------------------------------------------------------

class JoinGameView extends StatefulWidget {
  const JoinGameView({super.key});

  @override
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
        onPressed: () {
          String teamCode = _codeController.text;
          print('Código ingresado: $teamCode');
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
