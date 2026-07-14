import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/riwayat_model.dart';

class RiwayatService {
  final Dio _dio = DioClient.instance;

  Future<List<RiwayatModel>> getAll() async {
    try {
      final response = await _dio.get(ApiEndpoints.riwayatLayanan);
      final List data = response.data['data'];
      return data.map((json) => RiwayatModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat data riwayat layanan.');
    }
  }
}