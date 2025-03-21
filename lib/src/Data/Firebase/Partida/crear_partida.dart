import 'package:firebase_database/firebase_database.dart';

/// Clase encargada de la creación de partidas en Firebase Realtime Database.
class CrearPartida {
  final DatabaseReference _dbRef;

  /// Constructor que inicializa la referencia a Firebase Realtime Database.
  CrearPartida() : _dbRef = FirebaseDatabase.instance.ref();

  /// Método para crear una nueva partida asegurando un identificador único.
  Future<void> crearNuevaPartida() async {
    final DatabaseReference partidasRef = _dbRef.child('Five Force Competence/PARTIDAS');

    for (int i = 1; i <= 10; i++) {
      String partidaId = 'PARTIDA $i';
      DatabaseReference partidaRef = partidasRef.child(partidaId);

      DataSnapshot snapshot = await partidaRef.get();
      if (!snapshot.exists) {
        await partidaRef.set(_crearPlantillaPartida());
        print('Partida creada con éxito: $partidaId');
        return;
      }
    }

    print('No se pudo crear la partida. Todos los slots están ocupados.');
  }

  /// Retorna la estructura base de una partida basada en la plantilla.
  Map<String, dynamic> _crearPlantillaPartida() {
    return {
      'TURNO': '',
      'CONFIGURACIONES': {
        'SECTOR': '',
        'ESTADO': 'ACTIVO',
        'TIEMPO TURNO': 60,
        'CANTIDAD COMODINES': 2,
      },
      'EQUIPOS': {},
    };
  }
}
