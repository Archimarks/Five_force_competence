import 'package:firebase_database/firebase_database.dart';

/// Clase encargada de traer todos los sectores desde Firebase Realtime Database.
class TraerTodosSectores {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  TraerTodosSectores() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para obtener todos los sectores desde Firebase.
  Future<Map<String, dynamic>?> obtenerSectores() async {
    final DatabaseReference sectoresRef = _dbRef.child(
      'Five Force Competence/DATOS PERSISTENTES/SECTORES',
    );

    try {
      DataSnapshot snapshot = await sectoresRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        print('No se encontraron sectores en la base de datos.');
        return null;
      }
    } catch (e) {
      print('Error al obtener los sectores: $e');
      return null;
    }
  }
}
