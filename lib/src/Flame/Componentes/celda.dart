import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// ENUM: EstadoCelda
///
/// Define los posibles estados que puede tener una celda en el tablero.
/// - vacia:      La celda no contiene ningún objeto.
/// - barco:      La celda contiene una parte de un barco.
/// - atacada:    La celda fue atacada, pero no había barco.
/// - impactada:  La celda fue atacada y contenía parte de un barco.
/// ---------------------------------------------------------------------------
enum EstadoCelda { vacia, barco, atacada, impactada }

/// ---------------------------------------------------------------------------
/// COMPONENTE: Celda
///
/// Representa una celda individual dentro del tablero de juego.
/// Cada celda conoce su posición lógica, su estado actual, y los cuadrantes
/// a los que pertenece. Gestiona su apariencia visual según su estado.
/// ---------------------------------------------------------------------------
class Celda extends PositionComponent {
  /// Posición lógica en el tablero.
  final int fila;
  final int columna;

  /// Estado actual de la celda.
  EstadoCelda _estado;

  /// Cuadrantes asociados a esta celda.
  final Set<String> _cuadrantes = {};

  /// Color de fondo temporal (por ejemplo para interacciones visuales).
  Color _colorTemporal = Colors.transparent;

  /// Constructor
  Celda({required this.fila, required this.columna, EstadoCelda estadoInicial = EstadoCelda.vacia})
    : _estado = estadoInicial,
      super(size: Vector2.all(50.0));

  /// Getters y lógica
  EstadoCelda get estado => _estado;

  bool get tieneBarco => _estado == EstadoCelda.barco;

  Set<String> get cuadrantes => _cuadrantes;

  /// Ataca la celda según su estado actual.
  void atacar() {
    if (_estado == EstadoCelda.barco) {
      _estado = EstadoCelda.impactada;
    } else if (_estado == EstadoCelda.vacia) {
      _estado = EstadoCelda.atacada;
    }
  }

  /// Asocia esta celda a un cuadrante.
  void agregarACuadrante(String nombreCuadrante) {
    _cuadrantes.add(nombreCuadrante);
  }

  /// Define la celda como válida para colocar un barco (indicador visual).
  void permitirBarco() {
    _colorTemporal = Colors.green;
  }

  /// Indica que no se puede colocar un barco en esta celda (indicador visual).
  void rechazarBarco() {
    _colorTemporal = Colors.red;
  }

  /// Restablece el color temporal a transparente.
  void resetearColor() {
    _colorTemporal = Colors.transparent;
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
    }
  }

  /// Comparación entre celdas por fila y columna.
  @override
  bool operator ==(Object other) =>
      other is Celda && other.fila == fila && other.columna == columna;

  @override
  int get hashCode => Object.hash(fila, columna);
}
