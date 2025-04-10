// celda.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// ENUM: EstadoCelda
///
/// Define los posibles estados que puede tener una celda en el tablero.
/// - vacia:     La celda no contiene ningún objeto.
/// - barco:     La celda contiene una parte de un barco.
/// - atacada:   La celda fue atacada, pero no había barco.
/// - impactada: La celda fue atacada y contenía parte de un barco.
/// - resaltada: La celda está resaltada visualmente para colocación.
/// - rechazada: La celda está marcada visualmente como inválida para colocación.
/// ---------------------------------------------------------------------------
enum EstadoCelda { vacia, barco, atacada, impactada, resaltada, rechazada }

/// ---------------------------------------------------------------------------
/// COMPONENTE: Celda
///
/// Representa una celda individual dentro del tablero de juego.
/// Cada celda conoce su posición lógica y su estado actual.
/// Gestiona su apariencia visual según su estado.
/// ---------------------------------------------------------------------------
class Celda extends PositionComponent {
  /// Posición lógica en el tablero.
  final int fila;
  final int columna;

  /// Estado actual de la celda.
  EstadoCelda _estado;

  /// Color de fondo temporal (por ejemplo para interacciones visuales).
  Color _colorTemporal = Colors.transparent;

  /// Constructor
  Celda({required this.fila, required this.columna, EstadoCelda estadoInicial = EstadoCelda.vacia})
    : _estado = estadoInicial,
      super(size: Vector2.all(50.0));

  /// Getters y lógica
  EstadoCelda get estado => _estado;
  set estado(EstadoCelda nuevoEstado) {
    _estado = nuevoEstado;
  }

  bool get tieneBarco => _estado == EstadoCelda.barco;

  /// Ataca la celda según su estado actual.
  void atacar() {
    if (_estado == EstadoCelda.barco) {
      _estado = EstadoCelda.impactada;
    } else if (_estado == EstadoCelda.vacia) {
      _estado = EstadoCelda.atacada;
    }
  }

  /// Define la celda como válida para colocar un barco (indicador visual).
  void resaltar() {
    _colorTemporal = Colors.green.withOpacity(0.5);
    _estado = EstadoCelda.resaltada;
  }

  /// Indica que no se puede colocar un barco en esta celda (indicador visual).
  void rechazar() {
    _colorTemporal = Colors.red.withOpacity(0.5);
    _estado = EstadoCelda.rechazada;
  }

  /// Restablece el color temporal a transparente y el estado a vacío (si no tiene barco).
  void resetearColor() {
    _colorTemporal = Colors.transparent;
    if (_estado == EstadoCelda.resaltada || _estado == EstadoCelda.rechazada) {
      _estado = EstadoCelda.vacia;
    }
  }

  /// Marca la celda como que contiene parte de un barco.
  void colocarBarco() {
    _estado = EstadoCelda.barco;
  }

  /// Renderizado visual de la celda.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Paint fondo =
        Paint()
          ..color = _colorTemporal == Colors.transparent ? _obtenerColorPorEstado() : _colorTemporal
          ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), fondo);

    final Paint borde =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRect(size.toRect(), borde);
  }

  /// Devuelve el color correspondiente al estado de la celda.
  Color _obtenerColorPorEstado() {
    switch (_estado) {
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

  /// Comparación entre celdas por fila y columna.
  @override
  bool operator ==(Object other) =>
      other is Celda && other.fila == fila && other.columna == columna;

  @override
  int get hashCode => Object.hash(fila, columna);
}
