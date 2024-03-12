class CatalogoItem {
  int? id;
  String? nombrePrenda;
  String? fotos;
  String? tallas;
  String? material;
  String? colores;
  String? video;
  String? genero;
  String? campo;
  String? descripcion;
  int? costoini; // Cambiado a int
  String? codigod; // Cambiado a int

  CatalogoItem({
    this.id,
    this.nombrePrenda,
    this.fotos,
    this.tallas,
    this.material,
    this.colores,
    this.video,
    this.genero,
    this.campo,
    this.descripcion,
    this.costoini,
    this.codigod,
  });

  get otroCampo => null;

  get algunCampo => null;

  get isSelected => null;

  get isFavorite => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombrePrenda': nombrePrenda,
      'fotos': fotos,
      'tallas': tallas,
      'material': material,
      'colores': colores,
      'video': video,
      'genero': genero,
      'campo': campo,
      'descripcion': descripcion,
      'costoini': costoini,
      'codigod': codigod,
    };
  }

  factory CatalogoItem.fromMap(Map<String, dynamic> map) {
    return CatalogoItem(
      id: map['id'],
      nombrePrenda: map['nombrePrenda'],
      fotos: map['fotos'],
      tallas: map['tallas'],
      material: map['material'],
      colores: map['colores'],
      video: map['video'],
      genero: map['genero'],
      campo: map['campo'],
      descripcion: map['descripcion'],
      costoini: map['costoini'],
      codigod: map['codigod'],
    );
  }

  CatalogoItem copyWith({
    int? id,
    String? nombrePrenda,
    String? fotos,
    String? tallas,
    String? material,
    String? colores,
    String? video,
    String? genero,
    String? campo,
    String? descripcion,
    int? costoini,
    String? codigod,
  }) {
    return CatalogoItem(
      id: id ?? this.id,
      nombrePrenda: nombrePrenda ?? this.nombrePrenda,
      fotos: fotos ?? this.fotos,
      tallas: tallas ?? this.tallas,
      material: material ?? this.material,
      colores: colores ?? this.colores,
      video: video ?? this.video,
      genero: genero ?? this.genero,
      campo: campo ?? this.campo,
      descripcion: descripcion ?? this.descripcion,
      costoini: costoini ?? this.costoini,
      codigod: codigod ?? this.codigod,
    );
  }

  getValueForFilter(String option) {}

  void toggleSelected() {}
}
