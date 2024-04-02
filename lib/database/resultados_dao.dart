import 'package:sqflite/sqflite.dart';
import 'package:detto/models/resultados_model.dart';
import 'package:detto/database/database_helper.dart' as dbHelper;

class ResultadosDao {
  final dbHelper.DatabaseHelper _databaseHelper;

  ResultadosDao(this._databaseHelper);

  Future<void> insertResultado(Resultado resultado) async {
    try {
      final db = await _databaseHelper.db;
      await db.insert(
        'resultados',
        resultado.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error al insertar el resultado: $e');
      throw Exception('Error al insertar el resultado: $e');
    }
  }

  Future<List<Resultado>> getAllResultados() async {
    try {
      final db = await _databaseHelper.db;
      final List<Map<String, dynamic>> maps = await db.query('resultados');
      if (maps.isNotEmpty) {
        return List.generate(maps.length, (i) {
          return Resultado.fromMap(maps[i]);
        });
      } else {
        return []; // Devuelve una lista vacía si la consulta no devuelve resultados
      }
    } catch (e) {
      print('Error al obtener los resultados: $e');
      throw Exception('Error al obtener los resultados: $e');
    }
  }

  Future<void> eliminarResultado(Resultado resultado) async {
    try {
      final db = await _databaseHelper.db;
      await db.delete(
        'resultados',
        where: 'id = ?',
        whereArgs: [resultado.id],
      );
    } catch (e) {
      print('Error al eliminar el resultado: $e');
      throw Exception('Error al eliminar el resultado: $e');
    }
  }

  Future<void> deleteResultado(Resultado resultado) async {
    try {
      final db = await _databaseHelper.db;
      await db.delete(
        'resultados',
        where: 'id = ?',
        whereArgs: [resultado.id],
      );
    } catch (e) {
      print('Error al eliminar el resultado: $e');
      throw Exception('Error al eliminar el resultado: $e');
    }
  }
}
