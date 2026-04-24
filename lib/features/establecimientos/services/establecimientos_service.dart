import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/establecimiento.dart';

class EstablecimientosService {
  late final Dio _dio;

  EstablecimientosService() {
    final baseUrl = dotenv.env['PARQUEADERO_BASE_URL'] ??
        'https://parking.visiontic.com.co/api';

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Log every request/response in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint('[DIO] $o'),
        ),
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Unwrap common Laravel response wrappers:
  ///   { "data": [...] }  /  { "establecimientos": [...] }  /  plain [...]
  List<dynamic> _unwrapList(dynamic body) {
    if (body is List) return body;
    if (body is Map) {
      // Try common keys in order
      for (final key in ['data', 'establecimientos', 'items', 'results']) {
        if (body.containsKey(key) && body[key] is List) {
          return body[key] as List<dynamic>;
        }
      }
      // If it looks like a single object, wrap it
      if (body.containsKey('id')) return [body];
    }
    debugPrint('[EstablecimientosService] Unexpected list body: $body');
    return [];
  }

  Map<String, dynamic> _unwrapSingle(dynamic body) {
    if (body is Map) {
      // Unwrap common Laravel single-resource wrappers
      for (final key in ['data', 'establecimiento']) {
        if (body.containsKey(key) && body[key] is Map) {
          return Map<String, dynamic>.from(body[key] as Map);
        }
      }
      return Map<String, dynamic>.from(body);
    }
    throw FormatException('Unexpected response format: $body');
  }

  /// Safe filename extraction that works on both Unix and Windows paths
  String _filename(String path) =>
      path.split(RegExp(r'[/\\]')).last;

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  /// GET /establecimientos — list all
  Future<List<Establecimiento>> getAll() async {
    final response = await _dio.get<dynamic>('/establecimientos');
    final list = _unwrapList(response.data);
    return list
        .map((e) => Establecimiento.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// GET /establecimientos/{id} — get one
  Future<Establecimiento> getById(int id) async {
    final response = await _dio.get<dynamic>('/establecimientos/$id');
    return Establecimiento.fromJson(_unwrapSingle(response.data));
  }

  /// POST /establecimientos — create (multipart/form-data)
  Future<Establecimiento> create({
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    File? logo,
  }) async {
    final fields = <String, dynamic>{
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
    };

    if (logo != null) {
      fields['logo'] = await MultipartFile.fromFile(
        logo.path,
        filename: _filename(logo.path),
      );
    }

    final response = await _dio.post<dynamic>(
      '/establecimientos',
      data: FormData.fromMap(fields),
    );

    // Some Laravel APIs return 201 with the created object; others return a
    // minimal { "message": "ok" }. Handle both gracefully.
    try {
      return Establecimiento.fromJson(_unwrapSingle(response.data));
    } catch (_) {
      // Fallback: fetch the newly created item from the list
      final all = await getAll();
      return all.isNotEmpty
          ? all.last
          : Establecimiento(
              id: 0,
              nombre: nombre,
              nit: nit,
              direccion: direccion,
              telefono: telefono,
            );
    }
  }

  /// POST /establecimiento-update/{id} — editar
  ///
  /// La ruta del backend acepta POST directamente (sin _method spoofing).
  Future<Establecimiento> update({
    required int id,
    required String nombre,
    required String nit,
    required String direccion,
    required String telefono,
    File? logo,
  }) async {
    final fields = <String, dynamic>{
      'nombre': nombre,
      'nit': nit,
      'direccion': direccion,
      'telefono': telefono,
    };

    if (logo != null) {
      fields['logo'] = await MultipartFile.fromFile(
        logo.path,
        filename: _filename(logo.path),
      );
    }

    final response = await _dio.post<dynamic>(
      '/establecimiento-update/$id',
      data: FormData.fromMap(fields),
    );

    try {
      return Establecimiento.fromJson(_unwrapSingle(response.data));
    } catch (_) {
      // Fallback: return a local copy with the updated values
      return Establecimiento(
        id: id,
        nombre: nombre,
        nit: nit,
        direccion: direccion,
        telefono: telefono,
      );
    }
  }

  /// DELETE /establecimientos/{id}
  Future<void> delete(int id) async {
    await _dio.delete<dynamic>('/establecimientos/$id');
  }
}
