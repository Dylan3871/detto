import 'package:sqflite/sqflite.dart';
import 'database_helper.dart'; // Asegúrate de importar tu clase DatabaseHelper aquí

class CategoriasDao {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertCategoria(String nombre) async {
    final db = await dbHelper.db;
    return await db.insert(
      'categorias',
      {'nombre': nombre},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCategorias() async {
    final db = await dbHelper.db;
    return await db.query('categorias');
  }

  Future<int> updateCategoria(int id, String nombre) async {
    final db = await dbHelper.db;
    return await db.update(
      'categorias',
      {'nombre': nombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategoria(int id) async {
    final db = await dbHelper.db;
    return await db.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
