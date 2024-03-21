import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotizaciones App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Paginacotizaciones(),
    );
  }
}

class Paginacotizaciones extends StatefulWidget {
  @override
  _PaginacotizacionesState createState() => _PaginacotizacionesState();
}

class _PaginacotizacionesState extends State<Paginacotizaciones> {
  late Database _database;
  late List<Map<String, dynamic>> _cotizaciones = [];

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'cotizaciones_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
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
        ''',
        );
      },
      version: 1,
    );

    await _loadCotizaciones();
  }

  Future<void> _loadCotizaciones() async {
    final List<Map<String, dynamic>> cotizaciones =
        await _database.query('cotizador');
    setState(() {
      _cotizaciones = cotizaciones;
    });
  }

  Future<void> _deleteCotizacion(int id) async {
    await _database.delete(
      'cotizador',
      where: 'id = ?',
      whereArgs: [id],
    );
    _loadCotizaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizaciones'),
      ),
      body: _cotizaciones.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cotizaciones.length,
              itemBuilder: (context, index) {
                final cotizacion = _cotizaciones[index];
                return ListTile(
                  title: Text(cotizacion['nombreCliente']),
                  subtitle: Text(cotizacion['nombrePrenda']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteCotizacion(cotizacion['id']);
                    },
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}
