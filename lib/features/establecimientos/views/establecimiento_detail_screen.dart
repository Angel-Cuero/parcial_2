import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/establecimiento.dart';
import '../services/establecimientos_service.dart';

class EstablecimientoDetailScreen extends StatefulWidget {
  final int id;

  const EstablecimientoDetailScreen({super.key, required this.id});

  @override
  State<EstablecimientoDetailScreen> createState() =>
      _EstablecimientoDetailScreenState();
}

class _EstablecimientoDetailScreenState
    extends State<EstablecimientoDetailScreen> {
  final _service = EstablecimientosService();
  Establecimiento? _item;
  bool _loading = true;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final item = await _service.getById(widget.id);
      setState(() {
        _item = item;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Establecimiento',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro que deseas eliminar "${_item?.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.delete(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Establecimiento eliminado exitosamente')),
        );
        context.go('/establecimientos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _item?.nombre ?? 'Detalle',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _buildHeroLogo(),
      ),
      actions: _item == null
          ? []
          : [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await context.push('/establecimientos/${widget.id}/editar',
                      extra: _item);
                  _load();
                },
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                onPressed: _delete,
                tooltip: 'Eliminar',
              ),
            ],
    );
  }

  Widget _buildHeroLogo() {
    if (_item?.logoUrl != null && _item!.logoUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(_item!.logoUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Color(0xCC0D0D1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
      child: Center(
        child: Text(
          _item?.nombre.isNotEmpty == true
              ? _item!.nombre.substring(0, 1).toUpperCase()
              : '?',
          style: const TextStyle(
              fontSize: 72, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 64),
              const SizedBox(height: 16),
              Text(_errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final item = _item!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _DetailCard(
            children: [
              _DetailField(label: 'Nombre', value: item.nombre,
                  icon: Icons.store_outlined),
              _DetailField(label: 'NIT', value: item.nit,
                  icon: Icons.badge_outlined),
              _DetailField(label: 'Dirección', value: item.direccion,
                  icon: Icons.location_on_outlined),
              _DetailField(label: 'Teléfono', value: item.telefono,
                  icon: Icons.phone_outlined),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push(
                        '/establecimientos/${widget.id}/editar',
                        extra: item);
                    _load();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B)),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Reusable detail widgets ─────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: children),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailField(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00D4AA)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
