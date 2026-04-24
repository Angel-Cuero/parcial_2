import 'dart:isolate';

/// Data class returned by the Isolate after computing all 4 statistics.
class AccidentesStats {
  final Map<String, int> porClase;
  final Map<String, int> porGravedad;
  final List<MapEntry<String, int>> top5Barrios;
  final Map<String, int> porDia;
  final int totalRegistros;

  const AccidentesStats({
    required this.porClase,
    required this.porGravedad,
    required this.top5Barrios,
    required this.porDia,
    required this.totalRegistros,
  });
}

/// Entry point for [Isolate.run]. Receives the raw JSON list, computes
/// the 4 statistics, and returns an [AccidentesStats] object.
///
/// Console output required by the spec:
///   [Isolate] Iniciado — N registros recibidos
///   [Isolate] Completado en X ms
AccidentesStats calcularEstadisticasIsolate(List<Map<String, dynamic>> records) {
  final stopwatch = Stopwatch()..start();
  print('[Isolate] Iniciado — ${records.length} registros recibidos');

  try {
    // 1 — Distribución por clase de accidente
    final Map<String, int> porClase = {};
    // 2 — Distribución por gravedad
    final Map<String, int> porGravedad = {};
    // 3 — Conteo por barrio (para top 5)
    final Map<String, int> porBarrio = {};
    // 4 — Distribución por día de la semana
    final Map<String, int> porDia = {};

    for (final r in records) {
      // Clase de accidente
      final clase =
          (r['clase_de_accidente'] as String? ?? 'OTRO').toUpperCase().trim();
      porClase[clase] = (porClase[clase] ?? 0) + 1;

      // Gravedad
      final gravedad =
          (r['gravedad_del_accidente'] as String? ?? 'SIN DATOS')
              .toUpperCase()
              .trim();
      porGravedad[gravedad] = (porGravedad[gravedad] ?? 0) + 1;

      // Barrio
      final barrio = (r['barrio_hecho'] as String? ?? 'NO INFORMA').trim();
      if (barrio.isNotEmpty &&
          barrio.toUpperCase() != 'NO INFORMA' &&
          barrio.toUpperCase() != 'SIN INFORMACIÓN') {
        porBarrio[barrio] = (porBarrio[barrio] ?? 0) + 1;
      }

      // Día de la semana
      final dia =
          (r['dia'] as String? ?? 'no informa').toLowerCase().trim();
      porDia[dia] = (porDia[dia] ?? 0) + 1;
    }

    // Top 5 barrios — sort descending and take first 5
    final top5Barrios = porBarrio.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = top5Barrios.take(5).toList();

    stopwatch.stop();
    print('[Isolate] Completado en ${stopwatch.elapsedMilliseconds} ms');

    return AccidentesStats(
      porClase: porClase,
      porGravedad: porGravedad,
      top5Barrios: top5,
      porDia: porDia,
      totalRegistros: records.length,
    );
  } catch (e, st) {
    stopwatch.stop();
    print('[Isolate] ERROR en ${stopwatch.elapsedMilliseconds} ms: $e\n$st');
    // Return empty stats on error so the app doesn't crash
    return const AccidentesStats(
      porClase: {},
      porGravedad: {},
      top5Barrios: [],
      porDia: {},
      totalRegistros: 0,
    );
  }
}

/// Public helper — runs [calcularEstadisticasIsolate] in a separate Isolate
/// using [Isolate.run] (Flutter 3 / Dart 2.19+).
Future<AccidentesStats> calcularEstadisticas(
    List<Map<String, dynamic>> records) async {
  return Isolate.run(() => calcularEstadisticasIsolate(records));
}
