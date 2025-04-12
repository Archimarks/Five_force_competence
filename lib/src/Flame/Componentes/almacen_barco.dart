/// ---------------------------------------------------------------------------
/// `AlmacenBarco` - Componente lateral o inferior del juego que contiene los
/// barcos iniciales disponibles para ser arrastrados y colocados en el tablero.
/// Actúa como inventario visual de barcos antes del despliegue estratégico.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'barco.dart'; // Clase `Barco`, que representa individualmente cada unidad flotante.

/// ---------------------------------------------------------------------------
/// CLASE PRINCIPAL: AlmacenBarco
/// Representa un área tipo "contenedor de barcos" en la UI del juego, permitiendo
/// a los jugadores ver y arrastrar los barcos hacia el tablero.
/// ---------------------------------------------------------------------------
class AlmacenBarco extends PositionComponent with HasGameRef, DragCallbacks {
  // ===========================================================================
  // 🔗 PARÁMETROS DE CONFIGURACIÓN
  // ===========================================================================

  /// Lista de barcos disponibles al inicio del juego.
  final List<Barco> barcosIniciales;

  /// Espaciado horizontal entre cada barco en píxeles.
  final double espacioEntreBarcos;

  /// Componente interno que contiene y organiza visualmente los barcos.
  late final PositionComponent contenedorScroll;

  // ===========================================================================
  // 🏗️ CONSTRUCTOR
  // ===========================================================================

  /// Crea un nuevo `AlmacenBarco` en una posición específica y con tamaño dado.
  ///
  /// - [barcosIniciales]: barcos mostrados como disponibles al jugador.
  /// - [espacioEntreBarcos]: separación horizontal entre cada barco.
  /// - [position]: posición del componente en la pantalla.
  /// - [size]: dimensiones del área del almacén.
  AlmacenBarco({
    required this.barcosIniciales,
    required this.espacioEntreBarcos,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  // ===========================================================================
  // 🚀 CICLO DE VIDA - CARGA DEL COMPONENTE
  // ===========================================================================

  /// Se llama automáticamente cuando el componente es insertado en el juego.
  /// Se encarga de inicializar visualmente el almacén y colocar los barcos.
  @override
  Future<void> onLoad() async {
    // Crea un contenedor que funcionará como scroll horizontal (si se desea).
    contenedorScroll = PositionComponent();

    // Inserta el contenedor como hijo de este componente visual.
    add(contenedorScroll);

    // Posiciona visualmente los barcos dentro del contenedor.
    await _colocarBarcos();
  }

  // ===========================================================================
  // 🧭 MÉTODO PRIVADO: Posicionamiento de Barcos
  // ===========================================================================

  /// Posiciona todos los barcos iniciales horizontalmente dentro del contenedor,
  /// aplicando el espaciado definido y centrado vertical en el almacén.
  Future<void> _colocarBarcos() async {
    double xOffset = 0; // Desplazamiento horizontal inicial

    // Itera sobre todos los barcos disponibles
    for (final barco in barcosIniciales) {
      // Calcula su posición relativa dentro del almacén (centrado vertical)
      barco.position = Vector2(
        xOffset,
        (size.y - barco.size.y) / 2, // Centrado vertical del barco
      );

      // Añade el barco al contenedor visual
      contenedorScroll.add(barco);

      // Actualiza la posición horizontal para el siguiente barco
      xOffset += espacioEntreBarcos;
    }

    // Ajusta el tamaño del contenedor para que abarque todos los barcos
    contenedorScroll.size = Vector2(xOffset, size.y);
  }
}
