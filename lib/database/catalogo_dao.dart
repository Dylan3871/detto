import 'package:sqflite/sqflite.dart';
import 'package:detto/models/catalogo_model.dart';
import 'package:detto/database/database_helper.dart';

class CatalogoDao {
  final Database _db;

  CatalogoDao(this._db);

  Future<void> initDatabase() async {
    final databaseHelper = DatabaseHelper.instance;
    await databaseHelper.init();  // Inicializa la base de datos
  }

  Future<List<CatalogoItem>> readAll() async {
    final data = await _db.query('catalogo');
    return data.map((e) => CatalogoItem.fromMap(e)).toList();
  }

  Future<int> insert(CatalogoItem item) async {
    // Obtener el último ID utilizado
    int lastId = Sqflite.firstIntValue(await _db.rawQuery('SELECT MAX(id) FROM catalogo')) ?? 0;

    // Incrementar el ID para el nuevo elemento
    int newId = lastId + 1;
    item = item.copyWith(id: newId);

    // Insertar el nuevo elemento en el catálogo
    return await _db.insert('catalogo', item.toMap());
  }

  Future<void> update(CatalogoItem item) async {
    await _db.update('catalogo', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(CatalogoItem item) async {
    await _db.delete('catalogo', where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> insertTalla(String nombre) async {
    int lastId = Sqflite.firstIntValue(await _db.rawQuery('SELECT MAX(id) FROM tallas')) ?? 0;

    int newId = lastId + 1;

    return await _db.insert('tallas', {'id': newId, 'nombre': nombre});
  }

  Future<int> insertMaterial(String nombre) async {
    int lastId = Sqflite.firstIntValue(await _db.rawQuery('SELECT MAX(id) FROM materiales')) ?? 0;

    int newId = lastId + 1;

    return await _db.insert('materiales', {'id': newId, 'nombre': nombre});
  }

  Future<int> insertGenero(String nombre) async {
    int lastId = Sqflite.firstIntValue(await _db.rawQuery('SELECT MAX(id) FROM generos')) ?? 0;

    int newId = lastId + 1;

    return await _db.insert('generos', {'id': newId, 'nombre': nombre});
  }

  Future<int> insertCampo(String nombre) async {
    int lastId = Sqflite.firstIntValue(await _db.rawQuery('SELECT MAX(id) FROM campos')) ?? 0;

    int newId = lastId + 1;

    return await _db.insert('campos', {'id': newId, 'nombre': nombre});
  }
}
