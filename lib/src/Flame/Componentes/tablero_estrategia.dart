/// ---------------------------------------------------------------------------
/// `TableroEstrategia` - Componente principal que combina la funcionalidad del
/// tablero de juego y el almacén de barcos. Permite a los jugadores arrastrar
/// y colocar barcos desde el almacén al tablero para su despliegue estratégico.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Import para UniqueKey

import 'barco.dart'; // Clase `Barco`, que representa individualmente cada unidad flotante.
import 'celda.dart';
import 'coordenada.dart';

/// ---------------------------------------------------------------------------
/// CLASE PRINCIPAL: TableroEstrategia
/// Combina la lógica del tablero de juego y el almacén de barcos en un solo componente.
/// ---------------------------------------------------------------------------
class TableroEstrategia extends PositionComponent with HasGameRef {
  // ===========================================================================
  // ⚙️ CONFIGURACIÓN DEL TABLERO
  // ===========================================================================

  final int filas;
  final int columnas;
  final double tamanioCelda;
  late final List<List<Celda>> grilla; // Matriz 2D de celdas
  final List<Coordenada> coordenadas = []; // Coordenadas visuales (A, B, C / 1, 2, 3)
  final List<Barco> barcosEnTablero = []; // Lista de barcos colocados en el tablero

  // ===========================================================================
  // 📦 CONFIGURACIÓN DEL ALMACÉN DE BARCOS
  // ===========================================================================

  /// Lista de datos de los barcos iniciales (usados como plantillas).
  final List<Map<String, dynamic>> datosBarcosIniciales;

  /// Espaciado horizontal entre cada barco en píxeles.
  final double espacioEntreBarcos;

  /// Componente interno que contiene y organiza visualmente los barcos del almacén.
  late final PositionComponent contenedorScrollAlmacen;

  // ===========================================================================
  // 🏗️ CONSTRUCTOR
  // ===========================================================================

