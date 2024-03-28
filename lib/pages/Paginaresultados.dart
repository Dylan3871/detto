import 'package:flutter/material.dart';
import 'package:detto/database/database_helper.dart';
import 'package:detto/models/resultados_model.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Paginaresultados extends StatefulWidget {
  @override
  _PaginaresultadosState createState() => _PaginaresultadosState();
}

class _PaginaresultadosState extends State<Paginaresultados> {
  late Future<List<Resultado>> _respuestasFuture;

  @override
  void initState() {
    super.initState();
    _respuestasFuture = _obtenerRespuestas();
  }

  Future<List<Resultado>> _obtenerRespuestas() async {
    try {
      final db = DatabaseHelper.instance;
      final List<Resultado>? resultados = await db.getAllResultados();
      if (resultados != null) {
        print('Datos obtenidos de la base de datos: $resultados');
        return resultados;
      } else {
        print('La consulta devolvió un valor nulo');
        return []; // Devolver una lista vacía en caso de que la consulta devuelva un valor nulo
      }
    } catch (e) {
      print('Error al obtener respuestas: $e');
      return []; // Devolver una lista vacía en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Respuestas Preguntas Iniciales'),
      ),
      body: FutureBuilder<List<Resultado>>(
        future: _respuestasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al obtener resultados'),
            );
          } else {
            final resultados = snapshot.data;
            if (resultados == null || resultados.isEmpty) {
              return Center(
                child: Text('No hay resultados disponibles'),
              );
            } else {
              final groupedResults = _groupResultsByNombre(resultados);
              return _construirListaDeResultados(context, groupedResults);
            }
          }
        },
      ),
    );
  }

  Map<String, List<Resultado>> _groupResultsByNombre(List<Resultado> resultados) {
    Map<String, List<Resultado>> groupedResults = {};
    resultados.forEach((resultado) {
      if (!groupedResults.containsKey(resultado.nombre)) {
        groupedResults[resultado.nombre] = [];
      }
      groupedResults[resultado.nombre]!.add(resultado);
    });
    return groupedResults;
  }

  Widget _construirListaDeResultados(BuildContext context, Map<String, List<Resultado>> groupedResults) {
    return ListView.builder(
      itemCount: groupedResults.length,
      itemBuilder: (context, index) {
        final nombre = groupedResults.keys.elementAt(index);
        final resultados = groupedResults[nombre]!;
        return Card(
          margin: const EdgeInsets.all(8),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  nombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    _generarPDF(context, resultados, nombre);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _eliminarResultados(context, nombre);
                  },
                ),
              ],
            ),
            children: resultados.map((resultado) {
              return ListTile(
                title: Text(resultado.pregunta),
                subtitle: Text('Respuesta: ${resultado.respuesta}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _eliminarResultados(BuildContext context, String nombre) async {
    try {
      final db = DatabaseHelper.instance;
      await db.deleteResultadosPorNombre(nombre);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resultados eliminados'),
        ),
      );
      setState(() {
        // Actualizar la lista de resultados después de eliminar
        _respuestasFuture = _obtenerRespuestas();
      });
    } catch (e) {
      print('Error al eliminar los resultados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar los resultados'),
        ),
      );
    }
  }

  void _generarPDF(BuildContext context, List<Resultado> preguntas, String nombreEmpresa) async {
    final pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.MultiPage(
        build: (context) => [
          pdfLib.Header(level: 0, text: 'Preguntas y Respuestas'),
          pdfLib.Paragraph(
            text: 'Fecha de generación: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
          ),
          pdfLib.Paragraph(
            text: 'Nombre de la empresa: $nombreEmpresa',
          ),
          pdfLib.SizedBox(height: 20),
          pdfLib.Table.fromTextArray(
            border: pdfLib.TableBorder.all(),
            headerStyle: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
            cellAlignment: pdfLib.Alignment.center,
            data: <List<dynamic>>[
              ['Pregunta', 'Respuesta'],
              ...preguntas.map((pregunta) => [
                pregunta.pregunta,
                pregunta.respuesta,
              ]),
            ],
          ),
        ],
      ),
    );

    final directory = await getExternalStorageDirectory();
    final pdfFile = File('${directory!.path}/preguntas_$nombreEmpresa.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF generado y guardado correctamente'),
      ),
    );
  }
}
