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
  });

  get otroCampo => null;

  get algunCampo => null;

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
    );
  }

  getValueForFilter(String option) {}
}
