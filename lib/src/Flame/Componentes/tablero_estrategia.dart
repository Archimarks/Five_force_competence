/// ---------------------------------------------------------------------------
/// `TableroEstrategia` - Componente principal que gestiona el tablero de juego
/// y la interacción con los barcos. Permite a los jugadores arrastrar y colocar
/// barcos dentro de su área.
/// ---------------------------------------------------------------------------
library;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'barco.dart';
import 'celda.dart';
import 'coordenada.dart';
import 'sector.dart';

/// ---------------------------------------------------------------------------
/// CLASE PRINCIPAL: TableroEstrategia
/// Gestiona la lógica del tablero de juego y la interacción de arrastre y colocación
/// de los barcos dentro de su área designada.
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
  late final List<Sector> sectores; // Sectore  (A, B, C, D, E)
  Sector? sectorActivo;

  // ===========================================================================
  // 📦 CONFIGURACIÓN INICIAL DE LOS BARCOS
  // ===========================================================================

  /// Lista de datos de los barcos iniciales para crear las instancias.
  final List<Map<String, dynamic>> datosBarcosIniciales;

  /// Espaciado horizontal entre cada barco en la disposición inicial.
  final double espacioEntreBarcos;

  /// Componente interno que contiene y organiza visualmente los barcos iniciales.
  late final PositionComponent contenedorBarcosIniciales;

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
  }) : grilla = List.generate(filas, (fila) => List.generate(columnas, (col) => Celda(fila: fila, columna: col)));

  /// Área rectangular que ocupa el tablero en coordenadas globales.
  Rect get areaTablero => Rect.fromLTWH(position.x, position.y, columnas * tamanioCelda, filas * tamanioCelda);

  /// Área rectangular que ocupa la sección inicial de los barcos.
  Rect get areaBarcosIniciales => Rect.fromLTWH(position.x, position.y + filas * tamanioCelda + tamanioCelda * 2, size.x, size.y - (filas * tamanioCelda + tamanioCelda * 2));

  // ===========================================================================
  // 🚀 CICLO DE VIDA - CARGA DEL COMPONENTE
  // ===========================================================================

  @override
  Future<void> onLoad() async {
    // Inicializar el tablero
    await _crearCeldas();
    _agregarCoordenadasVisuales();
    await _inicializarSectores();

    // Inicializar la disposición inicial de los barcos
    contenedorBarcosIniciales = PositionComponent();
    add(contenedorBarcosIniciales);
    await _inicializarBarcosIniciales();
  }

  // ===========================================================================
  // 🛠️ MÉTODOS PRIVADOS - GESTIÓN DEL TABLERO
  // ===========================================================================

  /// Inicializa la definición de los sectores del tablero, leyendo los valores de SharedPreferences.
  Future<void> _inicializarSectores() async {
    final prefs = await SharedPreferences.getInstance();

    sectores = [
      Sector(
        id: 'A',
        nombre: 'POTENCIALES COMPETIDORES',
        valor: _obtenerValorSector(prefs, 'POTENCIALES COMPETIDORES'),
        rect: Rect.fromLTRB(
          position.x + 0 * tamanioCelda + tamanioCelda, // left (columna 0)
          position.y + 0 * tamanioCelda + tamanioCelda, // top (fila 0)
          position.x + 7 * tamanioCelda, // right (columna 6 + 1)
          position.y + 7 * tamanioCelda, // bottom (fila 6 + 1)
        ),
      ),
      Sector(
        id: 'B',
        nombre: 'RIVALIDAD ENTRE COMPETIDORES',
        valor: _obtenerValorSector(prefs, 'RIVALIDAD ENTRE COMPETIDORES'),
        rect: Rect.fromLTRB(
          position.x + 0 * tamanioCelda + tamanioCelda, // left (columna 0)
          position.y + 6 * tamanioCelda + tamanioCelda, // top (fila 6)
          position.x + 7 * tamanioCelda, // right (columna 6 + 1)
          position.y + 13 * tamanioCelda, // bottom (fila 12 + 1)
        ),
      ),
      Sector(
        id: 'C',
        nombre: 'PODER DE NEGOCIACION DE COMPRADORES',
        valor: _obtenerValorSector(prefs, 'PODER DE NEGOCIACION DE COMPRADORES'),
        rect: Rect.fromLTRB(
          position.x + 6 * tamanioCelda + tamanioCelda, // left (columna 6)
          position.y + 0 * tamanioCelda + tamanioCelda, // top (fila 0)
          position.x + 13 * tamanioCelda, // right (columna 12 + 1)
          position.y + 7 * tamanioCelda, // bottom (fila 6 + 1)
        ),
      ),
      Sector(
        id: 'D',
        nombre: 'PODER DE NEGOCIACION DE PROVEEDORES',
        valor: _obtenerValorSector(prefs, 'PODER DE NEGOCIACION DE PROVEEDORES'),
        rect: Rect.fromLTRB(
          position.x + 6 * tamanioCelda + tamanioCelda, // left (columna 6)
          position.y + 6 * tamanioCelda + tamanioCelda, // top (fila 6)
          position.x + 13 * tamanioCelda, // right (columna 12 + 1)
          position.y + 13 * tamanioCelda, // bottom (fila 12 + 1)
        ),
      ),
      Sector(
        id: 'E',
        nombre: 'PRODUCTOS SUSTITUTOS',
        valor: _obtenerValorSector(prefs, 'PRODUCTOS SUSTITUTOS'),
        rect: Rect.fromLTRB(
          position.x + 3 * tamanioCelda + tamanioCelda, // left (columna 3)
          position.y + 3 * tamanioCelda + tamanioCelda, // top (fila 3)
          position.x + 10 * tamanioCelda, // right (columna 9 + 1)
          position.y + 10 * tamanioCelda, // bottom (fila 9 + 1)
        ),
      ),
    ];
  }

  /// Función auxiliar para obtener el valor de un sector desde SharedPreferences y mapearlo a un entero.
  int _obtenerValorSector(SharedPreferences prefs, String nombreSector) {
    String? valorString = prefs.getString(nombreSector);

    if (valorString != null && valorString.isNotEmpty) {
      switch (valorString.toUpperCase()) {
        case 'MUY ALTA':
          return 5;
        case 'ALTA':
          return 4;
        case 'MEDIO':
          return 3;
        case 'BAJA':
          return 2;
        case 'MUY BAJA':
        default:
          return 1;
      }
    } else {
      return 1;
    }
  }

  /// Posiciona las celdas correctamente en la grilla y las agrega a la escena.
  Future<void> _crearCeldas() async {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final celda =
            grilla[fila][columna]
              ..position = Vector2(position.x + columna * tamanioCelda + tamanioCelda, position.y + fila * tamanioCelda + tamanioCelda)
              ..size = Vector2.all(tamanioCelda);
        add(celda);
      }
    }
  }

  /// Genera etiquetas visuales (A–Z y 1–N) alrededor del tablero.
  void _agregarCoordenadasVisuales() {
    const letras = 'ABCDEFGHIJKL';

    for (int columna = 0; columna < columnas; columna++) {
      coordenadas.add(Coordenada(texto: letras[columna], posicion: Vector2(position.x + columna * tamanioCelda + tamanioCelda + tamanioCelda / 2, position.y)));
    }

    for (int fila = 0; fila < filas; fila++) {
      coordenadas.add(Coordenada(texto: '${fila + 1}', posicion: Vector2(position.x, position.y + fila * tamanioCelda + tamanioCelda + tamanioCelda / 2)));
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

  void liberarCeldas(List<Vector2> posiciones) {
    for (final pos in posiciones) {
      final celda = obtenerCelda(pos.y.toInt(), pos.x.toInt());
      if (celda != null) {
        celda.liberar();
      } else {}
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
    if (!esPosicionValida(gridPos, barco.longitud, esVertical)) {
      return;
    }

    final celdas = calcularCeldasOcupadas(gridPos, barco.longitud, esVertical);
    ocuparCeldas(celdas);

    // Calcula la posición centrada del barco
    barco.position = barco.calcularPosicionCentrada(gridPos);

    barcosEnTablero.add(barco);
    add(barco);
  }

  /// Actualiza posición y orientación de un barco, validando primero.
  bool actualizarBarco(Barco barco, Vector2 nuevaPos, bool nuevaOrientacionVertical, {required bool orientacionActualVertical}) {
    final nuevaGrid = worldToGrid(nuevaPos);

    if (!esPosicionValida(nuevaGrid, barco.longitud, nuevaOrientacionVertical)) {
      return false;
    }

    final celdasAntiguas = calcularCeldasOcupadas(worldToGrid(barco.posicionAnterior), barco.longitud, orientacionActualVertical);

    final celdasNuevas = calcularCeldasOcupadas(nuevaGrid, barco.longitud, nuevaOrientacionVertical);

    liberarCeldas(celdasAntiguas);

    ocuparCeldas(celdasNuevas);
    // Calcula la nueva posición basada en la longitud del barco
    if (barco.longitud == 1) {
      barco.position = gridToWorldCentro(nuevaGrid) - Vector2(barco.tamanioesCelda / 2, barco.tamanioesCelda / 2);
    } else {
      final base = gridToWorldEsquina(nuevaGrid, barco.longitud, barco.esVertical);
      final offsetX = nuevaOrientacionVertical ? 0.0 : ((barco.longitud - 1) / 2) * barco.tamanioesCelda;
      final offsetY = nuevaOrientacionVertical ? ((barco.longitud - 1) / 2) * barco.tamanioesCelda : 0.0;
      barco.position = base + Vector2(0, barco.tamanioesCelda) - Vector2(offsetX, offsetY);
    }

    barco.rotar(nuevaOrientacionVertical);

    return true;
  }

  /// Valida si una posición en la grilla está libre para colocar un barco.
  bool esPosicionValida(Vector2 gridPos, int longitud, bool esVertical) {
    final int startX = gridPos.x.floor();
    final int startY = gridPos.y.floor();

    if (sectorActivo != null && longitud != sectorActivo!.valor) {
      return false; // La longitud del barco debe coincidir con el valor del sector activo
    }

    for (int i = 0; i < longitud; i++) {
      final fila = esVertical ? startY + i : startY;
      final columna = esVertical ? startX : startX + i;

      final celda = obtenerCelda(fila, columna);
      if (celda == null || celda.tieneBarco) {
        return false;
      }
      // Comprobar si la celda actual pertenece al sector activo
      if (sectorActivo != null) {
        final worldPosCelda = gridToWorldCentro(Vector2(columna.toDouble(), fila.toDouble()));
        if (!sectorActivo!.contiene(worldPosCelda)) {
          return false; // Si alguna celda está fuera del sector activo, la posición no es válida
        }
      }
    }
    return true;
  }

  /// Resalta un área como válida o inválida para colocar un barco,
  /// teniendo en cuenta el sector activo.55
  void resaltarPosicion(Vector2 gridPos, int longitudBarco, bool esVertical, [List<Vector2> celdasPropias = const []]) {
    final celdas = <Vector2>[];
    for (int i = 0; i < longitudBarco; i++) {
      final x = gridPos.x + (esVertical ? 0 : i.toDouble());
      final y = gridPos.y + (esVertical ? i.toDouble() : 0);
      if (x >= columnas || y >= filas) {
        _resaltarComoRechazado(celdas);
        _oscurecerCeldasFueraDeSector(sectorActivo, celdas); // Oscurecer fuera del sector
        return;
      }
      final celda = obtenerCelda(y.toInt(), x.toInt());
      if (celda == null || (celda.tieneBarco && !celdasPropias.contains(Vector2(x, y)))) {
        _resaltarComoRechazado(celdas);
        _oscurecerCeldasFueraDeSector(sectorActivo, celdas); // Oscurecer fuera del sector
        return;
      }
      final worldPosCelda = gridToWorldCentro(Vector2(x, y));
      if (sectorActivo != null && !sectorActivo!.contiene(worldPosCelda)) {
        _resaltarComoRechazado(celdas);
        _oscurecerCeldasFueraDeSector(sectorActivo, celdas); // Oscurecer fuera del sector
        return;
      }
      celdas.add(Vector2(x, y));
    }
    _oscurecerCeldasFueraDeSector(sectorActivo, celdas); // Asegurar que el resto esté oscuro
  }

  /// Muestra las celdas como inválidas visualmente (color rojo, por ejemplo).
  void _resaltarComoRechazado(List<Vector2> celdasParciales) {
    for (final coord in celdasParciales) {
      obtenerCelda(coord.y.toInt(), coord.x.toInt())?.rechazar();
    }
  }

  /// Oscurece las celdas del tablero que no pertenecen al sector dado.
  void _oscurecerCeldasFueraDeSector(Sector? sector, List<Vector2> celdasEnSector) {
    if (sector == null) {
      // Si no hay sector activo, no oscurecer nada
      return;
    }
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        final celda = grilla[fila][columna];
        final worldPosCelda = celda.position + Vector2(tamanioCelda / 2, tamanioCelda / 2);
        final gridPosCelda = Vector2(columna.toDouble(), fila.toDouble());
        if (celda.estado == EstadoCelda.barco) {
          celda.estado = EstadoCelda.barco;
        } else if (!sector.contiene(worldPosCelda) && !celdasEnSector.contains(gridPosCelda)) {
          celda.estado = EstadoCelda.rechazada; // Puedes usar otro estado o modificar el color directamente
        } else if (!celdasEnSector.contains(gridPosCelda) && celda.estado == EstadoCelda.rechazada) {
          celda.estado = EstadoCelda.vacia; // Restaurar si ya no está fuera del sector y no es parte del barco
        }
      }
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
  // ⚓ MÉTODOS PRIVADOS - GESTIÓN INICIAL DE LOS BARCOS
  // ===========================================================================

  /// Inicializa y posiciona los barcos en su disposición inicial.
  Future<void> _inicializarBarcosIniciales() async {
    double xOffset = position.x * 3; // Desplazamiento horizontal inicial
    double yOffset = tamanioCelda; // Desplazamiento horizontal inicial

    // Itera sobre la configuración de cada barco inicial
    for (final datosBarco in datosBarcosIniciales) {
      final barco = _crearBarcoInicial(datosBarco);
      barco.position = Vector2(position.x + xOffset, position.y + yOffset + (filas * tamanioCelda) + (tamanioCelda * 4) + (areaBarcosIniciales.height - barco.size.y) / 3);
      barco.actualizarPosicionInicial(barco.position);
      contenedorBarcosIniciales.add(barco);
      xOffset += espacioEntreBarcos;
      yOffset += tamanioCelda;
    }
    // Ajusta el tamaño del contenedor para que abarque todos los barcos
    contenedorBarcosIniciales.size = Vector2(xOffset - espacioEntreBarcos, areaBarcosIniciales.height + yOffset);
  }

  /// Crea una instancia del `Barco` para la disposición inicial.
  Barco _crearBarcoInicial(Map<String, dynamic> datos) {
    final int longitud = datos['longitud'];
    final Map<String, String> rutasSprites = Map<String, String>.from(datos['sprites']);

    return Barco(
      longitud: longitud,
      rutasSprites: rutasSprites,
      tamanioesCelda: tamanioCelda,

      onDragStartCallback: (barcoArrastrado) {
        barcoArrastrado.estaSiendoArrastrado = true;
        barcoArrastrado.priority = 1;
        sectorActivo = sectores.firstWhere((sector) => sector.valor == longitud);
      },
      onDragEndCallback: (barcoArrastrado) async {
        barcoArrastrado.priority = 0;
        barcoArrastrado.estaSiendoArrastrado = false;
        resetearResaltado(); // Limpiar cualquier resaltado
        for (final fila in grilla) {
          for (final celda in fila) {
            if (!celda.tieneBarco) {
              celda.estado = EstadoCelda.vacia; // Restaurar el estado visual de las celdas
            }
          }
        }
      },
    );
  }
}

/// ---------------------------------------------------------------------------
/// EXTENSIONES: Conversión entre posiciones de mundo y de grilla.
/// ---------------------------------------------------------------------------
extension TableroEstrategiaUtils on TableroEstrategia {
  /// Convierte una posición absoluta del mundo a una celda de la grilla.
  Vector2 worldToGrid(Vector2 worldPos) {
    return Vector2(((worldPos.x - position.x - tamanioCelda) / tamanioCelda).round().toDouble(), ((worldPos.y - position.y - tamanioCelda) / tamanioCelda).round().toDouble());
  }

  /// Convierte coordenadas de grilla a la esquina superior izquierda de la celda.
  ///
  /// Si **esVertical** ??  False = horizontal : True = vertical
  Vector2 gridToWorldEsquina(Vector2 gridPos, int longitud, bool esVertical) {
    // Ajuste en el eje X y Y para barcos igual o más de dos celdas
    //Cada caso es el valor de la longitud
    double ajusteY = 0.0;
    double ajusteX = 0.0;
    if (!esVertical) {
      switch (longitud) {
        case 2:
          ajusteX = tamanioCelda / 2;
          ajusteY = -tamanioCelda;
          break;
        case 3:
          ajusteX = tamanioCelda;
          ajusteY = -tamanioCelda;
          break;
        case 4:
          ajusteX = tamanioCelda * 1.5;
          ajusteY = -tamanioCelda;
          break;
        case 5:
        default:
          ajusteX = tamanioCelda * 2;
          ajusteY = -tamanioCelda;
      }
      return Vector2(position.x + gridPos.x * tamanioCelda + tamanioCelda + ajusteX, position.y + gridPos.y * tamanioCelda + tamanioCelda + ajusteY);
    } else {
      switch (longitud) {
        case 2:
          ajusteY = -tamanioCelda / 2;
          break;
        case 3:
          ajusteY = 0;
          break;
        case 4:
          ajusteY = tamanioCelda / 2;
          break;
        case 5:
        default:
          ajusteY = tamanioCelda;
          break;
      }
      return Vector2(position.x + gridPos.x * tamanioCelda + tamanioCelda, position.y + gridPos.y * tamanioCelda + tamanioCelda + ajusteY);
    }
  }

  /// Convierte coordenadas de grilla al centro de la celda.
  Vector2 gridToWorldCentro(Vector2 gridPos) {
    return Vector2(position.x + gridPos.x * tamanioCelda + tamanioCelda + tamanioCelda / 2, position.y + gridPos.y * tamanioCelda + tamanioCelda + tamanioCelda / 2);
  }
}
