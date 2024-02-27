// ignore_for_file: prefer_const_constructors, file_names, deprecated_member_use

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:detto/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class UsuariosModel {
  final int id;
  final String name;
  final String apellido;
  final String correo;
  final String contrasena;
  final String imagenPerfil;
  final String imagenQR;
  final String cargo;

  UsuariosModel({
    this.id = -1,
    required this.name,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.imagenPerfil,
    required this.imagenQR,
    required this.cargo,
  });

  UsuariosModel copyWith({
    int? id,
    String? name,
    String? apellido,
    String? correo,
    String? contrasena,
    String? imagenPerfil,
    String? imagenQR,
    String? cargo,
  }) {
    return UsuariosModel(
      id: id ?? this.id,
      name: name ?? this.name,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      imagenQR: imagenQR ?? this.imagenQR,
      cargo: cargo ?? this.cargo,
    );
  }

  factory UsuariosModel.fromMap(Map<String, dynamic> map) {
    return UsuariosModel(
      id: map['id'],
      name: map['name'] ?? '',
      apellido: map['apellido'] ?? '',
      correo: map['correo'] ?? '',
      contrasena: map['contrasena'] ?? '',
      imagenPerfil: map['imagenPerfil'] ?? '',
      imagenQR: map['imagenQR'] ?? '',
      cargo: map['cargo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'imagenPerfil': imagenPerfil,
      'imagenQR': imagenQR,
      'cargo': cargo,
    };
  }
}

class UsuariosDao {
  final database = DatabaseHelper.instance.db;

  Future<List<UsuariosModel>> readAll() async {
    final data = await database.query('usuarios');
    return data.map((e) => UsuariosModel.fromMap(e)).toList();
  }

  Future<int> insert(UsuariosModel usuarios) async {
    int lastId =
        Sqflite.firstIntValue(await database.rawQuery('SELECT MAX(id) FROM usuarios')) ?? 0;

    int newId = lastId + 1;
    usuarios = usuarios.copyWith(id: newId);

    return await database.insert('usuarios', usuarios.toMap());
  }

  Future<void> update(UsuariosModel usuarios) async {
    await database.update('usuarios', usuarios.toMap(), where: 'id = ?', whereArgs: [usuarios.id]);
  }

  Future<void> delete(UsuariosModel usuarios) async {
    await database.delete('usuarios', where: 'id = ?', whereArgs: [usuarios.id]);
  }
}

class Paginausuarios extends StatefulWidget {
  const Paginausuarios({Key? key}) : super(key: key);

  @override
  State<Paginausuarios> createState() => _PaginaUsuariosState();
}

class _PaginaUsuariosState extends State<Paginausuarios> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  File? _imagenPerfil;
  File? _imagenQR;
  String _selectedCargo = "vendedor";

  List<UsuariosModel> usuarios = [];
  final dao = UsuariosDao();

  @override
  void initState() {
    super.initState();
    dao.readAll().then((value) {
      setState(() {
        usuarios = value;
      });
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
          title: Text('Usuarios'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  _mostrarFormulario(context);
                },
                child: const Text('Crear Usuario'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    return _buildUsuarioCard(usuarios[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsuarioCard(UsuariosModel usuario) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          _mostrarEditarFormulario(context, usuario);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${usuario.name} ${usuario.apellido}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Correo: ${usuario.correo}'),
              SizedBox(height: 8),
              Text('Cargo: ${usuario.cargo}'),
              SizedBox(height: 8),
              if (usuario.imagenPerfil.isNotEmpty)
                Image.file(
                  File(usuario.imagenPerfil),
                  height: 100,
                ),
              SizedBox(height: 8),
              if (usuario.imagenQR.isNotEmpty)
                Image.file(
                  File(usuario.imagenQR),
                  height: 50,
                ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await dao.delete(usuario);
                        setState(() {
                          usuarios.remove(usuario);
                        });
                      },
                      child: Text('Eliminar'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         _mostrarEditarFormulario(context, usuario);
                      },
                      child: Text('Editar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Crear Usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _apellidoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido de usuario',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un apellido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un correo';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una contraseña';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCargo,
                  items: ["vendedor", "administrador"].map((String cargo) {
                    return DropdownMenuItem<String>(
                      value: cargo,
                      child: Text(cargo),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCargo = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Cargo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un cargo';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: _seleccionarImagenPerfil,
                  child: Text('Seleccionar Imagen de Perfil'),
                ),
                if (_imagenPerfil != null) Image.file(_imagenPerfil!, height: 100),
                ElevatedButton(
                  onPressed: _seleccionarImagenQR,
                  child: Text('Seleccionar Imagen de QR'),
                ),
                if (_imagenQR != null) Image.file(_imagenQR!, height: 100),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = _nombreController.text;
                  final apellido = _apellidoController.text;
                  final correo = _correoController.text;
                  final contrasena = _contrasenaController.text;
                  final cargo = _selectedCargo;

                  UsuariosModel usuario = UsuariosModel(
                    name: name,
                    apellido: apellido,
                    correo: correo,
                    contrasena: contrasena,
                    imagenPerfil: _imagenPerfil?.path ?? "",
                    imagenQR: _imagenQR?.path ?? "",
                    cargo: cargo,
                  );

                  _guardarUsuario(usuario);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarEditarFormulario(BuildContext context, UsuariosModel usuario) {
    _nombreController.text = usuario.name;
    _apellidoController.text = usuario.apellido;
    _correoController.text = usuario.correo;
    _contrasenaController.text = usuario.contrasena;
    _selectedCargo = usuario.cargo;
    _imagenPerfil = usuario.imagenPerfil.isNotEmpty ? File(usuario.imagenPerfil) : null;
    _imagenQR = usuario.imagenQR.isNotEmpty ? File(usuario.imagenQR) : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _apellidoController,
                  decoration: InputDecoration(
                    labelText: 'Apellido de usuario',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un apellido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _correoController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese un correo';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese una contraseña';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCargo,
                  items: ["vendedor", "administrador"].map((String cargo) {
                    return DropdownMenuItem<String>(
                      value: cargo,
                      child: Text(cargo),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCargo = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Cargo',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, seleccione un cargo';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: _seleccionarImagenPerfil,
                  child: Text('Seleccionar Imagen de Perfil'),
                ),
                if (_imagenPerfil != null) Image.file(_imagenPerfil!, height: 100),
                ElevatedButton(
                  onPressed: _seleccionarImagenQR,
                  child: Text('Seleccionar Imagen de QR'),
                ),
                if (_imagenQR != null) Image.file(_imagenQR!, height: 100),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final name = _nombreController.text;
                  final apellido = _apellidoController.text;
                  final correo = _correoController.text;
                  final contrasena = _contrasenaController.text;
                  final cargo = _selectedCargo;

                  UsuariosModel usuarioActualizado = usuario.copyWith(
                    name: name,
                    apellido: apellido,
                    correo: correo,
                    contrasena: contrasena,
                    imagenPerfil: _imagenPerfil?.path ?? "",
                    imagenQR: _imagenQR?.path ?? "",
                    cargo: cargo,
                  );

                  _actualizarUsuario(usuarioActualizado);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  void _seleccionarImagenPerfil() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenPerfil = File(pickedFile.path);
      });
    }
  }

  void _seleccionarImagenQR() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenQR = File(pickedFile.path);
      });
    }
  }

  void _guardarUsuario(UsuariosModel usuario) async {
    await dao.insert(usuario);
    dao.readAll().then((value) {
      setState(() {
        usuarios = value;
      });
    });
  }

  void _actualizarUsuario(UsuariosModel usuario) async {
    await dao.update(usuario);
    dao.readAll().then((value) {
      setState(() {
        usuarios = value;
      });
    });
  }
}

