import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para un campo desplegable con almacenamiento en Firebase.
class DesplegableTiempo extends StatelessWidget {
  final String titulo;
  final Icon icon;
  final List<String> opciones;
  final Function(String?)? onChanged;
  final Function()? onClear;
  final String? valorSeleccionado;
  final String partidaId;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Constructor del `DesplegableTiempo`
  ///
  /// - `titulo`: Etiqueta del campo desplegable.
  /// - `icon`: Ícono que acompaña el título.
  /// - `opciones`: Lista de opciones disponibles en el desplegable.
  /// - `partidaId`: ID de la partida actual en Firebase.
  /// - `onChanged`: Callback cuando se selecciona una opción.
  /// - `onClear`: Callback cuando se borra la selección.
  /// - `valorSeleccionado`: Opción preseleccionada.
  DesplegableTiempo({
    super.key,
    required this.titulo,
    required this.icon,
    required this.opciones,
    required this.partidaId,
    this.onChanged,
    this.onClear,
    this.valorSeleccionado,
  });

  /// Guarda la selección en Firebase para la partida específica.
  Future<void> _guardarSeleccion(String? seleccion) async {
    if (partidaId.isNotEmpty) {
      await _dbRef
          .child('Five Force Competence/PARTIDAS/$partidaId/CONFIGURACIONES/TIEMPO TURNO')
          .set(seleccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        130,
                        130,
                        130,
                      ).withAlpha((0.6 * 255).toInt()),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: valorSeleccionado,
                    dropdownColor: Colors.white,
                    hint: Text(
                      'Seleccione ${titulo.toLowerCase()}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    items:
                        opciones.map((String opcion) {
                          return DropdownMenuItem<String>(
                            value: opcion,
                            child: Text(
                              opcion,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (onChanged != null) {
                        onChanged!(newValue);
                      }
                      _guardarSeleccion(newValue);
                    },
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: -30,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (valorSeleccionado != null)
                Positioned(
                  right: 30,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: () {
                        if (onClear != null) {
                          onClear!();
                        }
                        _guardarSeleccion(null);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
