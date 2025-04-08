/// ---------------------------------------------------------------------------
/// Archivo: fuerza.dart
/// Desarrolladores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// Descripción:
/// Define el enumerado Fuerza que representa los distintos niveles de poder de
/// las cinco fuerzas de Porter. Cada nivel se asocia con una longitud de barco
/// específica y un cuadrante del tablero.
/// ---------------------------------------------------------------------------
library;

enum Fuerza {
  muyAlto, // → Barco de 5 celdas
  alto, // → Barco de 4 celdas
  medio, // → Barco de 3 celdas
  bajo, // → Barco de 2 celdas
  muyBajo, // → Barco de 1 celda
}

/// Extensión para añadir propiedades útiles al enum Fuerza.
extension FuerzaExtension on Fuerza {
  /// Retorna un nombre legible para mostrar en pantalla
  String get nombre {
    switch (this) {
      case Fuerza.muyAlto:
        return 'MUY ALTO';
      case Fuerza.alto:
        return 'ALTO';
      case Fuerza.medio:
        return 'MEDIO';
      case Fuerza.bajo:
        return 'BAJO';
      case Fuerza.muyBajo:
        return 'MUY BAJO';
    }
  }

  /// Retorna el número de celdas correspondiente al tamaño del barco
  int get longitud {
    switch (this) {
      case Fuerza.muyAlto:
        return 5;
      case Fuerza.alto:
        return 4;
      case Fuerza.medio:
        return 3;
      case Fuerza.bajo:
        return 2;
      case Fuerza.muyBajo:
        return 1;
    }
  }

  /// Retorna el nombre del cuadrante al que pertenece esta fuerza
  String get cuadrante {
    switch (this) {
      case Fuerza.muyAlto:
        return 'A - Negociación con Compradores';
      case Fuerza.alto:
        return 'B - Negociación con Proveedores';
      case Fuerza.medio:
        return 'C - Potenciales Competidores';
      case Fuerza.bajo:
        return 'D - Rivalidad Competitiva';
      case Fuerza.muyBajo:
        return 'E - Productos Sustitutos';
    }
  }
}
