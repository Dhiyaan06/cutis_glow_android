import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/notifikasi_model.dart';

class NotifikasiService {
  final Dio _dio = DioClient.instance;

  Future<List<NotifikasiModel>> getAll() async {
    try {
      final response = await _dio.get(ApiEndpoints.notifikasi);
      final List data = response.data['data'];
      return data.map((json) => NotifikasiModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat notifikasi.');
    }
  }

  Future<void> markAsRead(int idNotifikasi) async {
    try {
      await _dio.post(ApiEndpoints.notifikasiRead(idNotifikasi));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menandai notifikasi dibaca.');
    }
  }
}