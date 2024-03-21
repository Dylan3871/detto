import 'dart:convert';

class Resultado {
  int? id;
  String nombre;
  String pregunta;
  String respuesta;

  Resultado({
    this.id,
    required this.nombre,
    required this.pregunta,
    required this.respuesta,
  });

  // Método para convertir un objeto Resultado a un Map para ser utilizado en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'pregunta': pregunta,
      'respuesta': respuesta,
    };
  }

  // Método para crear un objeto Resultado a partir de un Map obtenido de la base de datos
  factory Resultado.fromMap(Map<String, dynamic> map) {
    return Resultado(
      id: map['id'],
      nombre: map['nombre'],
      pregunta: map['pregunta'],
      respuesta: map['respuesta'],
    );
  }
}

void main() {
  // Crear una instancia de Resultado
  Resultado resultado = Resultado(
    nombre: 'Juan',
    pregunta: '¿Cuál es tu color favorito?',
    respuesta: 'Azul',
  );

  // Convertir el objeto Resultado a un mapa
  Map<String, dynamic> resultadoMap = resultado.toMap();

  // Convertir el mapa a formato JSON
  String resultadoJson = jsonEncode(resultadoMap);

  // Imprimir el JSON resultante
  print(resultadoJson);

  // Para recuperar un objeto Resultado a partir de un mapa (por ejemplo, desde la base de datos):
  Map<String, dynamic> resultadoMapRecuperado = jsonDecode(resultadoJson);
  Resultado resultadoRecuperado = Resultado.fromMap(resultadoMapRecuperado);

  // Imprimir el objeto Resultado recuperado
  print(resultadoRecuperado);
}
