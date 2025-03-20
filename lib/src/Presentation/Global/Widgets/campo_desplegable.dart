import 'package:flutter/material.dart';

class CampoDesplegable extends StatelessWidget {
  final String titulo;
  final Icon icon;
  final List<Map<String, dynamic>> opciones;
  final Function(Map<String, dynamic>)? onChanged;
  final Function()? onClear;
  final Map<String, dynamic>? valorSeleccionado;

  const CampoDesplegable({
    super.key,
    required this.titulo,
    required this.icon,
    required this.opciones,
    this.onChanged,
    this.onClear,
    this.valorSeleccionado,
  });

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
                  child: DropdownButton<Map<String, dynamic>>(
                    isExpanded: true,
                    value: valorSeleccionado,
                    dropdownColor: Colors.white,
                    hint: Text(
                      'Seleccione ${titulo.toLowerCase()}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    items:
                        opciones.map((Map<String, dynamic> opcion) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: opcion,
                            child: Text(
                              opcion['nombre'] ?? '',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      if (onChanged != null && newValue != null) {
                        onChanged!(newValue);
                      }
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
                      Icon(Icons.widgets, color: Colors.blue.shade400),
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
                      onPressed: onClear,
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
