import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/theme/app_theme.dart';
import '../services/establecimientos_service.dart';
import '../models/establecimiento.dart';

class EstablecimientosListScreen extends StatefulWidget {
  const EstablecimientosListScreen({super.key});

  @override
  State<EstablecimientosListScreen> createState() =>
      _EstablecimientosListScreenState();
}

enum _LoadState { loading, success, error }

class _EstablecimientosListScreenState
    extends State<EstablecimientosListScreen> {
  _LoadState _state = _LoadState.loading;
  List<Establecimiento> _establecimientos = [];
  String _errorMsg = '';

  final _service = EstablecimientosService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool retry = true}) async {
    setState(() => _state = _LoadState.loading);
    try {
      final list = await _service.getAll();
      setState(() {
        _establecimientos = list;
        _state = _LoadState.success;
      });
    } on DioException catch (e) {
      // Retry once on timeout / connection error before showing the error UI
      if (retry &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError)) {
        await Future.delayed(const Duration(seconds: 2));
        return _load(retry: false);
      }
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      setState(() {
        _errorMsg = 'Error HTTP $statusCode\n'
            'Mensaje: ${e.message}\n'
            'Respuesta: $responseData';
        _state = _LoadState.error;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _state = _LoadState.error;
      });
    }
  }

  // Mock list for skeleton animation
  List<Establecimiento> get _skeletonItems => List.generate(
        6,
        (i) => const Establecimiento(
          id: 0,
          nombre: 'Nombre del Establecimiento',
          nit: '123.456.789-0',
          direccion: 'Calle 123 # 45-67, Ciudad',
          telefono: '300 000 0000',
        ),
      );

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
                  'Establecimientos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                background: Container(
                  decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
                ),
              ),
            ),
            if (_state == _LoadState.error)
              SliverFillRemaining(child: _buildError())
            else if (_state == _LoadState.success && _establecimientos.isEmpty)
              SliverFillRemaining(child: _buildEmpty())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final isLoading = _state == _LoadState.loading;
                      final items =
                          isLoading ? _skeletonItems : _establecimientos;
                      if (index >= items.length) return null;
                      return Skeletonizer(
                        enabled: isLoading,
                        child: _EstablecimientoCard(
                          item: items[index],
                          onTap: isLoading
                              ? null
                              : () => context.push(
                                  '/establecimientos/${items[index].id}'),
                        ),
                      );
                    },
                    childCount: _state == _LoadState.loading
                        ? _skeletonItems.length
                        : _establecimientos.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_create',
        onPressed: () async {
          await context.push('/establecimientos/nuevo');
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Crear'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_mall_directory_outlined,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin establecimientos',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aún no hay establecimientos registrados.\nPresiona el botón + para agregar uno.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                await context.push('/establecimientos/nuevo');
                _load();
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear primer establecimiento'),
            ),
          ],
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
            const Text('Error al cargar establecimientos',
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
}

class _EstablecimientoCard extends StatelessWidget {
  final Establecimiento item;
  final VoidCallback? onTap;

  const _EstablecimientoCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Logo
              _LogoAvatar(logoUrl: item.logoUrl, nombre: item.nombre),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _InfoRow(icon: Icons.badge_outlined, text: item.nit),
                    _InfoRow(icon: Icons.location_on_outlined, text: item.direccion),
                    _InfoRow(icon: Icons.phone_outlined, text: item.telefono),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white30),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final String nombre;

  const _LogoAvatar({this.logoUrl, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final initials = nombre.isNotEmpty
        ? nombre
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: const Color(0xFF2A2A4A),
        backgroundImage: NetworkImage(logoUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF00D4AA)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
