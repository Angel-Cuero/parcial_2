import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/accidente.dart';

class AccidentesService {
  late final Dio _dio;

  AccidentesService() {
    final baseUrl = dotenv.env['ACCIDENTES_BASE_URL'] ??
        'https://www.datos.gov.co/resource/';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'X-App-Token': '', // public dataset — no token required
        },
      ),
    );
  }

  /// Fetches all accident records with $limit=100000.
  /// Returns raw JSON list so it can be passed to an Isolate for processing.
  Future<List<Map<String, dynamic>>> fetchAllRaw() async {
    final response = await _dio.get<List<dynamic>>(
      'ezt8-5wyj.json',
      queryParameters: {'\$limit': 100000},
    );
    final data = response.data ?? [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  /// Convenience method that parses the raw data into [Accidente] objects.
  Future<List<Accidente>> fetchAll() async {
    final raw = await fetchAllRaw();
    return raw.map(Accidente.fromJson).toList();
  }
}
