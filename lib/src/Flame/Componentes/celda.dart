// celda.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// ENUM: EstadoCelda
///
/// Representa los distintos estados posibles de una celda en el tablero.
/// Cada estado tiene un propósito visual y/o funcional dentro del juego.
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

  /// La celda se está resaltando como opción válida para colocar un barco.
  resaltada,

  /// La celda se está resaltando como opción inválida para colocar un barco.
  rechazada,
}

/// ---------------------------------------------------------------------------
/// COMPONENTE: Celda
///
/// Representa una celda individual del tablero.
/// Administra su estado interno y renderiza su apariencia visual de acuerdo
/// al estado en el que se encuentre (ataque, barco, resaltado, etc.).
/// ---------------------------------------------------------------------------
class Celda extends PositionComponent {
  /// Posición lógica de la celda en el tablero (fila y columna).
  final int fila;
  final int columna;

  // Estado actual de la celda.
  EstadoCelda estado;

  // Color superpuesto temporal (para efectos visuales como resaltar/rechazar).
  Color _colorTemporal = Colors.transparent;

  /// Constructor principal de la celda.
  /// Por defecto, la celda inicia en estado [EstadoCelda.vacia].
  Celda({required this.fila, required this.columna, this.estado = EstadoCelda.vacia})
    : super(size: Vector2.all(50.0)); // Tamaño fijo de 50x50

  /// Indica si esta celda contiene un barco.
  bool get tieneBarco => estado == EstadoCelda.barco;

  /// Marca la celda como atacada. Si tenía un barco, pasa a estado 'impactada',
  /// si estaba vacía, pasa a 'atacada'. No cambia nada en otros casos.
  void atacar() {
    if (estado == EstadoCelda.barco) {
      estado = EstadoCelda.impactada;
    } else if (estado == EstadoCelda.vacia) {
      estado = EstadoCelda.atacada;
    }
  }

  /// Aplica un resaltado visual en verde, si está vacía.
  void resaltar() {
    if (estado == EstadoCelda.vacia) {
      _colorTemporal = Colors.green.withValues(alpha: 0.5);
      estado = EstadoCelda.resaltada;
    }
  }

  /// Aplica un resaltado visual en rojo, si está vacía.
  void rechazar() {
    if (estado == EstadoCelda.vacia) {
      _colorTemporal = Colors.red.withValues(alpha: 0.5);
      estado = EstadoCelda.rechazada;
    }
  }

  /// Elimina el color temporal y restablece el estado si estaba en
  /// modo resaltado o rechazado. No afecta a celdas con barco o ataque.
  void resetearColor() {
    _colorTemporal = Colors.transparent;
    if (estado == EstadoCelda.resaltada || estado == EstadoCelda.rechazada) {
      estado = EstadoCelda.vacia;
    }
  }

  /// Marca la celda como ocupada por un barco. Se aplica sin validación previa.
  void colocarBarco() {
    estado = EstadoCelda.barco;
    _colorTemporal = Colors.transparent;
  }

  /// Libera la celda, dejándola vacía y eliminando cualquier color temporal.
  void liberar() {
    estado = EstadoCelda.vacia;
    _colorTemporal = Colors.transparent;
  }

  /// Renderiza la celda según su estado actual.
  /// Aplica un color de fondo (por estado o temporal) y dibuja un borde negro.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Color de fondo: usa el color temporal si está presente.
    final Paint fondo =
        Paint()
          ..color = _colorTemporal == Colors.transparent ? _obtenerColorPorEstado() : _colorTemporal
          ..style = PaintingStyle.fill;

    // Dibuja el fondo de la celda.
    canvas.drawRect(size.toRect(), fondo);

    // Dibuja el borde de la celda.
    final Paint borde =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    canvas.drawRect(size.toRect(), borde);
  }

  /// Devuelve el color asociado a cada estado de celda.
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
      case EstadoCelda.resaltada:
        return Colors.green.withValues(alpha: 0.5);
      case EstadoCelda.rechazada:
        return Colors.red.withValues(alpha: 0.5);
    }
  }

  /// Sobrescribe la igualdad para comparar celdas por posición lógica.
  @override
  bool operator ==(Object other) =>
      other is Celda && other.fila == fila && other.columna == columna;

  /// Crea un hash único basado en la posición lógica.
  @override
  int get hashCode => Object.hash(fila, columna);
}
