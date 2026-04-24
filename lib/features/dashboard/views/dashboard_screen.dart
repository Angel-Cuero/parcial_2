import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/theme/app_theme.dart';
import '../../accidentes/services/accidentes_service.dart';
import '../../establecimientos/services/establecimientos_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _loadingAccidentes = true;
  bool _loadingEstablecimientos = true;
  int _totalAccidentes = 0;
  int _totalEstablecimientos = 0;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadSummary();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    // Load accidents count
    AccidentesService().fetchAllRaw().then((raw) {
      if (mounted) {
        setState(() {
          _totalAccidentes = raw.length;
          _loadingAccidentes = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => _loadingAccidentes = false);
    });

    // Load establishments count
    EstablecimientosService().getAll().then((list) {
      if (mounted) {
        setState(() {
          _totalEstablecimientos = list.length;
          _loadingEstablecimientos = false;
        });
      }
    }).catchError((_) {
      if (mounted) setState(() => _loadingEstablecimientos = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummaryRow(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Módulos'),
                      const SizedBox(height: 16),
                      _buildModuleCard(
                        id: 'btn_accidentes',
                        title: 'Estadísticas de\nAccidentes',
                        subtitle: 'Visualiza 4 gráficas de los\naccidentes de tránsito en Tuluá',
                        icon: Icons.bar_chart_rounded,
                        gradient: AppTheme.primaryGradient,
                        onTap: () => context.push('/accidentes'),
                      ),
                      const SizedBox(height: 16),
                      _buildModuleCard(
                        id: 'btn_establecimientos',
                        title: 'Gestión de\nEstablecimientos',
                        subtitle: 'CRUD completo de establecimientos\ncon carga de logo',
                        icon: Icons.store_rounded,
                        gradient: AppTheme.accentGradient,
                        onTap: () => context.push('/establecimientos'),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Acerca del Proyecto'),
                      const SizedBox(height: 12),
                      _buildInfoCard(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.dashboard_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parcial 2',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          letterSpacing: 1.5),
                    ),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Accidentes Tuluá · CRUD Establecimientos',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF2A2A4A)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            id: 'summary_accidentes',
            label: 'Accidentes',
            value: _totalAccidentes,
            loading: _loadingAccidentes,
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            id: 'summary_establecimientos',
            label: 'Establecimientos',
            value: _totalEstablecimientos,
            loading: _loadingEstablecimientos,
            icon: Icons.store_rounded,
            color: const Color(0xFF00D4AA),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildModuleCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: Key(id),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Color(0xFF6C63FF), size: 18),
              SizedBox(width: 8),
              Text('APIs utilizadas',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12),
          _ApiInfoRow(
            dot: Color(0xFF6C63FF),
            name: 'Datos Abiertos Colombia',
            desc: 'Accidentes de Tránsito Tuluá',
          ),
          _ApiInfoRow(
            dot: Color(0xFF00D4AA),
            name: 'VisionTIC Parqueadero',
            desc: 'CRUD Establecimientos',
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String id;
  final String label;
  final int value;
  final bool loading;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.id,
    required this.label,
    required this.value,
    required this.loading,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      child: Container(
        key: Key(id),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A2A4A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              loading ? '...' : value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiInfoRow extends StatelessWidget {
  final Color dot;
  final String name;
  final String desc;

  const _ApiInfoRow(
      {required this.dot, required this.name, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              Text(desc,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
