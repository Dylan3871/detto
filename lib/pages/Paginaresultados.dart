import 'package:flutter/material.dart';
import 'package:detto/database/database_helper.dart';
import 'package:detto/models/resultados_model.dart';

class Paginaresultados extends StatelessWidget {
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
        title: Text('Respuestas Peguntas Iniciales'),
      ),
      body: FutureBuilder<List<Resultado>>(
        future: _obtenerRespuestas(),
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
              return _construirListaDeResultados(context, resultados);
            }
          }
        },
      ),
    );
  }

  Widget _construirListaDeResultados(BuildContext context, List<Resultado> resultados) {
    final groupedResults = _groupResultsByNombre(resultados);
    return ListView.builder(
      itemCount: groupedResults.length,
      itemBuilder: (context, index) {
        final nombre = groupedResults.keys.elementAt(index);
        final preguntas = groupedResults[nombre]!;
        return Card(
          margin: EdgeInsets.all(8),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  nombre,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _eliminarResultados(context, nombre);
                  },
                ),
              ],
            ),
            children: preguntas.map((pregunta) {
              return ListTile(
                title: Text(pregunta.pregunta),
                subtitle: Text('Respuesta: ${pregunta.respuesta}'),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Map<String, List<Resultado>> _groupResultsByNombre(List<Resultado> resultados) {
    final Map<String, List<Resultado>> groupedResults = {};
    for (final resultado in resultados) {
      if (!groupedResults.containsKey(resultado.nombre)) {
        groupedResults[resultado.nombre] = [];
      }
      groupedResults[resultado.nombre]!.add(resultado);
    }
    return groupedResults;
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
      // No es necesario actualizar la lista de resultados aquí, ya que la lista se actualizará automáticamente al regresar a la página anterior
    } catch (e) {
      print('Error al eliminar los resultados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar los resultados'),
        ),
      );
    }
  }
}
