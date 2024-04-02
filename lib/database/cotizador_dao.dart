import 'package:detto/models/cotizador_model.dart'; // Asegúrate de importar el modelo correcto
import 'package:sqflite/sqflite.dart';

class CotizadorDAO {
  final Database _db;

  CotizadorDAO(this._db);

  Future<int> insertCotizacion(CotizadorItem cotizacion) async {
    return await _db.insert('cotizador', cotizacion.toMap());
  }

  Future<List<CotizadorItem>> getAllCotizaciones() async {
    final List<Map<String, dynamic>> cotizaciones = await _db.query('cotizador');
    return List.generate(cotizaciones.length, (i) {
      return CotizadorItem.fromMap(cotizaciones[i]);
    });
  }

  Future<CotizadorItem?> getCotizacionById(int id) async {
    final List<Map<String, dynamic>> cotizaciones = await _db.query('cotizador', where: 'id = ?', whereArgs: [id]);
    if (cotizaciones.isEmpty) {
      return null;
    }
    return CotizadorItem.fromMap(cotizaciones.first);
  }

  Future<int> updateCotizacion(CotizadorItem cotizacion) async {
    return await _db.update('cotizador', cotizacion.toMap(), where: 'id = ?', whereArgs: [cotizacion.id]);
  }

  Future<int> deleteCotizacion(int id) async {
    return await _db.delete('cotizador', where: 'id = ?', whereArgs: [id]);
  }
}