  /// Crea un nuevo `TableroEstrategia` con las dimensiones y configuraciones dadas.
  TableroEstrategia({
    required this.filas,
    required this.columnas,
    required this.tamanioCelda,
    required this.datosBarcosIniciales,
    required this.espacioEntreBarcos,
    super.position,
    super.size,
  }) : grilla = List.generate(
         filas,
         (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)),
       );

  /// Área rectangular que ocupa el tablero en coordenadas globales.
  Rect get areaTablero => position.toOffset() & size.toSize();

  // ===========================================================================
  // 🚀 CICLO DE VIDA - CARGA DEL COMPONENTE
  // ===========================================================================

  @override
  Future<void> onLoad() async {
    // Inicializar el tablero
    await _crearCeldas();
    _agregarCoordenadasVisuales();

    // Inicializar el almacén de barcos
    contenedorScrollAlmacen = PositionComponent();
    add(contenedorScrollAlmacen);
    await _inicializarAlmacenBarcos();
  }

  // ===========================================================================
  // 🛠️ MÉTODOS PRIVADOS - GESTIÓN DEL TABLERO
  // ===========================================================================

  /// Posiciona las celdas correctamente en la grilla y las agrega a la escena.
  Future<void> _crearCeldas() async {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final celda =
            grilla[fila][columna]
              ..position = Vector2(
                columna * tamanioCelda + tamanioCelda,
                fila * tamanioCelda + tamanioCelda,
              )
              ..size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Genera etiquetas visuales (A–Z y 1–N) alrededor del tablero.
  void _agregarCoordenadasVisuales() {
    const letras = 'ABCDEFGHIJKL'; // Puedes hacerlo dinámico si quieres más columnas

    for (int columna = 0; columna < columnas; columna++) {
      coordenadas.add(
        Coordenada(
          texto: letras[columna],
          posicion: Vector2(columna * tamanioCelda + tamanioCelda + tamanioCelda / 2, 0),
        ),
      );
    }

    for (int fila = 0; fila < filas; fila++) {
      coordenadas.add(
        Coordenada(
          texto: '${fila + 1}',
          posicion: Vector2(0, fila * tamanioCelda + tamanioCelda + tamanioCelda / 2),
        ),
      );
    }

    addAll(coordenadas);
  }

  /// Retorna una celda válida en la posición especificada o null si es inválida.
  Celda? obtenerCelda(int fila, int columna) {
    final filaValida = fila >= 0 && fila < filas;
    final columnaValida = columna >= 0 && columna < columnas;
    return filaValida && columnaValida ? grilla[fila][columna] : null;
  }

  /// Marca un conjunto de celdas como ocupadas por un barco.
  void ocuparCeldas(List<Vector2> posiciones) {
    for (final pos in posiciones) {
      obtenerCelda(pos.y.toInt(), pos.x.toInt())?.colocarBarco();
    }
  }

  /// Libera un conjunto de celdas para permitir futuras colocaciones.
  void liberarCeldas(List<Vector2> posiciones) {
    for (final pos in posiciones) {
      obtenerCelda(pos.y.toInt(), pos.x.toInt())?.liberar();
    }
  }

  /// Restaura los colores de todas las celdas a su estado original.
  void resetearResaltado() {
    for (final fila in grilla) {
      for (final celda in fila) {
        celda.resetearColor();
      }
    }
  }

  /// Intenta agregar un barco en la posición indicada si es válida.
  void agregarBarco(Barco barco, Vector2 gridPos, bool esVertical) {
    if (!esPosicionValida(gridPos, barco.longitud, esVertical)) return;

    final celdas = calcularCeldasOcupadas(gridPos, barco.longitud, esVertical);
    ocuparCeldas(celdas);

    // Actualiza la posición del barco en el mundo basada en la gridPos
    barco.position = gridToWorld(gridPos);
    // Asegúrate de que la orientación del barco sea la correcta
    barco.rotar(esVertical); // Llama al método rotar del Barco

    barcosEnTablero.add(barco);
    add(barco);
  }

  /// Actualiza posición y orientación de un barco, validando primero.
  bool actualizarBarco(
    Barco barco,
    Vector2 nuevaPos,
    bool nuevaOrientacionVertical, {
    required bool orientacionActualVertical,
  }) {
    final nuevaGrid = worldToGrid(nuevaPos);

    if (!esPosicionValida(nuevaGrid, barco.longitud, nuevaOrientacionVertical)) return false;

    final celdasAntiguas = calcularCeldasOcupadas(
      worldToGrid(barco.position),
      barco.longitud,
      orientacionActualVertical,
    );

    final celdasNuevas = calcularCeldasOcupadas(
      nuevaGrid,
      barco.longitud,
      nuevaOrientacionVertical,
    );

    liberarCeldas(celdasAntiguas);
    ocuparCeldas(celdasNuevas);

    barco.position = gridToWorld(nuevaGrid);
    barco.rotar(nuevaOrientacionVertical);

    return true;
  }

  /// Valida si una posición en la grilla está libre para colocar un barco.
  bool esPosicionValida(Vector2 gridPos, int longitud, bool esVertical) {
    final int startX = gridPos.x.floor();
    final int startY = gridPos.y.floor();

    for (int i = 0; i < longitud; i++) {
      final fila = esVertical ? startY + i : startY;
      final columna = esVertical ? startX : startX + i;

      final celda = obtenerCelda(fila, columna);
      if (celda == null || celda.tieneBarco) return false;
    }

    return true;
  }

  /// Resalta un área como válida o inválida para colocar un barco.
  void resaltarPosicion(
    Vector2 gridPos,
    int longitud,
    bool esVertical, [
    List<Vector2> celdasPropias = const [],
  ]) {
    resetearResaltado();

    final celdas = <Vector2>[];

    for (int i = 0; i < longitud; i++) {
      final x = gridPos.x + (esVertical ? 0 : i.toDouble());
      final y = gridPos.y + (esVertical ? i.toDouble() : 0);

      if (x >= columnas || y >= filas) {
        _resaltarComoRechazado(celdas);
        return;
      }

      final celda = obtenerCelda(y.toInt(), x.toInt());
      if (celda == null || (celda.tieneBarco && !celdasPropias.contains(Vector2(x, y)))) {
        _resaltarComoRechazado(celdas);
        return;
      }

      celdas.add(Vector2(x, y));
    }

    for (final coord in celdas) {
      obtenerCelda(coord.y.toInt(), coord.x.toInt())?.resaltar();
    }
  }

  /// Muestra las celdas como inválidas visualmente (color rojo, por ejemplo).
  void _resaltarComoRechazado(List<Vector2> celdasParciales) {
    for (final coord in celdasParciales) {
      obtenerCelda(coord.y.toInt(), coord.x.toInt())?.rechazar();
    }
  }

  /// Retorna una lista de coordenadas que ocuparía un barco en una posición dada.
  List<Vector2> calcularCeldasOcupadas(Vector2 gridPos, int longitud, bool esVertical) {
    final celdas = <Vector2>[];
    final filaInicio = gridPos.y.floor();
    final columnaInicio = gridPos.x.floor();

    for (int i = 0; i < longitud; i++) {
      final fila = esVertical ? filaInicio + i : filaInicio;
      final columna = esVertical ? columnaInicio : columnaInicio + i;
      celdas.add(Vector2(columna.toDouble(), fila.toDouble()));
    }

    return celdas;
  }

  // ===========================================================================
  // ⚓ MÉTODOS PRIVADOS - GESTIÓN DEL ALMACÉN DE BARCOS
  // ===========================================================================

  /// Inicializa visualmente el almacén y coloca los barcos.
  Future<void> _inicializarAlmacenBarcos() async {
    double xOffset = 60; // Desplazamiento horizontal inicial

    // Itera sobre la configuración de cada barco inicial
    for (final datosBarco in datosBarcosIniciales) {
      final barcoVisual = _crearBarcoAlmacen(datosBarco);
      barcoVisual.position = Vector2(
        xOffset,
        (size.y - barcoVisual.size.y) / 2, // Centrado vertical del barco
      );

      contenedorScrollAlmacen.add(barcoVisual);
      xOffset += espacioEntreBarcos;
    }

    // Ajusta el tamaño del contenedor para que abarque todos los barcos
    contenedorScrollAlmacen.size = Vector2(xOffset - espacioEntreBarcos, size.y);
  }

  /// Crea una instancia visual del `Barco` para el almacén a partir de los datos de configuración.
  Barco _crearBarcoAlmacen(Map<String, dynamic> datos) {
    final int longitud = datos['longitud'];
    final Map<String, String> rutasSprites = Map<String, String>.from(datos['sprites']);
    const double escala = 0.6; // Puedes hacerlo configurable si es necesario

    return Barco(
      longitud: longitud,
      rutasSprites: rutasSprites,
      escala: escala,
      // Los barcos en el almacén inician el proceso de arrastre
      onDragStartCallback: (barcoArrastrado) {
        // Crea una nueva instancia del barco que se va a arrastrar al tablero
        final nuevoBarco = _clonarBarcoParaTablero(barcoArrastrado);
        // Añade el nuevo barco a la escena en la posición del barco del almacén
        gameRef.add(nuevoBarco..position = barcoArrastrado.position.clone());
        // Establece el barco original del almacén como no visible durante el arrastre
        barcoArrastrado.removeFromParent();
      },
      onDragEndCallback: (barcoArrastrado) async {
        // Cuando se suelta el barco, intentamos colocarlo en el tablero
        final gridPosition = worldToGrid(barcoArrastrado.position);
        final esValida = esPosicionValida(
          gridPosition,
          barcoArrastrado.longitud,
          barcoArrastrado.esVertical,
        );

        if (esValida) {
          agregarBarco(barcoArrastrado, gridPosition, barcoArrastrado.esVertical);
        } else {
          // Si la colocación no es válida, espera un breve momento antes de eliminar
          await Future.delayed(const Duration(milliseconds: 50));
          if (barcoArrastrado.isMounted) {
            barcoArrastrado.removeFromParent();
            // Re-crea el barco en el almacén
            final datosOriginal = datosBarcosIniciales.firstWhere(
              (data) =>
                  data['longitud'] == barcoArrastrado.longitud &&
                  data['sprites'].toString() == barcoArrastrado.barcoVisual.sprites.toString(),
            );
            final nuevoBarcoAlmacen = _crearBarcoAlmacen(datosOriginal);
            nuevoBarcoAlmacen.position = barcoArrastrado.position.clone();
            contenedorScrollAlmacen.add(nuevoBarcoAlmacen);
            _reorganizarBarcosAlmacen(); // Opcional: reorganizar visualmente el almacén
          }
        }
      },
    );
  }

  /// Crea una nueva instancia del `Barco` a partir de otra instancia para arrastrar al tablero.
  Barco _clonarBarcoParaTablero(Barco barcoOriginal) {
    return Barco(
      longitud: barcoOriginal.longitud,
      rutasSprites: Map<String, String>.from(
        barcoOriginal.rutasSprites,
      ), // Usamos rutasSprites del Barco original
      escala: barcoOriginal.scale.x,
      onDragStartCallback: (barco) {}, // No necesitamos este callback en la copia
      onDragEndCallback: (barco) {}, // La lógica de soltar se maneja en el Tablero
      id: UniqueKey().toString(), // Aseguramos que la copia tenga un nuevo ID
    );
  }

  /// Reorganiza la posición de los barcos en el almacén después de un arrastre cancelado.
  void _reorganizarBarcosAlmacen() {
    contenedorScrollAlmacen.removeAll(contenedorScrollAlmacen.children.whereType<Barco>());
    double xOffset = 0;
    for (final datosBarco in datosBarcosIniciales) {
      final barcoVisual = _crearBarcoAlmacen({...datosBarco}); // Crea una nueva instancia
      barcoVisual.position = Vector2(xOffset, (size.y - barcoVisual.size.y) / 2);
      contenedorScrollAlmacen.add(barcoVisual);
      xOffset += barcoVisual.size.x + espacioEntreBarcos;
    }
    contenedorScrollAlmacen.size = Vector2(xOffset - espacioEntreBarcos, size.y);
  }
}

/// ---------------------------------------------------------------------------
/// EXTENSIONES: Conversión entre posiciones de mundo y de grilla.
/// ---------------------------------------------------------------------------
extension TableroEstrategiaUtils on TableroEstrategia {
  /// Convierte una posición absoluta del mundo a una celda de la grilla.
  Vector2 worldToGrid(Vector2 worldPos) {
    return Vector2(
      (worldPos.x - position.x) / tamanioCelda,
      (worldPos.y - position.y) / tamanioCelda,
    );
  }

  /// Convierte coordenadas de grilla a posición absoluta en el mundo.
  Vector2 gridToWorld(Vector2 gridPos) {
    return Vector2(
      position.x + gridPos.x * tamanioCelda + tamanioCelda / 2,
      position.y + gridPos.y * tamanioCelda + tamanioCelda / 2,
    );
  }
}
