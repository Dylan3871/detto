// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paginaresultados extends StatelessWidget {
  Future<Map<String, String>> _obtenerRespuestasLocalmente() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? respuestasJson = prefs.getString('respuestas');

    if (respuestasJson != null) {
      final Map<String, dynamic> respuestasMap = json.decode(respuestasJson);
      final Map<String, String> respuestas =
          respuestasMap.cast<String, String>();
      return respuestas;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _obtenerRespuestasLocalmente(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Puedes mostrar un indicador de carga mientras se obtienen las respuestas
        } else if (snapshot.hasError) {
          return Text('Error al obtener respuestas'); // Manejo de errores
        } else {
          final Map<String, String> respuestas = snapshot.data!;
          return _construirTablaDeRespuestas(respuestas);
        }
      },
    );
  }

  Widget _construirTablaDeRespuestas(Map<String, String> respuestas) {
  // Contenedor con borde y sombra
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), // Color del borde
      borderRadius: BorderRadius.circular(10.0), // Radio de la esquina del contenedor
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Color de la sombra
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 2), // Desplazamiento de la sombra
        ),
      ],
    ),
    // DataTable dentro del contenedor
    child: DataTable(
      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey),
      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
      columns: [
        DataColumn(
          label: Text('Pregunta', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Respuesta', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: respuestas.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value)),
        ]);
      }).toList(),
    ),
  );
}

}
