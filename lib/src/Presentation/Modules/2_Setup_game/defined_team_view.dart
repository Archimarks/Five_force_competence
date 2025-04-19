import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Data/Firebase/Equipo/validar_fuerzas.dart';
import '../../../Data/Firebase/Partida/cargar_partida.dart';
import '../../Global/Color/color_equipo.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../routes/routes.dart';

/// Vista donde el equipo define la asignación de fuerzas.
///
/// Esta pantalla permite seleccionar y confirmar la importancia de las cinco fuerzas
/// en el análisis estratégico del equipo.
/// Se adapta a orientación vertical y horizontal, e integra datos desde Firebase.
class DefinedTeamView extends StatefulWidget {
  const DefinedTeamView({super.key});

  @override
  State<DefinedTeamView> createState() => _DefinedTeamViewState();
}

class _DefinedTeamViewState extends State<DefinedTeamView> {
  /// Lista con las 5 fuerzas disponibles a seleccionar.
  final List<String> fuerzasOriginales = [
    'PODER DE NEGOCIACION DE COMPRADORES',
    'PODER DE NEGOCIACION DE PROVEEDORES',
    'POTENCIALES COMPETIDORES',
    'PRODUCTOS SUSTITUTOS',
    'RIVALIDAD ENTRE COMPETIDORES',
  ];

  /// Lista con las selecciones actuales del usuario (inicialmente nulas).
  final List<String?> seleccionadas = List<String?>.filled(5, null);

  /// Nombre del equipo, cargado desde SharedPreferences.
  late String nombreEquipo = '';

  /// Color del equipo, cargado desde SharedPreferences y convertido desde enum.
  late Color colorEquipo = Colors.black;

  /// ID de la partida actual.
  String? partidaId;

  /// Nombre del equipo actual (clave en Firebase).
  String? equipo;

  @override
  void initState() {
    super.initState();
    _cargarDatosEquipo();
  }

  /// Carga los datos persistidos del equipo y partida.
  ///
  /// Se obtienen desde `SharedPreferences` y desde Firebase mediante
  /// la clase `CargarPartida`. Inicializa también los dropdowns.
  Future<void> _cargarDatosEquipo() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar nombre y color del equipo desde preferencias
    nombreEquipo = prefs.getString('EMPRESA')!;
    final colorEnum = AppColorEquipo.values.firstWhere((e) => e.name == prefs.getString('COLOR')!);
    colorEquipo = colorEnum.color;

    // Cargar ID de partida usando clase auxiliar
    final cargarPartida = CargarPartida();
    await cargarPartida.cargarClavePartida();
    partidaId = cargarPartida.partidaId;
    equipo = prefs.getString('EQUIPO');

    setState(() {});
  }

  /// Valida y guarda la selección de fuerzas del usuario en Firebase.
  ///
  /// Muestra un `SnackBar` con el resultado de la operación.
  Future<void> _confirmarSeleccion() async {
    // Verificar si todas las fuerzas han sido seleccionadas
    if (seleccionadas.any((element) => element == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona una fuerza para cada nivel de importancia.')));
      return;
    }

    // Verificar si hay fuerzas duplicadas
    if (seleccionadas.toSet().length < seleccionadas.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, asegúrate de no seleccionar la misma fuerza más de una vez.')));
      return;
    }

    if (partidaId == null || equipo == null) {
      if (!mounted) return; // Verifica si el widget sigue en el árbol
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: no se encontraron los datos del equipo o partida.')));
      return;
    }

    final validador = ValidarFuerzas();
    await validador.validarSeleccionUsuario(partidaActual: partidaId!, equipo: equipo!, respuestasUsuario: seleccionadas);

    if (!mounted) return; // Verifica después del await

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fuerzas validadas correctamente.')));

    // Redirige a la vista de ingreso de código de equipo
    Navigator.pushNamed(context, Routes.setupGame);
  }

  /// Construye un Dropdown para seleccionar una fuerza.
  ///
  /// * [index] indica la posición en la lista `seleccionadas`
  /// * [label] es el texto de ayuda que describe el nivel de importancia
  Widget _dropdownFuerza(int index, String label) {
    // Crear una lista de fuerzas disponibles para este desplegable
    final List<String> fuerzasDisponibles = List<String>.from(fuerzasOriginales);

    // Excluir las fuerzas que ya han sido seleccionadas en otros desplegables
    for (int i = 0; i < seleccionadas.length; i++) {
      if (i != index && seleccionadas[i] != null) {
        fuerzasDisponibles.remove(seleccionadas[i]);
      }
    }

    return Flexible(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        hint: const Text('Seleccionar fuerza'),
        value: seleccionadas[index],
        isExpanded: true,
        items:
            fuerzasDisponibles.map((fuerza) {
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
          title: 'Define las fuerza de la empresa: $nombreEquipo',
          backgroundColor: colorEquipo,
          onLeadingPressed: () {
            Navigator.pushReplacementNamed(context, Routes.joinGame);
          },
          actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Image.asset('assets/Icon/LOGO.png', height: 40))],
        ),
      ),
      body: Stack(
        children: [
          /// Fondo con imagen decorativa
          Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/Icon/FONDO GENERAL.png'), fit: BoxFit.cover))),
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
                            /// Diseño adaptativo según orientación
                            isLandscape ? _buildHorizontalLayout() : _buildVerticalLayout(),

                            const Spacer(),

                            /// Botón de confirmación de fuerzas
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _confirmarSeleccion,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  /// Construye el layout vertical de los dropdowns (modo retrato).
  Widget _buildVerticalLayout() {
    return Column(
      children: List.generate(fuerzasOriginales.length, (index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _dropdownFuerza(index, _etiqueta(index)))),
    );
  }

  /// Construye el layout horizontal de los dropdowns (modo apaisado).
  Widget _buildHorizontalLayout() {
    return Column(
      children: [
        Row(children: [_dropdownFuerza(0, 'Fuerza principal (5 pines)'), const SizedBox(width: 12), _dropdownFuerza(3, 'Cuarta fuerza (2 pines)')]),
        const SizedBox(height: 16),
        Row(children: [_dropdownFuerza(2, 'Tercer fuerza (3 pines)'), const SizedBox(width: 12), _dropdownFuerza(1, 'Segunda fuerza (4 pines)')]),
        const SizedBox(height: 16),
        Row(children: [_dropdownFuerza(4, 'Menor fuerza (1 pin)')]),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Devuelve la etiqueta descriptiva para cada dropdown según su índice.
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
