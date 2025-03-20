/// *****************************************************************
/// * Nombre del Archivo: either.dart
/// * Proyecto: Five Force Competence
/// * Descripción: Implementación de la clase Either para manejo de errores.
/// * Autores: Marcos Alejandro Collazos Marmolejo, Geraldine Perilla Valderrama
/// * Notas:
/// *      - Se utiliza para encapsular errores y valores de éxito.
/// *      - Left representa un fallo, Right representa un caso de éxito.
/// *****************************************************************
library;

/// Clase genérica Either para manejar resultados con éxito o error.
///
/// - `Left` representa un fallo.
/// - `Right` representa un caso de éxito.
class Either<Left, Right> {
  /// Valor de fallo (si existe).
  final Left? _left;

  /// Valor de éxito (si existe).
  final Right? _right;

  /// Indica si el resultado es un fallo (`true` si es Left, `false` si es Right).
  final bool isLeft;

  /// Constructor privado para asegurar el uso de las factorías.
  Either._(this._left, this._right, this.isLeft);

  /// Factoría para crear una instancia de fallo (`Left`).
  factory Either.left(Left failure) {
    return Either._(failure, null, true);
  }

  /// Factoría para crear una instancia de éxito (`Right`).
  factory Either.right(Right value) {
    return Either._(null, value, false);
  }

  /// Ejecuta la función correspondiente dependiendo del estado de Either.
  ///
  /// - Si es `Left`, ejecuta la función `left`.
  /// - Si es `Right`, ejecuta la función `right`.
  T when<T>(T Function(Left) left, T Function(Right) right) {
    return isLeft ? left(_left as Left) : right(_right as Right);
  }
}
