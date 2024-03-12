class CotizadorItem {
  int? id;
  String? fechaaut;
  String? fechavig;
  String? nombreCliente;
  String? nombrePrenda;
  String? fotos;
  String? fotosF; // Nuevo campo agregado
  double? margenPre;
  double? costo;
  int? piezas;
  String? comentario;
  double? descuentoP;
  double? totalP;
  String? comentarioF;
  double? subtotal;
  double? descuentoG;
  double? iva;
  double? totalF;

  CotizadorItem({
    this.id,
    this.fechaaut,
    this.fechavig,
    this.nombreCliente,
    this.nombrePrenda,
    this.fotos,
    this.fotosF,
    this.margenPre,
    this.costo,
    this.piezas,
    this.comentario,
    this.descuentoP,
    this.totalP,
    this.comentarioF,
    this.subtotal,
    this.descuentoG,
    this.iva,
    this.totalF,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fechaaut': fechaaut,
      'fechavig': fechavig,
      'nombreCliente': nombreCliente,
      'nombrePrenda': nombrePrenda,
      'fotos': fotos,
      'fotosF': fotosF, // Agregado al mapa
      'margenPre': margenPre,
      'costo': costo,
      'piezas': piezas,
      'comentario': comentario,
      'descuentoP': descuentoP,
      'totalP': totalP,
      'comentarioF': comentarioF,
      'subtotal': subtotal,
      'descuentoG': descuentoG,
      'iva': iva,
      'totalF': totalF,
    };
  }

  factory CotizadorItem.fromMap(Map<String, dynamic> map) {
    return CotizadorItem(
      id: map['id'],
      fechaaut: map['fechaaut'],
      fechavig: map['fechavig'],
      nombreCliente: map['nombreCliente'],
      nombrePrenda: map['nombrePrenda'],
      fotos: map['fotos'],
      fotosF: map['fotosF'], // Asignación del nuevo campo
      margenPre: map['margenPre'],
      costo: map['costo'],
      piezas: map['piezas'],
      comentario: map['comentario'],
      descuentoP: map['descuentoP'],
      totalP: map['totalP'],
      comentarioF: map['comentarioF'],
      subtotal: map['subtotal'],
      descuentoG: map['descuentoG'],
      iva: map['iva'],
      totalF: map['totalF'],
    );
  }
}
