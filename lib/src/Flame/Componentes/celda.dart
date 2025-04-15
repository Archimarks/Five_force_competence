// celda.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// ENUM: EstadoCelda
///
/// Representa los distintos estados posibles de una celda en el tablero.
/// Cada estado influye en su apariencia y comportamiento en el juego.
/// ---------------------------------------------------------------------------
enum EstadoCelda {
  /// Celda libre, sin barco ni ataques.
  vacia,

  /// Parte de un barco está ocupando esta celda.
  barco,

  /// La celda fue atacada, pero no había un barco.
  atacada,

  /// La celda fue atacada y contenía parte de un barco.
  impactada,

  /// La celda se resalta como opción válida para colocar un barco.
  resaltada,

  /// La celda se resalta como opción inválida para colocar un barco.
  rechazada,
}

/// ---------------------------------------------------------------------------
/// COMPONENTE: Celda
///
/// Representa una celda del tablero de juego.
/// Gestiona su estado lógico y su representación visual según dicho estado.
/// ---------------------------------------------------------------------------
class Celda extends PositionComponent {
  /// Fila donde se ubica la celda en el tablero.
  final int fila;

  /// Columna donde se ubica la celda en el tablero.
  final int columna;

  /// Estado actual de la celda (lógico y visual).
  EstadoCelda estado;

  /// Constructor principal. Inicializa la celda como vacía por defecto.
  Celda({required this.fila, required this.columna, this.estado = EstadoCelda.vacia}) : super(size: Vector2.all(50.0)); // Tamaño estándar 50x50

  /// Devuelve `true` si la celda contiene un barco.
  bool get tieneBarco => estado == EstadoCelda.barco;

  /// Marca la celda como atacada.
  /// Si tenía un barco, se considera impactada. Si estaba vacía, simplemente atacada.
  void atacar() {
    if (estado == EstadoCelda.barco) {
      estado = EstadoCelda.impactada;
    } else if (estado == EstadoCelda.vacia) {
      estado = EstadoCelda.atacada;
    }
  }

  /// Indica que la celda es válida para colocar un barco (resaltado visual en verde).
  void resaltar() {
    if (estado == EstadoCelda.vacia) {
      estado = EstadoCelda.resaltada;
    }
  }

  /// Indica que la celda es inválida para colocar un barco (resaltado visual en rojo).
  void rechazar() {
    if (estado == EstadoCelda.vacia) {
      estado = EstadoCelda.rechazada;
    }
  }

  /// Restaura la celda a su estado original si estaba resaltada o rechazada.
  void resetearColor() {
    if (estado == EstadoCelda.resaltada || estado == EstadoCelda.rechazada) {
      estado = EstadoCelda.vacia;
    }
  }

  /// Marca la celda como ocupada por un barco.
  void colocarBarco() {
    estado = EstadoCelda.barco;
  }

  /// Libera la celda, dejándola vacía.
  void liberar() {
    estado = EstadoCelda.vacia;
  }

  /// Renderiza la celda de acuerdo a su estado actual.
  /// Aplica un color de fondo específico y un borde negro delgado.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Dibuja el fondo con el color correspondiente al estado actual.
    final Paint fondo =
        Paint()
          ..color = _colorPorEstado()
          ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), fondo);

    // Dibuja un borde negro alrededor de la celda.
    final Paint borde =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRect(size.toRect(), borde);
  }

  /// Devuelve el color correspondiente al estado actual de la celda.
  Color _colorPorEstado() {
    switch (estado) {
      case EstadoCelda.vacia:
        return Colors.blue.shade200;
      case EstadoCelda.barco:
        return Colors.grey.shade700;
      case EstadoCelda.atacada:
        return Colors.orange;
      case EstadoCelda.impactada:
        return Colors.red;
      case EstadoCelda.resaltada:
        return Colors.green.withOpacity(0.5);
      case EstadoCelda.rechazada:
        return Colors.red.withOpacity(0.5);
    }
  }

  /// Define la igualdad entre celdas comparando su posición lógica.
  @override
  bool operator ==(Object other) => other is Celda && other.fila == fila && other.columna == columna;

  /// Devuelve un hash único en función de la posición lógica.
  @override
  int get hashCode => Object.hash(fila, columna);
}
