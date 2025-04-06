import 'package:flutter/material.dart';

AppBar customAppBar({
  required BuildContext context,
  required String title,
  List<Widget>? actions,
  bool showLeading = true,
  VoidCallback? onLeadingPressed,
  Color? backgroundColor, // Agregado
}) {
  return AppBar(
    leading:
        showLeading
            ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
            )
            : const SizedBox(width: 56.0),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
    ),
    centerTitle: true,
    backgroundColor: backgroundColor ?? Colors.transparent, // Aplica si se pasa
    flexibleSpace:
        backgroundColor == null
            ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF405A63), Color(0xFF52727D)],
                ),
              ),
            )
            : null, // No usa gradiente si hay color personalizado
    actions: actions,
    elevation: 0,
  );
}
