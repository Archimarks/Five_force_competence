import 'dart:async'; // Importa Timer

import 'package:flutter/material.dart';

import '../../../Core/Utils/injector.dart';
import '../../Routes/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer; // Variable para manejar el temporizador

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCheckingInternet());
  }

  void _startCheckingInternet() {
    _checkInternet(); // Verifica la conexión inmediatamente
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkInternet()); // Verifica cada 5 segundos
  }

  Future<void> _checkInternet() async {
    final injector = Injector.of(context);
    final connectivityRepository = injector.connectivityRepository;
    final hasInternet = await connectivityRepository.hasInternet;

    if (hasInternet) {
      final authenticationRepository = injector.authenticationRepository;
      final isSignedIn = await authenticationRepository.isSignedIn;

      if (isSignedIn) {
        final user = await authenticationRepository.getUserData();
        if (mounted) {
          _goTo(user != null ? Routes.home : Routes.signIn);
        }
      } else if (mounted) {
        _goTo(Routes.signIn);
      }
    }
  }

  void _goTo(String routeName) {
    if (mounted) {
      _timer?.cancel(); // Cancela el temporizador antes de navegar
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador al salir del widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/Icon/FONDO PRINCIPAL.jpg', fit: BoxFit.cover)),
          Positioned.fill(
            // ignore: deprecated_member_use
            child: Container(color: const Color.fromARGB(255, 130, 130, 130).withAlpha((0.6 * 255).toInt())),
          ),
          Center(
            child: OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? _portraitLayout() // Diseño vertical
                    : _landscapeLayout(); // Diseño horizontal
              },
            ),
          ),
        ],
      ),
    );
  }

  // Diseño en Modo Vertical
  Widget _portraitLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/Icon/LOGO.png', width: 250, height: 250),
        const SizedBox(height: 20),
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        const Text('Conectando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  // Diseño en Modo Horizontal
  Widget _landscapeLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/Icon/LOGO.png', width: 200, height: 200),
        const SizedBox(width: 30),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator(), SizedBox(height: 10), Text('Conectando...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))],
        ),
      ],
    );
  }
}
