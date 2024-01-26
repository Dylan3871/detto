import 'dart:convert';

import 'package:detto/pages/Paginaresultados.dart';
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
      child: Column(
        children: [
          Text(
            'Preguntas:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Almacena las respuestas en el mapa
                Map<String, String> respuestasList = {
                  'Pregunta 1': _pregunta1Controller.text,
                  'Pregunta 2': _pregunta2Controller.text,
                  'Pregunta 3': _pregunta3Controller.text,
                  'Pregunta 4': _pregunta4Controller.text,
                  'Pregunta 5': _pregunta5Controller.text,
                };

                await _guardarRespuestasLocalmente(respuestasList);

                // Muestra un mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Respuestas enviadas con éxito'),
                  ),
                );

                // Navega a otra pantalla (puedes cambiar 'OtraPantalla' por el nombre de tu pantalla)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Paginaresultados(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(primary: Colors.blue),
            child: Text('Enviar Respuestas'),
          ),
        ],
      ),
    );
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
