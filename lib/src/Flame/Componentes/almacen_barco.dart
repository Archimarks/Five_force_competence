/// ---------------------------------------------------------------------------
/// `AlmacenBarco` - Componente lateral del juego que contiene barcos iniciales
/// disponibles para arrastrar hacia el tablero. Permite visualización clara
/// y separación del tablero de juego.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'barco.dart'; // Importa la clase Barco, que define los componentes de los barcos

/// Componente que actúa como un "almacén" visual donde se muestran los barcos
/// iniciales antes de ser colocados en el tablero. Los jugadores pueden
/// arrastrar estos barcos desde aquí hacia el tablero.
class AlmacenBarco extends PositionComponent with HasGameRef, DragCallbacks {
  /// Lista de barcos que se mostrarán inicialmente en el almacén.
  final List<Barco> barcosIniciales;

  /// Espacio horizontal en píxeles entre cada barco dentro del contenedor.
  final double espacioEntreBarcos;

  /// Contenedor que organiza visualmente los barcos dentro del almacén.
  late final PositionComponent contenedorScroll;

  /// Constructor que inicializa posición, tamaño del almacén, barcos y espacio.
  AlmacenBarco({
    required this.barcosIniciales,
    required this.espacioEntreBarcos,
    required Vector2 position, // Posición del almacén en el mundo del juego
    required Vector2 size, // Tamaño del área del almacén
  }) : super(position: position, size: size);

  /// Método que se ejecuta al cargar el componente en el juego.
  /// Se asegura de que todos los barcos estén cargados y luego los posiciona.
  @override
  Future<void> onLoad() async {
    // Espera a que todos los barcos iniciales terminen su proceso de carga.
    await Future.wait(barcosIniciales.map((b) async => b.onLoad()));

    // Crea un contenedor para agrupar los barcos dentro del almacén.
    contenedorScroll = PositionComponent();

    // Agrega el contenedor como hijo de este componente para que se renderice.
    add(contenedorScroll);

    // Llama al método encargado de colocar visualmente los barcos en línea.
    await _colocarBarcos();
  }

  /// Método privado que posiciona los barcos dentro del contenedor.
  /// Calcula la posición horizontal de cada barco dejando espacio entre ellos.
  Future<void> _colocarBarcos() async {
    double xOffset = 0; // Posición horizontal inicial para el primer barco.

    // Itera sobre todos los barcos y los coloca alineados horizontalmente.
    for (final barco in barcosIniciales) {
      // Centra verticalmente el barco dentro del contenedor del almacén.
      barco.position = Vector2(
        xOffset,
        (size.y - barco.size.y) / 2, // Centrado vertical en el almacén
      );

      // Agrega el barco al contenedor visual.
      contenedorScroll.add(barco);

      // Aumenta el desplazamiento horizontal para el próximo barco.
      xOffset += espacioEntreBarcos;
    }

    // Ajusta el tamaño del contenedor para que abarque todos los barcos colocados.
    contenedorScroll.size = Vector2(xOffset, size.y);
  }
}
