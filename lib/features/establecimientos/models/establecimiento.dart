class Establecimiento {
  /// Base URL where uploaded logos are served from.
  static const String _logoBaseUrl =
      'https://parking.visiontic.com.co/logos/';

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
      logoUrl: _buildLogoUrl(json['logo'] as String?),
    );
  }

  /// Returns a fully-qualified URL for the logo, or null if there is none.
  static String? _buildLogoUrl(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'sin-imagen.png') return null;
    // If the API ever returns a full URL, pass it through unchanged.
    if (raw.startsWith('http')) return raw;
    return '$_logoBaseUrl$raw';
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
