// ignore_for_file: file_names, prefer_const_constructors_in_immutables, prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, prefer_final_fields, library_private_types_in_public_api, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Paginapreguntas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PreguntasForm(),
      ),
    );
  }
}

class PreguntasForm extends StatefulWidget {
  @override
  _PreguntasFormState createState() => _PreguntasFormState();
}

class _PreguntasFormState extends State<PreguntasForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _pregunta1Controller = TextEditingController();
  TextEditingController _pregunta2Controller = TextEditingController();
  TextEditingController _pregunta3Controller = TextEditingController();
  TextEditingController _pregunta4Controller = TextEditingController();
  TextEditingController _pregunta5Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16.0), // Agrega padding al Container
        margin: EdgeInsets.all(16.0), // Agrega margen al Container
        decoration: BoxDecoration(
          color: Colors.white, // Cambia el color de fondo del Container
          borderRadius: BorderRadius.circular(10.0), // Agrega bordes redondeados
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Preguntas:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            PreguntaWidget(
              numeroPregunta: 1,
              pregunta: '¿Cuántos empleados tiene tu empresa?',
              controller: _pregunta1Controller,
            ),
            SizedBox(height: 16),
            PreguntaWidget(
              numeroPregunta: 2,
              pregunta: '¿Cuál es la preferencia de color o diseño para los uniformes?',
              controller: _pregunta2Controller,
            ),
            SizedBox(height: 16),
            PreguntaWidget(
              numeroPregunta: 3,
              pregunta: '¿Necesitas uniformes específicos para diferentes departamentos o roles?',
              controller: _pregunta3Controller,
            ),
            SizedBox(height: 16),
            PreguntaWidget(
              numeroPregunta: 4,
              pregunta: '¿Tienes alguna preferencia en cuanto a la calidad o tipo de tela?',
              controller: _pregunta4Controller,
            ),
            SizedBox(height: 16),
            PreguntaWidget(
              numeroPregunta: 5,
              pregunta: '¿Cuál es tu presupuesto aproximado para los uniformes?',
              controller: _pregunta5Controller,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Map<String, String> respuestasList = {
                    'Pregunta 1': _pregunta1Controller.text,
                    'Pregunta 2': _pregunta2Controller.text,
                    'Pregunta 3': _pregunta3Controller.text,
                    'Pregunta 4': _pregunta4Controller.text,
                    'Pregunta 5': _pregunta5Controller.text,
                  };

                  await _guardarRespuestasLocalmente(respuestasList);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Registro Exitoso'),
                        content: Text('Respuestas enviadas con éxito.'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _limpiarRespuestas();
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Enviar Respuestas', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _limpiarRespuestas() {
    _pregunta1Controller.clear();
    _pregunta2Controller.clear();
    _pregunta3Controller.clear();
    _pregunta4Controller.clear();
    _pregunta5Controller.clear();
  }
}
Future<void> _guardarRespuestasLocalmente(Map<String, String> respuestasList) async{
  //Aqui obtenemos el objeo SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  //Almacenamos la respuesta en un formato JSON en SharedPreferences
  prefs.setString('respuestas', json.encode(respuestasList));
}

class PreguntaWidget extends StatelessWidget {
  final int numeroPregunta;
  final String pregunta;
  final TextEditingController controller;

  PreguntaWidget({
    required this.numeroPregunta,
    required this.pregunta,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$numeroPregunta. $pregunta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Respuesta'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Por favor, contesta las preguntas';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class OtraPantalla extends StatelessWidget {
  final Map<String, String> respuestas;

  OtraPantalla({required this.respuestas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Respuestas'),
      ),
      body: Column(
        children: [
          Text('Respuestas recibidas:'),
          // Puedes mostrar las respuestas aquí según tu diseño
          for (var entry in respuestas.entries)
            Text('${entry.key}: ${entry.value}'),
        ],
      ),
    );
  }
}
