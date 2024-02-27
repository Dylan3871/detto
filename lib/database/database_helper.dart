import 'package:detto/models/catalogo_model.dart';
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
      version: 6, // Incrementa la versión
      onCreate: (db, version) {
        db.execute('CREATE TABLE usuarios(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, apellido TEXT, correo TEXT, contrasena TEXT, imagenPerfil TEXT, imagenQR TEXT, cargo TEXT)');
        db.execute('CREATE TABLE catalogo(id INTEGER PRIMARY KEY AUTOINCREMENT, nombrePrenda TEXT, fotos TEXT, tallas TEXT, material TEXT, colores TEXT, video TEXT, genero TEXT, campo TEXT, descripcion TEXT)');
        db.execute('CREATE TABLE categorias(id INTEGER PRIMARY KEY AUTOINCREMENT, nombre TEXT)'); // Aquí se crea la tabla 'categorias'
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 6) {
          // Agrega la tabla 'catalogo' si estás actualizando desde la versión anterior
          db.execute('CREATE TABLE catalogo(id INTEGER PRIMARY KEY AUTOINCREMENT, nombrePrenda TEXT, fotos TEXT, tallas TEXT, material TEXT, colores TEXT, video TEXT, genero TEXT, campo TEXT, descripcion TEXT)');
        }
      },
    );
  }

  void insertProduct(CatalogoItem newProduct) {}
}
