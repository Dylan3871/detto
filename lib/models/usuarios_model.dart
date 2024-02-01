class UsuariosModel {
  final int id;
  final String name;
  final String apellido;
  final String correo;
  final String contrasena;
  final String imagenPerfil;
  final String imagenQR;
  final String cargo;

  UsuariosModel({
    this.id = -1,
    required this.name,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.imagenPerfil,
    required this.imagenQR,
    required this.cargo,
  });

  UsuariosModel copyWith({
    int? id,
    String? name,
    String? apellido,
    String? correo,
    String? contrasena,
    String? imagenPerfil,
    String? imagenQR,
    String? cargo,
  }) {
    return UsuariosModel(
      id: id ?? this.id,
      name: name ?? this.name,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      imagenQR: imagenQR ?? this.imagenQR,
      cargo: cargo ?? this.cargo,
    );
  }

  factory UsuariosModel.fromMap(Map<String, dynamic> map) {
  return UsuariosModel(
    id: map['id'] ?? -1,
    name: map['name'] ?? '',
    apellido: map['apellido'] ?? '',
    correo: map['correo'] ?? '',
    contrasena: map['contrasena'] ?? '',
    imagenPerfil: map['imagenPerfil'] ?? '',
    imagenQR: map['imagenQR'] ?? '',
    cargo: map['cargo'] ?? '',
  );
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'imagenPerfil': imagenPerfil,
      'imagenQR': imagenQR,
      'cargo': cargo,
    };
  }
}
