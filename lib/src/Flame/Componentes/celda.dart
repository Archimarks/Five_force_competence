import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// ENUM: EstadoCelda
///
/// Define los posibles estados que puede tener una celda en el tablero.
///
/// - vacia:        La celda no contiene ningún objeto.
/// - barco:        La celda contiene una parte de un barco.
/// - atacada:      La celda fue atacada, pero no había barco.
/// - impactada:    La celda fue atacada y contenía parte de un barco.
/// ---------------------------------------------------------------------------
enum EstadoCelda { vacia, barco, atacada, impactada }

/// ---------------------------------------------------------------------------
/// COMPONENTE: Celda
///
/// Representa una celda individual dentro del tablero de juego. Cada celda
/// conoce su posición lógica (fila y columna), su estado actual, y los
/// cuadrantes a los que pertenece.
///
/// También se encarga de su renderizado visual utilizando colores distintos
/// según el estado en el que se encuentre.
/// ---------------------------------------------------------------------------
class Celda extends PositionComponent {
  /// Fila de la celda en el tablero (0 a 11).
  final int fila;

  /// Columna de la celda en el tablero (0 a 11).
  final int columna;

  /// Estado actual de la celda.
  EstadoCelda estado;

  /// Conjunto de nombres de cuadrantes a los que esta celda pertenece.
  final Set<String> cuadrantes = {};

  /// Constructor base.
  Celda({required this.fila, required this.columna, this.estado = EstadoCelda.vacia});

  /// Retorna `true` si la celda contiene una parte de un barco.
  bool get tieneBarco => estado == EstadoCelda.barco;

  /// Marca la celda como atacada.
  ///
  /// - Si tenía un barco, cambia a `impactada`.
  /// - Si no, cambia a `atacada`.
  void atacar() {
    if (estado == EstadoCelda.barco) {
      estado = EstadoCelda.impactada;
    } else if (estado == EstadoCelda.vacia) {
      estado = EstadoCelda.atacada;
    }
  }

  /// Asocia esta celda a un cuadrante por su nombre (por ejemplo: "A", "B", etc.).
  void agregarACuadrante(String nombreCuadrante) {
    cuadrantes.add(nombreCuadrante);
  }

  /// Método de renderizado de la celda.
  ///
  /// Dibuja un rectángulo coloreado según el estado y un borde negro.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Pintado del fondo según estado
    final paint =
        Paint()
          ..color = _obtenerColorPorEstado()
          ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), paint);

    // Borde negro de la celda
    final borde =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRect(size.toRect(), borde);
  }

  /// Devuelve el color asociado al estado actual de la celda.
  Color _obtenerColorPorEstado() {
    switch (estado) {
      case EstadoCelda.vacia:
        return Colors.blue.shade200;
      case EstadoCelda.barco:
        return Colors.grey.shade700;
      case EstadoCelda.atacada:
        return Colors.orange;
      case EstadoCelda.impactada:
        return Colors.red;
    }
  }
}
