//Importaciones de paquetes: Importa los paquetes necesarios para el funcionamiento de la aplicación.
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

//Clase SelectedProduct: Define la clase SelectedProduct que representa un producto seleccionado para la cotización.
class SelectedProduct {
  final Favorito product;
  String? clientName;
  String? empresa; // Nuevo campo empresa
  String? contacto; // Nuevo campo contacto
  String? correo; // Nuevo campo correo
  String? telefono; // Nuevo campo telefono
  String condicioncom;
  double costoini;
  int pieces;
  String comment;
  double discount;
  double margin;
  String finalComment;
  String codigod;


  SelectedProduct({
    required this.product,
    this.clientName,
    this.empresa, // Agregar empresa al constructor
    this.contacto, // Agregar contacto al constructor
    this.correo, // Agregar correo al constructor
    this.telefono, // Agregar telefono al constructor
    this.costoini = 0,
    this.pieces = 0,
    this.comment = '',
    this.discount = 0,
    this.margin = 0,
    this.finalComment = '',
    this.condicioncom = '',
    required this.codigod,
  });
}

//Clase Paginacotizador: Define la clase Paginacotizador que es un StatefulWidget y representa la página principal de la aplicación.
class Paginacotizador extends StatefulWidget {
  @override
  _PaginacotizadorState createState() => _PaginacotizadorState();
}

//Estado de la clase Paginacotizador (_PaginacotizadorState): Define el estado de la clase Paginacotizador.
class _PaginacotizadorState extends State<Paginacotizador> {
  late FavoritoDao _favoritoDao;
  late Future<List<Favorito>> _productsFuture;
  List<SelectedProduct> selectedProducts = [];
  bool _databaseInitialized = false;
  double _totalPrice = 0.0;
  double _discount = 0.0;
  String? _clientName;
  String? _empresa; // Nuevas variables para empresa, contacto, correo y teléfono
  String? _contacto;
  String? _correo;
  String? _telefono;
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  List<double> _margins = List.generate(20, (index) => (index + 1) * 5.0);
  List<File> _capturedImages = [];
  String? _finalComment;
  String? _condicioncom;

//Método initState(): Este método se llama automáticamente cuando el estado del widget está inicializado.
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }


//Método _initializeDatabase(): Inicializa la base de datos y carga los productos favoritos.
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

//Métodos para manejar el carrito de compras: _addToCart y _removeFromCart para agregar y eliminar productos del carrito, respectivamente.
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
//Métodos para calcular el precio total y generar el PDF: _calculateTotalPrice, _generatePDF, _calculateTotal.
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
   // Método para mostrar el cuadro de diálogo de condiciones
  // Método para mostrar el cuadro de diálogo de condiciones
