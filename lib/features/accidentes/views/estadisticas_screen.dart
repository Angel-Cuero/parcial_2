import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/theme/app_theme.dart';
import '../services/accidentes_service.dart';
import '../isolates/accidentes_isolate.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

enum _LoadState { loading, success, error }

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  _LoadState _state = _LoadState.loading;
  AccidentesStats? _stats;
  String _errorMsg = '';

  final _service = AccidentesService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _LoadState.loading);
    try {
      final raw = await _service.fetchAllRaw();
      final stats = await calcularEstadisticas(raw);
      setState(() {
        _stats = stats;
        _state = _LoadState.success;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _state = _LoadState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Estadísticas de Accidentes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                background: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
              ),
            ),
            if (_state == _LoadState.error)
              SliverFillRemaining(child: _buildError())
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTotalBadge(),
                    const SizedBox(height: 20),
                    _buildChartCard(
                      title: '🚗 Distribución por Clase de Accidente',
                      child: _buildClasePieChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      title: '⚠️ Distribución por Gravedad',
                      child: _buildGravedadBarChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      title: '📍 Top 5 Barrios con más Accidentes',
                      child: _buildTop5BarriosChart(),
                    ),
                    const SizedBox(height: 16),
                    _buildChartCard(
                      title: '📅 Distribución por Día de la Semana',
                      child: _buildPorDiaChart(),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBadge() {
    return Skeletonizer(
      enabled: _state == _LoadState.loading,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total de Registros Procesados',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  _stats != null
                      ? '${_stats!.totalRegistros.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} accidentes'
                      : 'Cargando...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Skeletonizer(
      enabled: _state == _LoadState.loading,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
              const SizedBox(height: 16),
              SizedBox(height: 260, child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 64),
            const SizedBox(height: 16),
            const Text('Error al cargar los datos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(_errorMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chart 1: PIE — Clase de Accidente ────────────────────────────────────

  Widget _buildClasePieChart() {
    if (_state == _LoadState.loading || _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _stats!.porClase;
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return const Center(child: Text('Sin datos'));

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00D4AA),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFFCE93D8),
    ];

    final entries = data.entries.toList();
    int colorIdx = 0;

    final sections = entries.map((e) {
      final pct = (e.value / total * 100).toStringAsFixed(1);
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '$pct%',
        radius: 80,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(PieChartData(
            sections: sections,
            centerSpaceRadius: 36,
            sectionsSpace: 3,
            borderData: FlBorderData(show: false),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _capitalize(entries[i].key),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── Chart 2: BAR — Gravedad ───────────────────────────────────────────────

  Widget _buildGravedadBarChart() {
    if (_state == _LoadState.loading || _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _stats!.porGravedad;
    if (data.isEmpty) return const Center(child: Text('Sin datos'));

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF00D4AA),
      const Color(0xFF6C63FF),
    ];

    final maxY =
        entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: List.generate(entries.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: entries[i].value.toDouble(),
                color: colors[i % colors.length],
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= entries.length) return const SizedBox();
                final label = _shortenGravedad(entries[idx].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(label,
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 9),
                      textAlign: TextAlign.center),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFF2A2A4A), strokeWidth: 1),
          drawVerticalLine: false,
        ),
      ),
    );
  }

  // ─── Chart 3: BAR — Top 5 Barrios ─────────────────────────────────────────

  Widget _buildTop5BarriosChart() {
    if (_state == _LoadState.loading || _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final top5 = _stats!.top5Barrios;
    if (top5.isEmpty) return const Center(child: Text('Sin datos'));

    final maxY =
        top5.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    const gradient = LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barGroups: List.generate(top5.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: top5[i].value.toDouble(),
                gradient: gradient,
                width: 32,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= top5.length) return const SizedBox();
                final name = top5[idx].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _capitalize(name.length > 10
                        ? '${name.substring(0, 10)}…'
                        : name),
                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0xFF2A2A4A), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${top5[groupIndex].key}\n',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '${rod.toY.toInt()} accidentes',
                    style: const TextStyle(
                        color: Color(0xFF00D4AA), fontWeight: FontWeight.normal),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Chart 4: PIE — Día de la semana ──────────────────────────────────────

  Widget _buildPorDiaChart() {
    if (_state == _LoadState.loading || _stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final raw = _stats!.porDia;
    if (raw.isEmpty) return const Center(child: Text('Sin datos'));

    final Map<String, int> normalized = {};
    raw.forEach((key, val) {
      // Normalize accented chars for ordering
      final norm = key.toLowerCase().trim();
      normalized[norm] = (normalized[norm] ?? 0) + val;
    });

    // Merge accented variants
    if (normalized.containsKey('miercoles') && normalized.containsKey('miércoles')) {
      normalized['miércoles'] =
          (normalized['miércoles'] ?? 0) + (normalized.remove('miercoles') ?? 0);
    } else if (normalized.containsKey('miercoles')) {
      normalized['miércoles'] = normalized.remove('miercoles') ?? 0;
    }
    if (normalized.containsKey('sabado') && normalized.containsKey('sábado')) {
      normalized['sábado'] =
          (normalized['sábado'] ?? 0) + (normalized.remove('sabado') ?? 0);
    } else if (normalized.containsKey('sabado')) {
      normalized['sábado'] = normalized.remove('sabado') ?? 0;
    }

    final sortedDays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final entries = sortedDays
        .where((d) => normalized.containsKey(d))
        .map((d) => MapEntry(d, normalized[d]!))
        .toList();

    if (entries.isEmpty) return const Center(child: Text('Sin datos'));

    final total = entries.map((e) => e.value).fold(0, (a, b) => a + b);
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00D4AA),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF4FC3F7),
      const Color(0xFFCE93D8),
      const Color(0xFF81C784),
    ];

    final sections = List.generate(entries.length, (i) {
      final pct = (entries[i].value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: entries[i].value.toDouble(),
        title: '$pct%',
        radius: 75,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      );
    });

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(PieChartData(
            sections: sections,
            centerSpaceRadius: 30,
            sectionsSpace: 2,
            borderData: FlBorderData(show: false),
          )),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(entries.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _capitalize(entries[i].key),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  String _shortenGravedad(String s) {
    if (s.startsWith('CON MUERTO')) return 'Con\nMuertos';
    if (s.startsWith('CON HERIDO')) return 'Con\nHeridos';
    if (s.startsWith('SOLO DA')) return 'Solo\nDaños';
    if (s.startsWith('SIN DATO')) return 'Sin\nDatos';
    final words = s.split(' ');
    return words.take(2).join('\n');
  }
}
