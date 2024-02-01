import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._internal();
  static DatabaseHelper get instance => _databaseHelper ??= DatabaseHelper._internal();
  Database? _db;
  Database get db => _db!;

  Future<void> init() async {
    _db = await openDatabase(
      'database_db',
      version: 4, // Incrementa la versión
      onCreate: (db, version) {
        db.execute('CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, apellido TEXT, correo TEXT, contrasena TEXT, imagenPerfil TEXT, imagenQR TEXT, cargo TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Agrega la columna 'apellido' a la tabla 'usuarios'
          await db.execute('ALTER TABLE usuarios ADD COLUMN apellido TEXT');
          await db.execute('ALTER TABLE usuarios ADD COLUMN correo TEXT');
          await db.execute('ALTER TABLE usuarios ADD COLUMN contrasena TEXT');
          await db.execute('ALTER TABLE usuarios ADD COLUMN imagenPerfil TEXT');
          await db.execute('ALTER TABLE usuarios ADD COLUMN imagenQR TEXT');
          await db.execute('ALTER TABLE usuarios ADD COLUMN cargo TEXT');
        }
      },
    );
  }
}
