import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:detto/database/database_helper.dart';

class CatalogoDao {
  final database = DatabaseHelper.instance.db;

  Future<void> createTable() async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS catalogo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombrePrenda TEXT,
        fotos TEXT,
        tallas TEXT,
        material TEXT,
        colores TEXT,
        video TEXT,
        genero TEXT,
        campo TEXT,
        descripcion TEXT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> producto) async {
    int lastId = Sqflite.firstIntValue(await database.rawQuery('SELECT MAX(id) FROM catalogo')) ?? 0;

    int newId = lastId + 1;
    producto['id'] = newId;

    return await database.insert('catalogo', producto);
  }

  Future<void> update(Map<String, dynamic> producto) async {
    await database.update('catalogo', producto, where: 'id = ?', whereArgs: [producto['id']]);
  }

  Future<void> delete(int productId) async {
    await database.delete('catalogo', where: 'id = ?', whereArgs: [productId]);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await database.query('catalogo');
  }

  Future<List<String>> getAllColores() async {
    final List<Map<String, dynamic>> productos = await database.query('catalogo');
    final Set<String> coloresSet = Set<String>();

    for (final producto in productos) {
      final String colores = producto['colores'];
      if (colores.isNotEmpty) {
        final List<String> coloresList = colores.split(',');
        coloresSet.addAll(coloresList);
      }
    }

    return coloresSet.toList();
  }

  Future<int> insertColor(String nombre) async {
    bool tableExists = await database
        .rawQuery("SELECT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'colores')")
        .then((value) => Sqflite.firstIntValue(value) == 1);

    if (!tableExists) {
      return 0;
    }

    int lastId = Sqflite.firstIntValue(await database.rawQuery('SELECT MAX(id) FROM colores')) ?? 0;

    int newId = lastId + 1;

    return await database.insert('colores', {'id': newId, 'nombre': nombre});
  }

  Future<List<String>> getAllTallas() async {
    final List<Map<String, dynamic>> productos = await database.query('catalogo');
    final Set<String> tallasSet = Set<String>();

    for (final producto in productos) {
      final String tallas = producto['tallas'];
      if (tallas.isNotEmpty) {
        final List<String> tallasList = tallas.split(',');
        tallasSet.addAll(tallasList);
      }
    }

    return tallasSet.toList();
  }

  Future<List<String>> getAllMateriales() async {
    final List<Map<String, dynamic>> productos = await database.query('catalogo');
    final Set<String> materialesSet = Set<String>();

    for (final producto in productos) {
      final String material = producto['material'];
      if (material.isNotEmpty) {
        materialesSet.add(material);
      }
    }

    return materialesSet.toList();
  }


Future<List<String>> getAllGenero() async {
  final List<Map<String, dynamic>> productos = await database.query('catalogo');
  final Set<String> generoSet = Set<String>();

  for (final producto in productos) {
    final String? genero = producto['genero'];
    if (genero != null && genero.isNotEmpty) {
      generoSet.add(genero);
    }
  }

  // Convertir el conjunto de géneros a una lista y ordenarla alfabéticamente
  List<String> generos = generoSet.toList();
  generos.sort();
  
  return generos;
}



  Future<List<String>> getAllCampo() async {
    final List<Map<String, dynamic>> productos = await database.query('catalogo');
    final Set<String> campoSet = Set<String>();

    for (final producto in productos) {
      final String campo = producto['campo'];
      if (campo.isNotEmpty) {
        campoSet.add(campo);
      }
    }

    return campoSet.toList();
  }
}

class Paginaregistro extends StatefulWidget {
  const Paginaregistro({Key? key}) : super(key: key);

  @override
  State<Paginaregistro> createState() => _PaginaRegistroState();
}

class _PaginaRegistroState extends State<Paginaregistro> {
  final _formKey = GlobalKey<FormState>();
  final _nombrePrendaController = TextEditingController();
  final _tallasController = TextEditingController();
  final _materialController = TextEditingController();
  final _coloresController = TextEditingController();
  final _generoController = TextEditingController();
  final _campoController = TextEditingController();
  final _descripcionController = TextEditingController();

