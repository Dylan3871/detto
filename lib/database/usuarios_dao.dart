import 'package:sqflite/sqflite.dart';
import 'package:detto/models/usuarios_model.dart';
import 'package:detto/database/database_helper.dart';

class UsuariosDao {
  final database = DatabaseHelper.instance.db;

  Future<List<UsuariosModel>> readAll() async {
    final data = await database.query('usuarios');
    return data.map((e) => UsuariosModel.fromMap(e)).toList();
  }

  Future<int> insert(UsuariosModel usuario) async {
    int lastId = Sqflite.firstIntValue(await database.rawQuery('SELECT MAX(id) FROM usuarios')) ?? 0;
    int newId = lastId + 1;
    usuario = usuario.copyWith(id: newId);
    return await database.insert('usuarios', usuario.toMap());
  }

  Future<void> update(UsuariosModel usuario) async {
    await database.update('usuarios', usuario.toMap(), where: 'id = ?', whereArgs: [usuario.id]);
  }

  Future<void> delete(UsuariosModel usuario) async {
    await database.delete('usuarios', where: 'id = ?', whereArgs: [usuario.id]);
  }

  Future<UsuariosModel?> authenticateUser(String correo, String contrasena) async {
    final List<Map<String, dynamic>> result = await database.query('usuarios',
        where: 'correo = ? AND contrasena = ?', whereArgs: [correo, contrasena]);

    if (result.isNotEmpty) {
      return UsuariosModel.fromMap(result.first);
    } else {
      return null;
    }
  }
}
