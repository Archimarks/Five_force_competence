import 'package:flutter/material.dart';

import '../../../Core/Utils/injector.dart';
import '../../Global/Widgets/button.dart'; // Importa el botón personalizado
import '../../Routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewsState();
}

class _SignInViewsState extends State<SignInView> {
  bool _fetching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/Icon/FONDO PRINCIPAL.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 130, 130, 130).withAlpha((0.6 * 255).toInt()),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/Icon/LOGO.png', width: 250),
                const SizedBox(height: 40),
                if (_fetching) const CircularProgressIndicator(),
                if (!_fetching)
                  _buildButton(
                    context,
                    texto: 'Iniciar sesión con Google',
                    color: ButtonColor.azulClaro,
                    onPressed: _signInWithGoogle,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _fetching = true);

    final result = await Injector.of(context).authenticationRepository.signInWithGoogle();

    setState(() => _fetching = false);

    result.when(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al iniciar sesión con Google'))),
      (user) => Navigator.pushReplacementNamed(context, Routes.home),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String texto,
    required ButtonColor color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 50,
      child: Button(texto: texto, color: color, onPressed: onPressed),
    );
  }
}
