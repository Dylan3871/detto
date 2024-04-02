// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:detto/database/database_helper.dart';
import 'package:detto/database/preguntas_dao.dart';

class Pregunta {
  int? id;
  String pregunta;
  List<String> opciones;
  String? respuestaUsuario;
  String? respuestaAbierta;

  Pregunta({
    this.id,
    required this.pregunta,
    required this.opciones, 
    required bool opcionMultiple,
    required String respuestaUsuario,
    required String? respuestaAbierta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregunta': pregunta,
      'opciones': opciones.join(','), // Convertir la lista de opciones a una cadena
    };
  }

factory Pregunta.fromMap(Map<String, dynamic> map) {
  return Pregunta(
    id: map['id'],
    pregunta: map['pregunta'],
    opciones: (map['opciones'] as String).split(','), // Convertir la cadena de opciones a una lista
    opcionMultiple: false,
    respuestaUsuario: '',
    respuestaAbierta: '',
  );
}


  Future<void> eliminar(PreguntasDao preguntasDao) async {
    if (id != null) {
      await preguntasDao.deletePregunta(this);
    }
  }
}

class PaginaPreguntas extends StatefulWidget {
  @override
  _PaginaPreguntasState createState() => _PaginaPreguntasState();
}

class _PaginaPreguntasState extends State<PaginaPreguntas> {
  final PreguntasDao _preguntasDao = PreguntasDao(DatabaseHelper.instance);
  List<Pregunta> _preguntas = [];

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  void _cargarPreguntas() async {
    final preguntas = await _preguntasDao.getAllPreguntas();
    setState(() {
      _preguntas = preguntas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas'),
      ),
      body: _buildListaPreguntas(),
    );
  }

  Widget _buildListaPreguntas() {
    return ListView.builder(
      itemCount: _preguntas.length,
      itemBuilder: (context, index) {
        final pregunta = _preguntas[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(pregunta.pregunta),
            subtitle: _buildOpcionesRespuesta(pregunta),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _eliminarPregunta(pregunta);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpcionesRespuesta(Pregunta pregunta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pregunta.opciones.map((opcion) {
        return RadioListTile<String>(
          title: Text(opcion),
          value: opcion,
          groupValue: pregunta.respuestaUsuario,
          onChanged: (value) {
            setState(() {
              pregunta.respuestaUsuario = value;
            });
          },
        );
      }).toList(),
    );
  }

  Future<void> _eliminarPregunta(Pregunta pregunta) async {
    await pregunta.eliminar(_preguntasDao);
    _cargarPreguntas();
  }
}