/// ---------------------------------------------------------------------------
/// Archivo: fuerza.dart
/// Desarrolladores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// Descripción:
/// Define el enumerado Fuerza que representa los distintos niveles de poder de
/// las cinco fuerzas de Porter. Cada nivel se asocia con una longitud de barco
/// específica.
/// ---------------------------------------------------------------------------
library;

/// Enumerado que representa las cinco fuerzas de Porter y asocia cada fuerza
/// con la longitud del barco que la representa en el juego.
enum Fuerza {
  /// Poder de negociación de los compradores, representado por un barco de 5 celdas.
  poderNegociacionCompradores(longitudBarco: 5),

  /// Poder de negociación de los proveedores, representado por un barco de 4 celdas.
  poderNegociacionProveedores(longitudBarco: 4),

  /// Amenaza de nuevos competidores entrantes, representado por un barco de 3 celdas.
  amenazaNuevosCompetidores(longitudBarco: 3),

  /// Intensidad de la rivalidad entre los competidores existentes, representado por un barco de 2 celdas.
  rivalidadEntreCompetidores(longitudBarco: 2),

  /// Amenaza de productos o servicios sustitutos, representado por un barco de 1 celda.
  amenazaProductosSustitutos(longitudBarco: 1);

  /// Longitud del barco asociado a esta fuerza.
  final int longitudBarco;

  /// Constructor privado para asociar la longitud del barco a cada fuerza.
  const Fuerza({required this.longitudBarco});
}
