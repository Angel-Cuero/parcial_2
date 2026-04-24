import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../models/establecimiento.dart';
import '../services/establecimientos_service.dart';

class EstablecimientoFormScreen extends StatefulWidget {
  /// If null → create mode. If provided → edit mode.
  final Establecimiento? establecimiento;

  const EstablecimientoFormScreen({super.key, this.establecimiento});

  @override
  State<EstablecimientoFormScreen> createState() =>
      _EstablecimientoFormScreenState();
}

class _EstablecimientoFormScreenState
    extends State<EstablecimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  File? _selectedImage;
  bool _submitting = false;
  final _service = EstablecimientosService();
  final _picker = ImagePicker();

  bool get _isEditing => widget.establecimiento != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.establecimiento!;
      _nombreCtrl.text = e.nombre;
      _nitCtrl.text = e.nit;
      _direccionCtrl.text = e.direccion;
      _telefonoCtrl.text = e.telefono;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _direccionCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Seleccionar imagen',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF6C63FF)),
              title: const Text('Galería',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF00D4AA)),
              title: const Text('Cámara',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      if (_isEditing) {
        await _service.update(
          id: widget.establecimiento!.id,
          nombre: _nombreCtrl.text.trim(),
          nit: _nitCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          logo: _selectedImage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Establecimiento actualizado exitosamente')),
          );
          context.pop();
        }
      } else {
        await _service.create(
          nombre: _nombreCtrl.text.trim(),
          nit: _nitCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          logo: _selectedImage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Establecimiento creado exitosamente')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
              expandedHeight: 110,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _isEditing ? 'Editar Establecimiento' : 'Nuevo Establecimiento',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: _isEditing
                        ? AppTheme.accentGradient
                        : AppTheme.primaryGradient,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo picker
                      _buildLogoSection(),
                      const SizedBox(height: 28),
                      // Fields
                      _buildField(
                        controller: _nombreCtrl,
                        label: 'Nombre del establecimiento',
                        icon: Icons.store_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _nitCtrl,
                        label: 'NIT',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _direccionCtrl,
                        label: 'Dirección',
                        icon: Icons.location_on_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _telefonoCtrl,
                        label: 'Teléfono',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isEditing
                                      ? 'Guardar Cambios'
                                      : 'Crear Establecimiento',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    Widget imageWidget;
    if (_selectedImage != null) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(_selectedImage!, fit: BoxFit.cover,
            width: double.infinity, height: 160),
      );
    } else if (_isEditing &&
        widget.establecimiento!.logoUrl != null &&
        widget.establecimiento!.logoUrl!.isNotEmpty) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(widget.establecimiento!.logoUrl!,
            fit: BoxFit.cover, width: double.infinity, height: 160),
      );
    } else {
      imageWidget = Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A4A), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 48, color: Colors.white30),
            const SizedBox(height: 8),
            const Text('Agregar logo',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        imageWidget,
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.photo_camera_outlined),
          label:
              Text(_selectedImage != null ? 'Cambiar imagen' : 'Seleccionar logo'),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
      ),
    );
  }
}
