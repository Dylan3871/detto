import 'package:detto/pages/Paginacotizador.dart';
import 'package:sqflite/sqflite.dart';
import 'package:detto/models/favorito_model.dart';

class FavoritoDao {
  final Database _db;

  FavoritoDao(this._db);

  Future<void> insert(Map<String, dynamic> row) async {
    await _db.insert('favorito', row);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return await _db.query('favorito');
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    List<Map<String, dynamic>> results =
        await _db.query('favorito', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> update(Map<String, dynamic> row) async {
    await _db.update('favorito', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<void> delete(int id) async {
    await _db.delete('favorito', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addToFavorites(Favorito favorito) async {
    // Convierte el objeto Favorito a un mapa para insertarlo en la base de datos
    Map<String, dynamic> row = favorito.toMap();
    await insert(row);
  }

  Future<bool?> isFavorite(int productId) async {
    List<Map<String, dynamic>> results = await _db.query('favorito', where: 'id = ?', whereArgs: [productId]);
    if (results.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<void> removeFromFavorites(int productId) async {
    await _db.delete('favorito', where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> initDatabase() async {
    try {
      await _db.execute('''
        CREATE TABLE IF NOT EXISTS favorito(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fotos TEXT,
          nombrePrenda TEXT,
          costoini INTEGER,
          codigod TEXT
        )
      ''');
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  Future<List<Favorito>> getAllFavoriteProducts() async {
    try {
      List<Map<String, dynamic>> favoriteProductMaps =
          await _db.query('favorito');

      // Convierte los mapas de productos favoritos a objetos Favorito
      List<Favorito> favoriteProducts = favoriteProductMaps
          .map((map) => Favorito(
                id: map['id'],
                fotos: map['fotos'],
                nombrePrenda: map['nombrePrenda'],
                costoini: map['costoini'],
                codigod: map['codigod'],
              ))
          .toList();

      return favoriteProducts;
    } catch (e) {
      print('Error al obtener productos favoritos: $e');
      return []; // Retorna una lista vacía en caso de error
    }
  }

  Future<void> deleteFavoriteProduct(int id) async {
    try {
      await _db.delete('favorito', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting favorite product from database: $e');
      rethrow; // Relanza la excepción para manejo externo
    }
  }

  insertFavoriteProduct(SelectedProduct selectedProduct) {}
}