void _showConditionsDialog(BuildContext context) {
  String conditionsText = _condicioncom ?? '''CONDICIONES COMERCIALES:
1. TIEMPO DE ENTREGA: DE 3 A 4 SEMANAS, DESPUÉS DE RECIBIR ANTICIPO, TALLAS COMPLETAS Y AUTORIZACIÓN DE MUESTRAS
2. FORMA DE PAGO: 60% ANTICIPO, 40% A LA ENTREGA
3. SE ACEPTAN TARJETAS DE CRÉDITO CON UN INCREMENTO DEL 3.5% POR COMISIÓN BANCARIA.
4. TODOS NUESTROS PRECIOS GENERAN EL 16% DEL I.V.A..
5. INCLUYE SERVICIO ADICIONAL DE TOMA DE TALLAS Y ENTREGA PERSONALIZADA
6. ES POSIBLE QUE EXISTA DIFERENCIA DE TONOS ENTRE LOTES QUE NO PODAMOS CONTROLAR
7. NO HAY CAMBIOS NI DEVOLUCIONES, SI NO SE REALIZÓ LA TOMA DE TALLAS
8. ESTOS PRECIOS ESTÁN SUJETOS A CAMBIO ANTES DE LA CONFIRMACIÓN POR ESCRITO DEL PEDIDO
9. ESTOS PRECIOS SON HASTA LA TALLA XL 42 (PLAYERAS, BATAS, SUDADERAS, CAMISAS) Y TALLA 36 EN PANTALONES, EN TALLAS SUPERIORES SE INCREMENTA EL PRECIO
10. EL FLETE NO ESTÁ INCLUIDO'''; // Usar el valor actual de _condicioncom

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Condiciones'),
        content: TextFormField(
          maxLines: null, // Permite múltiples líneas
          initialValue: conditionsText, // Usar el valor actual
          onChanged: (value) {
            setState(() {
              conditionsText = value; // Actualizar conditionsText al escribir
            });
          },
          decoration: InputDecoration(
            hintText: 'Ingrese las condiciones aquí...',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _condicioncom = conditionsText; // Actualizar _condicioncom con el nuevo valor
              });
              Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            },
            child: Text('Guardar'),
          ),
        ],
      );
    },
  );
}


 
// Método para generar el PDF del cliente
void _generateClientPDF() async {
  final pdf = pdfLib.Document();

  pdf.addPage(
    pdfLib.MultiPage(
      build: (context) => [
        pdfLib.Header(level: 0, text: 'Cotización para el Cliente'),
        pdfLib.Paragraph(
          text: 'Fecha de emisión: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        ),
        if (_selectedDate != null)
          pdfLib.Paragraph(
            text: 'Fecha de vigencia: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
          ),
        if (_clientName != null)
          pdfLib.Paragraph(
            text: 'Nombre del cliente: $_clientName',
          ),
        if (_empresa != null)
          pdfLib.Paragraph(
            text: 'Nombre de la empresa: $_empresa',
          ),
        if (_contacto != null)
          pdfLib.Paragraph(
            text: 'Contacto: $_contacto',
          ),
        if (_correo != null)
          pdfLib.Paragraph(
            text: 'Correo: $_correo',
          ),
        if (_telefono != null)
          pdfLib.Paragraph(
            text: 'Teléfono: $_telefono',
          ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Tabla con detalles de la cotización y las fotos de los productos
        pdfLib.Table.fromTextArray(
          border: pdfLib.TableBorder.all(),
          headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
          cellAlignment: pdfLib.Alignment.center,
          data: <List<dynamic>>[
            [
              'Código',
              'Nombre Prenda',
              'Foto Prenda',
              'Costo',
              'Piezas',
              'Total',
            ],
            ...selectedProducts.map((product) => [
              product.product.codigod,
              product.product.nombrePrenda,
              pdfLib.Container(
                width: 100,
                height: 100,
                child: pdfLib.Image(
                  pdfLib.MemoryImage(
                    File(product.product.fotos).readAsBytesSync(),
                  ),
                ),
              ),
              product.costoini,
              product.pieces,
              _calculateTotal(product),
            ]),
          ],
        ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Tabla con subtotal, iva y total
        pdfLib.Table.fromTextArray(
          border: pdfLib.TableBorder.all(),
          headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
          cellAlignment: pdfLib.Alignment.center,
          data: <List<String>>[
            ['Subtotal:', _totalPrice.toStringAsFixed(2)],
            ['IVA:', (_totalPrice * 0.16).toStringAsFixed(2)],
            ['Total:', (_totalPrice * 1.16).toStringAsFixed(2)],
          ],
        ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Condiciones comerciales
        pdfLib.Paragraph(
          text: 'Condiciones:',
        ),
        pdfLib.Paragraph(
          text: _condicioncom ?? 'No hay condiciones especificadas.',
        ),
      ],
    ),
  );

  // Guardar el PDF del cliente
  final directory = await getExternalStorageDirectory();
  final clientPDFFile = File('${directory!.path}/cotizacion_cliente_${_empresa ?? 'cliente'}.pdf');
  await clientPDFFile.writeAsBytes(await pdf.save());
  print('PDF del cliente generado exitosamente en: ${clientPDFFile.path}');
}

// Método para generar el PDF del usuario
// Método para generar el PDF del usuario
void _generateUserPDF() async {
  final pdf = pdfLib.Document();

  pdf.addPage(
    pdfLib.MultiPage(
      build: (context) => [
        pdfLib.Header(level: 0, text: 'Cotización para el Usuario'),
        pdfLib.Paragraph(
          text: 'Fecha de emisión: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        ),
        if (_selectedDate != null)
          pdfLib.Paragraph(
            text: 'Fecha de vigencia: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
          ),
        if (_clientName != null)
          pdfLib.Paragraph(
            text: 'Nombre del cliente: $_clientName',
          ),
        if (_empresa != null)
          pdfLib.Paragraph(
            text: 'Nombre de la empresa: $_empresa',
          ),
        if (_contacto != null)
          pdfLib.Paragraph(
            text: 'Contacto: $_contacto',
          ),
        if (_correo != null)
          pdfLib.Paragraph(
            text: 'Correo: $_correo',
          ),
        if (_telefono != null)
          pdfLib.Paragraph(
            text: 'Teléfono: $_telefono',
          ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Detalles de la cotización con fotos de productos y comentarios finales
        pdfLib.Table.fromTextArray(
          border: pdfLib.TableBorder.all(),
          headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
          cellAlignment: pdfLib.Alignment.center,
          data: <List<dynamic>>[
            [
              'Código',
              'Nombre Prenda',
              'Foto Prenda',
              'Costo',
              'Piezas',
              'Comentario',
              'Descuento',
              'Total',
            ],
            ...selectedProducts.map((product) => [
              product.product.codigod,
              product.product.nombrePrenda,
              pdfLib.Container(
                width: 100,
                height: 100,
                child: pdfLib.Image(
                  pdfLib.MemoryImage(
                    File(product.product.fotos).readAsBytesSync(),
                  ),
                ),
              ),
              product.costoini,
              product.pieces,
              product.comment, // Comentario
              product.discount, // Descuento
              _calculateTotal(product).toStringAsFixed(2), // Limitar a dos decimales
            ]),
          ],
        ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Tabla con subtotal, descuento general, IVA y total
        pdfLib.Table.fromTextArray(
          border: pdfLib.TableBorder.all(),
          headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
          cellAlignment: pdfLib.Alignment.center,
          data: <List<String>>[
            ['Subtotal:', _totalPrice.toStringAsFixed(2)],
            ['Descuento General:', _discount.toStringAsFixed(2)],
            ['IVA:', (_totalPrice * 0.16).toStringAsFixed(2)],
            ['Total:', (_totalPrice * 1.16).toStringAsFixed(2)],
          ],
        ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Comentarios finales
        pdfLib.Paragraph(
          text: 'Comentarios finales:',
        ),
        pdfLib.Paragraph(
          text: _finalComment ?? 'No hay comentarios finales.',
        ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Incluir fotos tomadas
        pdfLib.Paragraph(
          text: 'Fotos tomadas:',
        ),
        for (var imageFile in _capturedImages)
          pdfLib.Container(
            width: 100,
            height: 100,
            child: pdfLib.Image(
              pdfLib.MemoryImage(
                File(imageFile.path).readAsBytesSync(),
              ),
            ),
          ),
        pdfLib.SizedBox(height: 20), // Espacio entre los elementos
        // Condiciones
        pdfLib.Paragraph(
          text: 'Condiciones:',
        ),
        pdfLib.Paragraph(
          text: 'Incluir aquí las condiciones de la cotización para el usuario.',
        ),
      ],
    ),
  );

  // Guardar el PDF
  final directory = await getExternalStorageDirectory();
  final userPDFFile = File('${directory!.path}/cotizacion_usuario_${_empresa ?? 'usuario'}.pdf');
  await userPDFFile.writeAsBytes(await pdf.save());
}







  double _calculateTotal(SelectedProduct product) {
    double totalPrice = product.costoini * product.pieces;
    totalPrice -= totalPrice * (product.discount / 100);
    totalPrice =
        totalPrice / (1 - (product.margin / 100)); // Calcular el precio usando el margen de ganancia
    return totalPrice;
  }


//Método build(): Construye la interfaz de usuario de la página.
  @override
Widget build(BuildContext context) {
  //Manejo de la inicialización de la base de datos en el widget build(): Muestra un indicador de carga si la base de datos no se ha inicializado.
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
                     TextFormField(
  onChanged: (value) {
    setState(() {
      _empresa = value; // Asignar el valor ingresado a la variable _empresa
    });
  },
  decoration: InputDecoration(
    labelText: 'Empresa',
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),

TextFormField(
  onChanged: (value) {
    setState(() {
      _contacto = value; // Asignar el valor ingresado a la variable _contacto
    });
  },
  decoration: InputDecoration(
    labelText: 'Contacto',
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),

TextFormField(
  onChanged: (value) {
    setState(() {
      _correo = value; // Asignar el valor ingresado a la variable _correo
    });
  },
  decoration: InputDecoration(
    labelText: 'Correo',
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),

TextFormField(
  onChanged: (value) {
    setState(() {
      _telefono = value; // Asignar el valor ingresado a la variable _telefono
    });
  },
  decoration: InputDecoration(
    labelText: 'Teléfono',
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),

                        //aqui ajustamos la tabla como se muestra en al app
                       SingleChildScrollView(
  scrollDirection: Axis.horizontal,
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
    textAlign: TextAlign.start, // Alinear el texto hacia la derecha
    //textDirection: TextDirection.ltr, // Establecer la dirección del texto de izquierda a derecha
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
                  TextFormField(
  onChanged: (value) {
    setState(() {
      _finalComment = value; // Asignar el valor ingresado a la variable _commentarioFinal
    });
  },
  decoration: InputDecoration(
    labelText: 'Comentario final',
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),
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
                  ElevatedButton(
  onPressed: () {
    _showConditionsDialog(context); // Llama al método para mostrar el cuadro de diálogo
  },
  child: Text('Condiciones'),
),

                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _generateClientPDF();
          _generateUserPDF();
        },
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }
}
