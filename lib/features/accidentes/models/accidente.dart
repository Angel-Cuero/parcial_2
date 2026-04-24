class Accidente {
  final String claseAccidente;
  final String gravedadAccidente;
  final String barrioHecho;
  final String dia;
  final String hora;
  final String area;
  final String claseVehiculo;

  const Accidente({
    required this.claseAccidente,
    required this.gravedadAccidente,
    required this.barrioHecho,
    required this.dia,
    required this.hora,
    required this.area,
    required this.claseVehiculo,
  });

  factory Accidente.fromJson(Map<String, dynamic> json) {
    return Accidente(
      claseAccidente:
          (json['clase_de_accidente'] as String? ?? 'OTRO').toUpperCase(),
      gravedadAccidente:
          (json['gravedad_del_accidente'] as String? ?? 'SIN DATOS')
              .toUpperCase(),
      barrioHecho: (json['barrio_hecho'] as String? ?? 'NO INFORMA'),
      dia: (json['dia'] as String? ?? 'NO INFORMA').toLowerCase(),
      hora: json['hora'] as String? ?? '',
      area: (json['area'] as String? ?? 'NO INFORMA').toUpperCase(),
      claseVehiculo:
          (json['clase_de_vehiculo'] as String? ?? 'NO INFORMA').toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() => {
        'clase_de_accidente': claseAccidente,
        'gravedad_del_accidente': gravedadAccidente,
        'barrio_hecho': barrioHecho,
        'dia': dia,
        'hora': hora,
        'area': area,
        'clase_de_vehiculo': claseVehiculo,
      };
}
