import 'package:detto/models/catalogo_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._internal();
  static DatabaseHelper get instance =>
      _databaseHelper ??= DatabaseHelper._internal();
  late Database _db;
  Database get db => _db;

  Future<void> init() async {
    _db = await openDatabase(
      'database_db',
      version: 17, // Incrementa la versión si es necesario
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            apellido TEXT,
            correo TEXT,
            contrasena TEXT,
            imagenPerfil TEXT,
            imagenQR TEXT,
            cargo TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE catalogo(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombrePrenda TEXT,
            fotos TEXT,
            tallas TEXT,
            material TEXT,
            colores TEXT,
            video TEXT,
            genero TEXT,
            campo TEXT,
            descripcion TEXT,
            costoini INTEGER,
            codigod TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE categorias(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE favorito(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fotos TEXT,
            nombrePrenda TEXT,
            costoini INTEGER,
            codigod TEXT
          )
        ''');

        db.execute('''
          CREATE TABLE cotizador(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fechaaut TEXT,
            fechavig TEXT,
            nombreCliente TEXT,
            nombrePrenda TEXT,
            fotos TEXT,
            margenPre REAL,
            costo REAL,
            piezas INTEGER,
            comentario TEXT,
            descuentoP REAL,
            totalP REAL,
            comentarioF TEXT,
            fotosF TEXT,
            subtotal REAL,
            descuentoG REAL,
            iva REAL,
            totalF REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 18) {
          // Agrega la columna 'codigod' a la tabla 'catalogo' si estás actualizando desde la versión anterior
          db.execute('ALTER TABLE catalogo ADD COLUMN codigod TEXT');
        }
      },
    );
  }

  void insertProduct(CatalogoItem newProduct) {}

  initDatabase() {}
}
