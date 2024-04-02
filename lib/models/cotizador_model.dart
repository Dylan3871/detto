class CotizadorItem {
  int? id;
  String? empresa; // Nuevo campo agregado
  String? contacto; // Nuevo campo agregado
  String? correo; // Nuevo campo agregado
  String? telefono; // Nuevo campo agregado
  String? fechaaut;
  String? fechavig;
  String? nombreCliente;
  String? nombrePrenda;
  String? fotos;
  String? fotosF;
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
  String? concdicioncom; // Nuevo campo agregado

  CotizadorItem({
    this.id,
    this.empresa,
    this.contacto,
    this.correo,
    this.telefono,
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
    this.concdicioncom,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresa': empresa,
      'contacto': contacto,
      'correo': correo,
      'telefono': telefono,
      'fechaaut': fechaaut,
      'fechavig': fechavig,
      'nombreCliente': nombreCliente,
      'nombrePrenda': nombrePrenda,
      'fotos': fotos,
      'fotosF': fotosF,
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
      'concdicioncom': concdicioncom,
    };
  }

  factory CotizadorItem.fromMap(Map<String, dynamic> map) {
    return CotizadorItem(
      id: map['id'],
      empresa: map['empresa'],
      contacto: map['contacto'],
      correo: map['correo'],
      telefono: map['telefono'],
      fechaaut: map['fechaaut'],
      fechavig: map['fechavig'],
      nombreCliente: map['nombreCliente'],
      nombrePrenda: map['nombrePrenda'],
      fotos: map['fotos'],
      fotosF: map['fotosF'],
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
      concdicioncom: map['concdicioncom'],
    );
  }
}