  List<XFile>? _imagenesProducto = [];
  XFile? _videoFile;
  final dao = CatalogoDao();

  VideoPlayerController? _videoController;
  bool _mostrarFormularioRegistro = false;

  List<String> tallasDisponibles = [];
  List<String> materialesDisponibles = [];
  List<String> generoDisponible = [];
  List<String> campoDisponible = [];
  List<String> coloresDisponibles = [];

  @override
  void initState() {
    super.initState();
    _fetchColores();
    _fetchTallas();
    _fetchMateriales();
    _fetchGenero();
    _fetchCampo();
  }

  Future<void> _fetchColores() async {
    List<String> colores = await dao.getAllColores();
    setState(() {
      coloresDisponibles = colores;
    });
  }

  Future<void> _fetchTallas() async {
    List<String> tallas = await dao.getAllTallas();
    setState(() {
      tallasDisponibles = tallas;
    });
  }

  Future<void> _fetchMateriales() async {
    List<String> materiales = await dao.getAllMateriales();
    setState(() {
      materialesDisponibles = materiales;
    });
  }

  Future<void> _fetchGenero() async {
    List<String> genero = await dao.getAllGenero();
    setState(() {
      generoDisponible = genero;
    });
  }

  Future<void> _fetchCampo() async {
    List<String> campo = await dao.getAllCampo();
    setState(() {
      campoDisponible = campo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.redAccent,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.redAccent,
            onPrimary: Colors.white,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Registro'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _mostrarFormularioRegistro = !_mostrarFormularioRegistro;
                      });
                    },
                    child: Text('Registrar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _mostrarAgregarElementos();
                    },
                    child: Text('Agregar'),
                  ),
                  if (_mostrarFormularioRegistro)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nombrePrendaController,
                            decoration: InputDecoration(
                              labelText: 'Nombre de la prenda',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese un nombre de prenda';
                              }
                              return null;
                            },
                          ),
                          _buildDropdownButtonFormField(
                            label: 'Tallas',
                            items: tallasDisponibles,
                            controller: _tallasController,
                          ),
                          _buildDropdownButtonFormField(
                            label: 'Material',
                            items: materialesDisponibles,
                            controller: _materialController,
                          ),
                          _buildDropdownButtonFormField(
                            label: 'Colores',
                            items: coloresDisponibles,
                            controller: _coloresController,
                          ),
                          _buildDropdownButtonFormField(
                            label: 'Género',
                            items: generoDisponible,
                            controller: _generoController,
                          ),
                          _buildDropdownButtonFormField(
                            label: 'Campo',
                            items: campoDisponible,
                            controller: _campoController,
                          ),
                          TextFormField(
                            controller: _descripcionController,
                            decoration: InputDecoration(
                              labelText: 'Descripción',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese una descripción';
                              }
                              return null;
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _seleccionarImagenesProducto();
                            },
                            child: Text('Seleccionar Imágenes del Producto'),
                          ),
                          if (_imagenesProducto != null && _imagenesProducto!.isNotEmpty)
                            Column(
                              children: [
                                Text('Imágenes seleccionadas:'),
                                SizedBox(height: 8),
                                Row(
                                  children: _imagenesProducto!.map((imagen) {
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Image.file(File(imagen.path), height: 50),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ElevatedButton(
                            onPressed: () {
                              _seleccionarVideoProducto();
                            },
                            child: Text('Seleccionar Video del Producto'),
                          ),
                          if (_videoController != null)
                            Column(
                              children: [
                                Text('Video seleccionado:'),
                                SizedBox(height: 8),
                                AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ],
                            ),
                          ElevatedButton(
                            onPressed: _guardarProducto,
                            child: Text('Guardar Producto'),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: dao.getAllProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final productos = snapshot.data;
                        return Column(
                          children: productos!.map((producto) {
                            return ListTile(
                              title: Text(producto['nombrePrenda']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _mostrarFormularioRegistro = true; // Mostrar el formulario de registro
                                      _nombrePrendaController.text = producto['nombrePrenda']; // Rellenar los campos del formulario con los datos del producto seleccionado
                                      _tallasController.text = producto['tallas'];
                                      _materialController.text = producto['material'];
                                      _coloresController.text = producto['colores'];
                                      _generoController.text = producto['genero'];
                                      _campoController.text = producto['campo'];
                                      _descripcionController.text = producto['descripcion'];
                                      // No olvides configurar el controlador de video si el producto tiene un video asociado
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      dao.delete(producto['id']);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButtonFormField({
    required String label,
    required List<String> items,
    required TextEditingController controller,
  }) {
    return DropdownButtonFormField<String>(
      value: null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          controller.text = newValue!;
        });
      },
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, seleccione un $label';
        }
        return null;
      },
    );
  }

  void _mostrarAgregarElementos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Elementos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAgregarElementoButton('Talla', tallasDisponibles),
              _buildAgregarElementoButton('Material', materialesDisponibles),
              _buildAgregarElementoButton('Color', coloresDisponibles),
              _buildAgregarElementoButton('Género', generoDisponible),
              _buildAgregarElementoButton('Campo', campoDisponible),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgregarElementoButton(String label, List<String> lista) {
    TextEditingController _textFieldController = TextEditingController();
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _mostrarDialogoAgregarElemento(label, _textFieldController);
          },
          child: Text('Agregar $label'),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  void _mostrarDialogoAgregarElemento(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nuevo $label'),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Agregar'),
              onPressed: () async {
                String nuevoElemento = controller.text;
                if (nuevoElemento.isNotEmpty) {
                  switch (label) {
                    case 'Talla':
                      setState(() {
                        tallasDisponibles.add(nuevoElemento);
                      });
                      break;
                    case 'Material':
                      setState(() {
                        materialesDisponibles.add(nuevoElemento);
                      });
                      break;
                    case 'Color':
                      setState(() {
                        coloresDisponibles.add(nuevoElemento);
                      });
                      await dao.insertColor(nuevoElemento);
                      break;
                    case 'Género':
                      setState(() {
                        generoDisponible.add(nuevoElemento);
                      });
                      break;
                    case 'Campo':
                      setState(() {
                        campoDisponible.add(nuevoElemento);
                      });
                      break;
                    default:
                      break;
                  }
                  controller.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _seleccionarImagenesProducto() async {
    List<XFile>? result = await ImagePicker().pickMultiImage();
    setState(() {
      _imagenesProducto = result;
    });
  }

  Future<void> _seleccionarVideoProducto() async {
    final picker = ImagePicker();
    XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _videoFile = video;
        _videoController = VideoPlayerController.file(File(_videoFile!.path))
          ..initialize().then((_) {
            setState(() {});
          });
      });
    }
  }

  void _guardarProducto() {
    if (_formKey.currentState!.validate() && _imagenesProducto!.isNotEmpty && _videoFile != null) {
      final nombrePrenda = _nombrePrendaController.text;
      final tallas = _tallasController.text;
      final material = _materialController.text;
      final colores = _coloresController.text;
      final genero = _generoController.text;
      final campo = _campoController.text;
      final descripcion = _descripcionController.text;

      Map<String, dynamic> producto = {
        'nombrePrenda': nombrePrenda,
        'tallas': tallas,
        'material': material,
        'colores': colores,
        'genero': genero,
        'campo': campo,
        'descripcion': descripcion,
        'fotos': _imagenesProducto!.map((imagen) => imagen.path).join(','),
        'video': _videoFile!.path,
      };

      _guardarProductoEnBaseDeDatos(producto);
    }
  }

  void _guardarProductoEnBaseDeDatos(Map<String, dynamic> producto) async {
    await dao.insert(producto);

    setState(() {
      _mostrarFormularioRegistro = false;
    });
  }
}

