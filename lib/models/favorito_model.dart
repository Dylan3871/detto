class Favorito {
  int? id; // Cambiar a tipo int?

  String fotos;
  String nombrePrenda;
  int costoini;
  String codigod;

  Favorito({
    this.id, // Cambiar a tipo int?
    required this.fotos,
    required this.nombrePrenda,
    required this.costoini,
    required this.codigod,
  });

  // Constructor de fábrica para crear una instancia de Favorito desde un mapa JSON
  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'],
      fotos: json['fotos'],
      nombrePrenda: json['nombrePrenda'],
      costoini: json['costoini'],
      codigod: json['codigod'],
    );
  }

  get descripcion => null;

  get fechaAut => null;

  get fechaVig => null;

  // Método toJson para convertir un objeto Favorito a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fotos': fotos,
      'nombrePrenda': nombrePrenda,
      'costoini': costoini,
      'codigod': codigod,
    };
  }

  // Método toMap para convertir un objeto Favorito a un mapa
  Map<String, dynamic> toMap() {
    return {
      'fotos': fotos,
      'nombrePrenda': nombrePrenda,
      'costoini': costoini,
      'codigod': codigod,
    };
  }
}
