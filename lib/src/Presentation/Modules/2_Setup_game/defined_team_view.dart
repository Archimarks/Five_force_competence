import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Data/Firebase/Equipo/validar_fuerzas.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../../Global/Color/color_equipo.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../routes/routes.dart';

class DefinedTeamView extends StatefulWidget {
  const DefinedTeamView({super.key});

  @override
  State<DefinedTeamView> createState() => _DefinedTeamViewState();
}

class _DefinedTeamViewState extends State<DefinedTeamView> {
  final List<String> fuerzas = [
    'PODER DE NEGOCIACION DE COMPRADORES',
    'PODER DE NEGOCIACION DE PROVEEDORES',
    'POTENCIALES COMPETIDORES',
    'PRODUCTOS SUSTITUTOS',
    'RIVALIDAD ENTRE COMPETIDORES',
  ];

  final List<String?> seleccionadas = List<String?>.filled(5, null);
  late String nombreEquipo = '';
  late Color colorEquipo = Colors.black;
  String? partidaId;
  String? equipo;

  @override
  void initState() {
    super.initState();
    _cargarDatosEquipo();
  }

  Future<void> _cargarDatosEquipo() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar nombre y color del equipo
    nombreEquipo = prefs.getString('EMPRESA')!;
    final colorEnum = AppColorEquipo.values.firstWhere((e) => e.name == prefs.getString('COLOR')!);
    colorEquipo = colorEnum.color;

    // Cargar partida con clase dedicada
    final cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida();
    partidaId = cargarPartida.partidaId;
    equipo = prefs.getString('EQUIPO');

    // Inicializar dropdowns
    for (int i = 0; i < fuerzas.length; i++) {
      seleccionadas[i] = fuerzas[i];
    }

    setState(() {});
  }

  Future<void> _confirmarSeleccion() async {
    if (partidaId == null || equipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: no se encontraron los datos del equipo o partida.')),
      );
      return;
    }

    final validador = ValidarFuerzas();
    await validador.validarSeleccionUsuario(
      partidaActual: partidaId!,
      equipo: equipo!,
      respuestasUsuario: seleccionadas,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fuerzas validadas correctamente.')));
  }

  Widget _dropdownFuerza(int index, String label) {
    return Flexible(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        hint: Text(label),
        value: seleccionadas[index],
        isExpanded: true,
        items:
            fuerzas.map((fuerza) {
              return DropdownMenuItem(value: fuerza, child: Text(fuerza));
            }).toList(),
        onChanged: (value) {
          setState(() {
            seleccionadas[index] = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: customAppBar(
          context: context,
          title: nombreEquipo,
          backgroundColor: colorEquipo,
          onLeadingPressed: () {
            Navigator.pushReplacementNamed(context, Routes.joinGame);
          },
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Image.asset('assets/Icon/LOGO.png', height: 40),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Icon/FONDO GENERAL.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              'Define las fuerzas de tu empresa',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 25),
                            isLandscape ? _buildHorizontalLayout() : _buildVerticalLayout(),
                            const Spacer(),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _confirmarSeleccion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Confirmar', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      children: List.generate(
        fuerzas.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _dropdownFuerza(index, _etiqueta(index)),
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Column(
      children: [
        Row(
          children: [
            _dropdownFuerza(0, 'Fuerza principal (5 pines)'),
            const SizedBox(width: 12),
            _dropdownFuerza(3, 'Cuarta fuerza (2 pines)'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _dropdownFuerza(2, 'Tercer fuerza (3 pines)'),
            const SizedBox(width: 12),
            _dropdownFuerza(1, 'Segunda fuerza (4 pines)'),
          ],
        ),
        const SizedBox(height: 16),
        Row(children: [_dropdownFuerza(4, 'Menor fuerza (1 pin)')]),
      ],
    );
  }

  String _etiqueta(int index) {
    switch (index) {
      case 0:
        return 'Fuerza principal (5 pines)';
      case 1:
        return 'Segunda fuerza (4 pines)';
      case 2:
        return 'Tercer fuerza (3 pines)';
      case 3:
        return 'Cuarta fuerza (2 pines)';
      case 4:
      default:
        return 'Menor fuerza (1 pin)';
    }
  }
}
