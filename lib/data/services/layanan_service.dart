import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/layanan_model.dart';

class LayananService {
  final Dio _dio = DioClient.instance;

  Future<List<LayananModel>> getAll() async {
    try {
      final response = await _dio.get(ApiEndpoints.layanan);
      final List data = response.data['data'];
      return data.map((json) => LayananModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat data layanan.');
    }
  }
}