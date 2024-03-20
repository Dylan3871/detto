import 'package:sqflite/sqflite.dart';
import 'package:detto/models/preguntas_model.dart';
import 'package:detto/database/database_helper.dart' as dbHelper;

class PreguntasDao {
  final dbHelper.DatabaseHelper _databaseHelper;

  PreguntasDao(this._databaseHelper);

  Future<void> insertPregunta(Pregunta pregunta) async {
    try {
      final db = await _databaseHelper.db;
      await db.insert(
        'preguntas',
        pregunta.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error al insertar la pregunta: $e');
      throw Exception('Error al insertar la pregunta: $e');
    }
  }

  Future<List<Pregunta>> getAllPreguntas() async {
    try {
      final db = await _databaseHelper.db;
      final List<Map<String, dynamic>> maps = await db.query('preguntas');
      return List.generate(maps.length, (i) {
        return Pregunta.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error al obtener las preguntas: $e');
      throw Exception('Error al obtener las preguntas: $e');
    }
  }

 Future<void> deletePregunta(Pregunta pregunta) async {
  try {
    final db = await _databaseHelper.db;
    await db.delete(
      'preguntas',
      where: 'id = ?',
      whereArgs: [pregunta.id],
    );
  } catch (e) {
    print('Error al eliminar la pregunta: $e');
    throw Exception('Error al eliminar la pregunta: $e');
  }
}
}
