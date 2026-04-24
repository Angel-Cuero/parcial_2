class Establecimiento {
  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String? logoUrl;

  const Establecimiento({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    this.logoUrl,
  });

  factory Establecimiento.fromJson(Map<String, dynamic> json) {
    return Establecimiento(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] as String? ?? '',
      nit: json['nit'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      logoUrl: json['logo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'nit': nit,
        'direccion': direccion,
        'telefono': telefono,
        'logo': logoUrl,
      };

  Establecimiento copyWith({
    int? id,
    String? nombre,
    String? nit,
    String? direccion,
    String? telefono,
    String? logoUrl,
  }) {
    return Establecimiento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }
}
