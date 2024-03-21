import 'package:sqflite/sqflite.dart';
import 'package:detto/models/catalogo_model.dart';
import 'package:detto/models/resultados_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._internal();
  static DatabaseHelper get instance =>
      _databaseHelper ??= DatabaseHelper._internal();
  late Database _db;
  Database get db => _db;

  Future<void> init() async {
    try {
      _db = await openDatabase(
        'database_db',
        version: 33,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
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

    await db.execute('''
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

    await db.execute('''
      CREATE TABLE categorias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE favorito(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fotos TEXT,
        nombrePrenda TEXT,
        costoini INTEGER,
        codigod TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cotizador(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa TEXT,
        contacto TEXT,
        correo TEXT,
        telefono TEXT,
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
        totalF REAL,
        concdicioncom TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE resultados(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        pregunta TEXT,
        respuesta TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE preguntas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pregunta TEXT,
        opciones TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 34) {
     
      // Agregar la lógica de actualización de la base de datos aquí
    }
  }

  void insertProduct(CatalogoItem newProduct) {}

  Future<void> initDatabase() async {
    await init();
  }

  Future<void> insertResultado(String nombre, String pregunta, String respuesta) async {
    try {
      final db = await _databaseHelper!.db;
      await db.insert(
        'resultados',
        {'nombre': nombre, 'pregunta': pregunta, 'respuesta': respuesta},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error al insertar el resultado: $e');
      throw Exception('Error al insertar el resultado: $e');
    }
  }

  Future<List<Resultado>> getAllResultados() async {
    try {
      final db = await _databaseHelper!.db;
      final List<Map<String, dynamic>> maps = await db.query('resultados');
      return List.generate(maps.length, (i) {
        return Resultado(
          id: maps[i]['id'],
          nombre: maps[i]['nombre'],
          pregunta: maps[i]['pregunta'],
          respuesta: maps[i]['respuesta'],
        );
      });
    } catch (e) {
      print('Error al obtener los resultados: $e');
      throw Exception('Error al obtener los resultados: $e');
    }
  }

  void queryAllRows(String s) {}

  deleteResultado(Resultado resultado) {}

  deleteResultadosPorNombre(String nombre) {}

  // Elimina este método, ya que no se está utilizando
  // void getAllResultados() {}
}
