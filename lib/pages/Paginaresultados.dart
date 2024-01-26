import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Paginaresultados extends StatelessWidget {
  Future<Map<String, String>> _obtenerRespuestasLocalmente() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? respuestasJson = prefs.getString('respuestas');

    if (respuestasJson != null) {
      final Map<String, dynamic> respuestasMap = json.decode(respuestasJson);
      final Map<String, String> respuestas = respuestasMap.cast<String, String>();
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
    // Aquí puedes construir tu tabla utilizando los datos de respuestas
    // Puedes utilizar un paquete de Flutter como 'datatable' o construir tu propia tabla con Column y Row
    // Ejemplo con DataTable:
    return DataTable(
      columns: [
        DataColumn(label: Text('Pregunta')),
        DataColumn(label: Text('Respuesta')),
      ],
      rows: respuestas.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key)),
          DataCell(Text(entry.value)),
        ]);
      }).toList(),
    );
  }
}
