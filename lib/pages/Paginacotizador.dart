import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:detto/models/favorito_model.dart';
import 'package:detto/database/favorito_dao.dart';
import 'package:detto/database/database_helper.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart'; // Para formatear fechas
import 'package:image_picker/image_picker.dart';

class SelectedProduct {
  final Favorito product;
  String? clientName;
  double costoini;
  int pieces;
  String comment;
  double discount;
  double margin; // Nuevo campo para el margen de ganancia
  String finalComment;
  String codigod; // Nuevo campo para almacenar el código del producto

  SelectedProduct({
    required this.product,
    this.clientName,
    this.costoini = 0,
    this.pieces = 0,
    this.comment = '',
    this.discount = 0,
    this.margin = 0, // Inicializar el margen de ganancia en 0
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
  double _discount = 0.0; // Descuento general
  String? _clientName; // Variable para almacenar el nombre del cliente

  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;

  List<double> _margins = List.generate(20, (index) => (index + 1) * 5.0); // Genera valores de margen del 5% al 100%
  List<File> _capturedImages = []; // Lista para almacenar las imágenes capturadas

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
      _productsFuture =
          Future.value(favoriteProducts as FutureOr<List<Favorito>>?);
      _databaseInitialized = true;

      // Insertar productos automáticamente en la lista seleccionada
      selectedProducts.addAll(favoriteProducts.map((product) =>
          SelectedProduct(
            product: product,
            costoini: product.costoini.toDouble(),
            codigod: product.codigod,
          )));

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
    double total = selectedProducts.fold(
        0, (total, product) => total + _calculateTotal(product));
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
          pdfLib.Header(level: 0, text: 'Cotización'),
          pdfLib.Paragraph(
            text:
                'Fecha de emisión: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          ),
          if (_selectedDate != null)
            pdfLib.Paragraph(
              text:
                  'Fecha de vigencia: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
            ),
          if (_clientName != null)
            pdfLib.Paragraph(
              text: 'Nombre del cliente: $_clientName',
            ),
          pdfLib.SizedBox(height: 20), // Agregar espacio entre los elementos

          // Agregar tabla con detalles de la cotización y las fotos de los productos
          pdfLib.Table.fromTextArray(
            border: pdfLib.TableBorder.all(),
            headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
            cellAlignment: pdfLib.Alignment.center,
            data: <List<dynamic>>[
              [
                'Código',
                'Nombre Prenda',
                'Foto Prenda',
                'Costo Ini',
                'Piezas',
                'Margen de Ganancia',
                 'Descuento',
                'Comentario',
                'Total'
              ],
              ...selectedProducts.map((product) => [
                product.product.nombrePrenda,
                // Incluir la imagen del producto
                pdfLib.Container(
                  width: 100, // Ancho de la imagen
                  height: 100, // Alto de la imagen
                  child: pdfLib.Image(
                    pdfLib.MemoryImage(
                      File(product.product.fotos).readAsBytesSync(),
                    ),
                  ),
                ),
                product.codigod,
                product.costoini.toString(),
                product.pieces.toString(),
                product.comment,
                '${product.discount}%',
                '${product.margin}%',
                _calculateTotal(product).toStringAsFixed(2),
              ]),
            ],
          ),

          pdfLib.SizedBox(height: 20),

          pdfLib.Table.fromTextArray(
            border: pdfLib.TableBorder.all(),
            headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
            cellAlignment: pdfLib.Alignment.center,
            data: <List<String>>[
              ['Subtotal:', _totalPrice.toStringAsFixed(2)],
              ['Descuento General:', (_totalPrice * (_discount / 100)).toStringAsFixed(2)],
              ['IVA:', (_totalPrice * 0.16).toStringAsFixed(2)],
              ['Total General:', (_totalPrice * (1 - (_discount / 100)) * 1.16).toStringAsFixed(2)],
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
    totalPrice =
        totalPrice / (1 - (product.margin / 100)); // Calcular el precio usando el margen de ganancia
    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    if (!_databaseInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Cotizador'),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _currentDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selectedDate != null && selectedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = selectedDate;
                        });
                      }
                    },
                    child: Text(
                      'Vigencia: ${_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : "Seleccionar fecha"}',
                      style: TextStyle(color: Color.fromARGB(255, 108, 107, 107)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(_currentDate)),
            TextButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _currentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null && selectedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                }
              },
              child: Text(
                'Vigencia: ${_selectedDate != null ? DateFormat('dd/MM/yyyy').format(_selectedDate!) : "Seleccionar fecha"}',
                style: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
              ),
            ),
          ],
        ),
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
                        TextFormField(
                          onChanged: (value) {
                            _clientName = value.isNotEmpty ? value : null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Nombre del Cliente',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        //aqui ajustamos la tabla como se muestra en al app
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          //aqui se mueve para añadir columnas tablas o modificar logica de la tabla que se muestra en la app
                     child: DataTable(
  columns: [
    DataColumn(label: Text('Código')), 
    DataColumn(label: Text('Nombre Prenda')),
    DataColumn(label: Text('Foto Prenda')),
    DataColumn(label: Text('Costo')),
    DataColumn(label: Text('Piezas')),
    DataColumn(label: Text('Margen de Ganancia')), 
    DataColumn(label: Text('Descuento')),
    DataColumn(label: Text('Comentario')),
    DataColumn(label: Text('Total')),
    DataColumn(label: Text('Eliminar')),
  ],
  rows: List<DataRow>.generate(selectedProducts.length, (index) {
    final product = selectedProducts[index];
    return DataRow(cells: [
      DataCell(
        Text(product.codigod),
      ),
      DataCell(
        Text(product.product.nombrePrenda),
      ),
      DataCell(
        SizedBox(
          width: 100, // Ancho de la imagen
          height: 100, // Alto de la imagen
          child: Image.file(File(product.product.fotos)),
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  product.costoini = (product.costoini - 1).clamp(0, double.infinity);
                  _calculateTotalPrice();
                });
              },
            ),
            SizedBox(
              width: 70,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    product.costoini = double.tryParse(value) ?? 0.0;
                    _calculateTotalPrice();
                  });
                },
                controller: TextEditingController(text: product.costoini.toStringAsFixed(2)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  product.costoini += 1;
                  _calculateTotalPrice();
                });
              },
            ),
          ],
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  product.pieces = (product.pieces - 1).clamp(0, double.infinity).toInt();
                  _calculateTotalPrice();
                });
              },
            ),
            SizedBox(
              width: 70,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    product.pieces = int.tryParse(value) ?? 0;
                    _calculateTotalPrice();
                  });
                },
                controller: TextEditingController(text: product.pieces.toString()),
                keyboardType: TextInputType.number,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  product.pieces += 1;
                  _calculateTotalPrice();
                });
              },
            ),
          ],
        ),
      ),
      DataCell(
        DropdownButton<double>(
          value: product.margin == 0.0 ? _margins.first : product.margin,
          onChanged: (newValue) {
            setState(() {
              product.margin = newValue!;
              _calculateTotalPrice();
            });
          },
          items: _margins.map((margin) {
            return DropdownMenuItem<double>(
              value: margin,
              child: Text('$margin%'),
            );
          }).toList(),
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  product.discount = (product.discount - 1).clamp(0, double.infinity);
                  _calculateTotalPrice();
                });
              },
            ),
            SizedBox(
              width: 70,
              child: TextFormField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    product.discount = double.tryParse(value) ?? 0.0;
                    _calculateTotalPrice();
                  });
                },
                controller: TextEditingController(text: product.discount.toStringAsFixed(2)),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  product.discount += 1;
                  _calculateTotalPrice();
                });
              },
            ),
          ],
        ),
      ),
      DataCell(
        TextFormField(
          onChanged: (value) {
            setState(() {
              product.comment = value;
            });
          },
          controller: TextEditingController(text: product.comment),
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
                        //aqui termina donde se modifca la logica y orden de tabla 

                        
                        Text('Total: ${_totalPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                  SizedBox(height: 20),
                  TextFormField(
                    onChanged: (value) {
                      _discount = double.tryParse(value) ?? 0.0;
                      setState(() {});
                    },
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Descuento General (%)',
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final imagePicker = ImagePicker();
                      final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() {
                          _capturedImages.add(File(image.path));
                        });
                        // Aquí puedes guardar la imagen y realizar cualquier otra tarea necesaria
                        print('Imagen guardada en: ${image.path}');
                      }
                    },
                    child: Text('Tomar Fotos y Guardar'),
                  ),
                  SizedBox(height: 20),
                  // Visualizar las imágenes tomadas
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _capturedImages
                          .map((image) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              image,
                              width: 150,
                              height: 150,
                            ),
                          ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Aquí puedes agregar la tabla para mostrar el subtotal, descuento general, IVA y total
                  Table(
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Text('Subtotal:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TableCell(
                            child: Text('\$${_totalPrice.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text('Descuento General:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TableCell(
                            child: Text('\$${(_totalPrice * (_discount / 100)).toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text('IVA:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TableCell(
                            child: Text('\$${(_totalPrice * 0.16).toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          TableCell(
                            child: Text('\$${(_totalPrice * (1 - (_discount / 100)) * 1.16).toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _generatePDF();
        },
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
