import 'package:flutter/material.dart';

import '../../../Core/Utils/injector.dart';
import '../../Global/Color/color.dart';
import '../../Global/Widgets/app_bar.dart';
import '../../Global/Widgets/button.dart';
import '../../Global/Widgets/campo_desplegable.dart';
import '../../Global/Widgets/card_teams.dart';
import '../../Routes/routes.dart';

//--------------------------------------------------------
String titulo = 'Partida N';
//--------------------------------------------------------
Map<String, dynamic>? opcionSeleccionada;
final opciones = [
  {'id': 1, 'nombre': 'Sector Alimentario'},
  {'id': 2, 'nombre': 'Sector Turismo'},
  {'id': 3, 'nombre': 'Industrial'},
  {'id': 4, 'nombre': 'Academico'},
];

//---------------------------------------------------------
Map<String, dynamic>? opcionSeleccionada1;
final opciones1 = [
  {'id': 1, 'nombre': '50'},
  {'id': 2, 'nombre': '60'},
  {'id': 3, 'nombre': '120'},
];
//---------------------------------------------------------
Map<int, Map<String, dynamic>> seleccionEquipos = {};

final opcionesEmpresa = [
  {'id': 1, 'nombre': 'Comotor'},
  {'id': 2, 'nombre': 'Taxis Verdes'},
  {'id': 3, 'nombre': 'Ultra Huila'},
  {'id': 3, 'nombre': 'Taxis el Inge'},
];

final opcionesFuerza = [
  {'id': 1, 'nombre': 'Producto sustituto'},
  {'id': 2, 'nombre': 'Elementos fuertes'},
  {'id': 3, 'nombre': 'Comida de noche'},
  {'id': 3, 'nombre': 'Ser Inges'},
];

final opcionesColores = [
  {'id': 1, 'nombre': 'Naranja', 'color': Colors.orange},
  {'id': 2, 'nombre': 'Verde', 'color': Colors.green},
  {'id': 3, 'nombre': 'Amarillo', 'color': Colors.yellow},
  {'id': 4, 'nombre': 'Cyan', 'color': Colors.cyanAccent},
];
//---------------------------------------------------------

// Create a StatefulWidget wrapper for PersistentCardWidget to maintain its state
class PersistentCardWidget extends StatefulWidget {
  final Direccion direccion;
  final Function(Map<int, Map<String, dynamic>>) onSeleccion;

  const PersistentCardWidget({super.key, required this.direccion, required this.onSeleccion});

  @override
  PersistentCardWidgetState createState() => PersistentCardWidgetState();
}

class PersistentCardWidgetState extends State<PersistentCardWidget> {
  // This class will manage and preserve the state of PersistentCardWidget

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      direccion: widget.direccion,
      opcionesEmpresa: opcionesEmpresa,
      opcionesFuerza: opcionesFuerza,
      opcionesColores: opcionesColores,
      // Pass existing selections from the global variable
      seleccionesIniciales: seleccionEquipos,
      onSeleccion: (seleccion) {
        // Update global variable
        seleccionEquipos = seleccion;
        // Call parent's callback
        widget.onSeleccion(seleccion);
      },
    );
  }
}

class CreateGameView extends StatefulWidget {
  const CreateGameView({super.key});

  @override
  State<CreateGameView> createState() => _CreateGameViewState();
}

class _CreateGameViewState extends State<CreateGameView> {
  // Create a global key to maintain the PersistentTarjetasWidget instance state
  final GlobalKey<PersistentCardWidgetState> _tarjetasKey = GlobalKey<PersistentCardWidgetState>();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Placeholder()));
            },
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                orientation == Orientation.portrait ? _portraitVertical() : _landscapeHorizontal(),
          ),
        ],
      ),
    );
  }

  /// **Diseño para orientación vertical**
  Widget _portraitVertical() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24), // Espacio superior
                CampoDesplegable(
                  titulo: 'Temática',
                  icon: const Icon(Icons.star_border),
                  opciones: opciones,
                  valorSeleccionado: opcionSeleccionada,
                  onChanged: (nuevaOpcion) {
                    setState(() {
                      opcionSeleccionada = nuevaOpcion;
                    });
                  },
                  onClear: () {
                    setState(() {
                      opcionSeleccionada = null;
                    });
                  },
                ),
                const SizedBox(height: 25),
                CampoDesplegable(
                  titulo: 'Tiempo permitido',
                  icon: const Icon(Icons.star_border),
                  opciones: opciones1,
                  valorSeleccionado: opcionSeleccionada1,
                  onChanged: (nuevaOpcion) {
                    setState(() {
                      opcionSeleccionada1 = nuevaOpcion;
                    });
                  },
                  onClear: () {
                    setState(() {
                      opcionSeleccionada1 = null;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity, // Ocupar todo el ancho disponible
                  padding: const EdgeInsets.symmetric(horizontal: 16), // Espaciado lateral opcional
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: PersistentCardWidget(
                      key: _tarjetasKey,
                      direccion: Direccion.vertical,
                      onSeleccion: (Map<int, Map<String, dynamic>> seleccion) {
                        setState(() {
                          seleccionEquipos = seleccion;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Espacio adicional entre tarjetas y botón
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Button(
              texto: 'Confirmar',
              color: AppColor.verde,
              onPressed: () {
                // ignore: avoid_print
                print('Botón presionado');
              },
            ),
          ),
        ),
      ],
    );
  }

  /// **Diseño para orientación horizontal**
  Widget _landscapeHorizontal() {
    return Column(
      children: [
        /// **Fila con los desplegables**
        Row(
          children: [
            Expanded(
              child: CampoDesplegable(
                titulo: 'Tematica',
                icon: const Icon(Icons.star_border),
                opciones: opciones,
                valorSeleccionado: opcionSeleccionada,
                onChanged: (nuevaOpcion) {
                  setState(() {
                    opcionSeleccionada = nuevaOpcion;
                  });
                },
                onClear: () {
                  setState(() {
                    opcionSeleccionada = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              child: CampoDesplegable(
                titulo: 'Tiempo permitido',
                icon: const Icon(Icons.star_border),
                opciones: opciones1,
                valorSeleccionado: opcionSeleccionada1,
                onChanged: (nuevaOpcion) {
                  setState(() {
                    opcionSeleccionada1 = nuevaOpcion;
                  });
                },
                onClear: () {
                  setState(() {
                    opcionSeleccionada1 = null;
                  });
                },
              ),
            ),
          ],
        ),

        /// **Tarjetas ocupando el espacio restante**
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: PersistentCardWidget(
              key: _tarjetasKey,
              direccion: Direccion.horizontal,
              onSeleccion: (Map<int, Map<String, dynamic>> seleccion) {
                setState(() {
                  seleccionEquipos = seleccion;
                });
              },
            ),
          ),
        ),

        /// **Botón al fondo dentro de la columna**
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Button(
              texto: 'Confirmar',
              color: AppColor.verde,
              onPressed: () {
                // ignore: avoid_print
                print('Botón presionado');
              },
            ),
          ),
        ),
      ],
    );
  }
}
