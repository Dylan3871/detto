import 'package:flutter/material.dart';
import 'package:detto/models/preguntas_model.dart';
import 'package:detto/database/preguntas_dao.dart';
import 'package:detto/database/database_helper.dart' as dbHelper;

class Paginapreguntas extends StatefulWidget {
  @override
  _PaginaPreguntasState createState() => _PaginaPreguntasState();
}

class _PaginaPreguntasState extends State<Paginapreguntas> {
  final _preguntaController = TextEditingController();
  final _opcionController = TextEditingController();
  final _nombreController = TextEditingController();
  List<String> _opciones = ['Opción 1'];
  bool _opcionMultiple = false;
  bool _mostrarCreacion = false;
  late PreguntasDao _preguntasDao;
  List<Pregunta> _preguntas = [];

  @override
  void initState() {
    super.initState();
    _preguntasDao = PreguntasDao(dbHelper.DatabaseHelper.instance);
    _cargarPreguntas();
  }

  void _cargarPreguntas() async {
    try {
      final preguntas = await _preguntasDao.getAllPreguntas();
      setState(() {
        _preguntas = preguntas;
      });
    } catch (e) {
      print('Error al cargar las preguntas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(
              hintText: 'Escribe tu nombre aquí',
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mostrarCreacion = !_mostrarCreacion;
              });
            },
            child: Text('Crear Pregunta'),
          ),
          if (_mostrarCreacion) _buildCreacionPregunta(),
          SizedBox(height: 20),
          _buildContestarPreguntas(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _enviarRespuestas,
            child: Text('Enviar Respuestas'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreacionPregunta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _preguntaController,
          decoration: InputDecoration(
            hintText: 'Escribe tu pregunta aquí',
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Text('Tipo de pregunta:'),
            SizedBox(width: 10),
            DropdownButton<bool>(
              value: _opcionMultiple,
              onChanged: (bool? newValue) {
                setState(() {
                  _opcionMultiple = newValue!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: false,
                  child: Text('Abierta'),
                ),
                DropdownMenuItem(
                  value: true,
                  child: Text('Opción múltiple'),
                ),
              ],
            ),
          ],
        ),
        if (_opcionMultiple) ...[
          SizedBox(height: 20),
          Text('Añadir Opciones:'),
          _buildOpciones(),
          SizedBox(height: 10),
          TextFormField(
            controller: _opcionController,
            decoration: InputDecoration(
              hintText: 'Escribe una opción',
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _agregarOpcion,
            child: Text('Añadir Opción'),
          ),
        ],
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _guardarPregunta,
          child: Text('Guardar Pregunta'),
        ),
      ],
    );
  }

  Widget _buildOpciones() {
    return Column(
      children: [
        ..._opciones.map((opcion) {
          return ListTile(
            title: Text(opcion),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _opciones.remove(opcion);
                });
              },
            ),
          );
        }).toList(),
        ListTile(
          title: Text('Otros'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _opciones.remove('Otros');
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContestarPreguntas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _preguntas.map((pregunta) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(pregunta.pregunta),
              ),
              if (pregunta.opciones.isNotEmpty)
                ...pregunta.opciones.map((opcion) {
                  return RadioListTile<String>(
                    title: Text(opcion),
                    value: opcion,
                    groupValue: pregunta.respuestaUsuario,
                    onChanged: (String? value) {
                      setState(() {
                        pregunta.respuestaUsuario = value;
                      });
                    },
                  );
                }).toList(),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Escribe aquí tu respuesta',
                  ),
                  onChanged: (value) {
                    pregunta.respuestaUsuario = value;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _eliminarPregunta(pregunta);
                    },
                    child: Text('Eliminar Pregunta'),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _agregarOpcion() {
    setState(() {
      if (_opcionController.text.isNotEmpty) {
        _opciones.add(_opcionController.text);
        _opcionController.clear();
      }
    });
  }

  void _guardarPregunta() async {
    String preguntaText = _preguntaController.text;

    Pregunta nuevaPregunta = Pregunta(
      pregunta: preguntaText,
      opciones: _opciones,
      opcionMultiple: _opcionMultiple,
    );

    await _preguntasDao.insertPregunta(nuevaPregunta);
    _limpiarFormulario();
    _cargarPreguntas();
  }

  void _eliminarPregunta(Pregunta pregunta) async {
    await _preguntasDao.deletePregunta(pregunta);
    setState(() {
      _preguntas.remove(pregunta);
    });
  }

  void _limpiarFormulario() {
    _preguntaController.clear();
    _opcionController.clear();
    _opciones.clear();
    setState(() {
      _opcionMultiple = false;
    });
  }

  void _enviarRespuestas() async {
    String nombre = _nombreController.text;

    try {
      // Guardar todas las respuestas en la base de datos
      for (var pregunta in _preguntas) {
        await dbHelper.DatabaseHelper.instance.insertResultado(nombre, pregunta.pregunta, pregunta.respuestaUsuario ?? '');
      }

      // Mostrar mensaje de éxito en la consola
      print('Las respuestas se han guardado correctamente en la base de datos.');

      // Limpiar
      // Limpiar los campos y recargar las preguntas
      _limpiarFormulario();
      _nombreController.clear();
      _cargarPreguntas();

      // Mostrar mensaje de éxito
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Éxito'),
            content: Text('Las respuestas se han guardado correctamente en la base de datos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error al guardar las respuestas: $e');

      // Mostrar mensaje de error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al guardar las respuestas en la base de datos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

