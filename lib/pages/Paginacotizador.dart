import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:detto/models/favorito_model.dart';
import 'package:detto/database/favorito_dao.dart';
import 'package:detto/database/database_helper.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class SelectedProduct {
  final Favorito product;
  String? clientName;
  double costoini;
  int pieces;
  String comment;
  double discount;
  String finalComment;
  String codigod; // Nuevo campo para almacenar el código del producto

  SelectedProduct({
    required this.product,
    this.clientName,
    this.costoini = 0,
    this.pieces = 0,
    this.comment = '',
    this.discount = 0,
    this.finalComment = '',
    required this.codigod, // Añadir el código del producto al constructor
  });
}

class Paginacotizador extends StatefulWidget {
  @override
  _PaginacotizadorState createState() => _PaginacotizadorState();
}

class _PaginacotizadorState extends State<Paginacotizador> {
  late FavoritoDao _favoritoDao;
  late Future<List<Favorito>> _productsFuture;
  List<SelectedProduct> selectedProducts = [];
  bool _databaseInitialized = false;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final databaseHelper = DatabaseHelper.instance;
      await databaseHelper.initDatabase();
      _favoritoDao = FavoritoDao(databaseHelper.db);
      final favoriteProducts = await _favoritoDao.getAllFavoriteProducts();
      _productsFuture = Future.value(favoriteProducts as FutureOr<List<Favorito>>?);
      _databaseInitialized = true;

      // Insertar productos automáticamente en la lista seleccionada
      selectedProducts.addAll(favoriteProducts.map((product) =>
          SelectedProduct(
            product: product,
            costoini: product.costoini.toDouble(),
            codigod: product.codigod,
          )
      ));

      _calculateTotalPrice(); // Recalcular el precio total
    } catch (e) {
      print('Error initializing database: $e');
    }
    setState(() {});
  }

  void _addToCart(Favorito product) {
    setState(() {
      // Al agregar un producto al carrito, incluir el código del producto
      selectedProducts.add(SelectedProduct(
        product: product,
        costoini: product.costoini.toDouble(),
        codigod: product.codigod, // Agregar el código del producto
      ));
    });
  }

  Future<void> _removeFromCart(SelectedProduct selectedProduct) async {
    try {
      // Eliminar el producto de la base de datos
      await _favoritoDao.deleteFavoriteProduct(selectedProduct.product.id!);
    } catch (e) {
      print('Error deleting product from database: $e');
      return;
    }

    setState(() {
      // Eliminar el producto de la lista
      selectedProducts.remove(selectedProduct);
      // Recalcular el precio total después de eliminar el producto
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    double total = selectedProducts.fold(0, (total, product) => total + _calculateTotal(product));
    setState(() {
      _totalPrice = total;
    });
  }

  Future<pdfLib.Font> _loadCustomFont() async {
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    return pdfLib.Font.ttf(fontData.buffer.asByteData());
  }

  void _generatePDF() async {
    _calculateTotalPrice();
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.MultiPage(
        build: (context) => [
          pdfLib.Table.fromTextArray(
            data: <List<String>>[
              <String>[
                'Nombre Cliente',
                'Nombre Prenda',
                'Foto Prenda',
                'Código', // Nueva columna para mostrar el código del producto
                'Costo Ini',
                'Piezas',
                'Comentario',
                'Descuento',
                'Total',
                'Eliminar',
              ],
              ...selectedProducts.map((product) => [
                product.clientName ?? '',
                product.product.nombrePrenda,
                product.product.fotos,
                product.codigod, // Mostrar el código del producto en la tabla
                product.costoini.toString(),
                product.pieces.toString(),
                product.comment,
                product.discount.toString(),
                _calculateTotal(product).toString(),
              ]),
              ['', '', '', '', '', '', '', '', _totalPrice.toStringAsFixed(2), ''],
            ],
          ),
        ],
      ),
    );

    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/cotizador.pdf');
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      print('PDF generado exitosamente en: ${file.path}');
    } catch (e, stackTrace) {
      print('Error al generar el PDF: $e\n$stackTrace');
    }
  }

  double _calculateTotal(SelectedProduct product) {
    double totalPrice = product.costoini * product.pieces;
    totalPrice -= totalPrice * (product.discount / 100);
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    if (!_databaseInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cotizador'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotizador'),
      ),
      body: FutureBuilder<List<Favorito>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (selectedProducts.isNotEmpty)
                    Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('Nombre Cliente')),
                              DataColumn(label: Text('Nombre Prenda')),
                              DataColumn(label: Text('Foto Prenda')),
                              DataColumn(label: Text('Código')), // Nueva columna para el código
                              DataColumn(label: Text('Costo Ini')),
                              DataColumn(label: Text('Piezas')),
                              DataColumn(label: Text('Comentario')),
                              DataColumn(label: Text('Descuento')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Eliminar')),
                            ],
                            rows: List<DataRow>.generate(selectedProducts.length, (index) {
                              final product = selectedProducts[index];
                              return DataRow(cells: [
                                DataCell(
                                  TextField(
                                    onChanged: (value) {
                                      product.clientName = value.isNotEmpty ? value : null;
                                    },
                                    controller: TextEditingController(text: product.clientName ?? ''),
                                  ),
                                ),
                                DataCell(
                                  Text(product.product.nombrePrenda),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100, // Ajusta el ancho de la imagen según sea necesario
                                    height: 100, // Ajusta el alto de la imagen según sea necesario
                                    child: Image.file(File(product.product.fotos)),
                                  ),
                                ),
                                DataCell(
                                  Text(product.codigod), // Mostrar el código del producto
                                ),
                                DataCell(
                                  TextField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        product.costoini = double.parse(value);
                                      } else {
                                        product.costoini = 0.0;
                                      }
                                      _calculateTotalPrice();
                                    },
                                    controller: TextEditingController(text: product.costoini == 0.0 ? '' : product.costoini.toStringAsFixed(2)),
                                  ),
                                ),
                                DataCell(
                                  TextField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        product.pieces = int.parse(value);
                                      } else {
                                        product.pieces = 0;
                                      }
                                      _calculateTotalPrice();
                                    },
                                    controller: TextEditingController(text: product.pieces == 0 ? '' : product.pieces.toString()),
                                  ),
                                ),
                                DataCell(
                                  TextField(
                                    onChanged: (value) {
                                      product.comment = value.isNotEmpty ? value : '';
                                    },
                                    controller: TextEditingController(text: product.comment),
                                  ),
                                ),
                                DataCell(
                                  TextField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        product.discount = double.parse(value);
                                      } else {
                                        product.discount = 0.0;
                                      }
                                      _calculateTotalPrice();
                                    },
                                    controller: TextEditingController(text: product.discount == 0.0 ? '' : product.discount.toString()),
                                  ),
                                ),
                                DataCell(
                                  Text(_calculateTotal(product).toStringAsFixed(2)),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await _removeFromCart(product);
                                    },
                                  ),
                                ),
                              ]);
                            }),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _generatePDF();
                          },
                          child: Text('Generar PDF'),
                        ),
                        Text('Total: ${_totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
