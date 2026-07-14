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

  /// [Admin] Tambah layanan baru.
  Future<LayananModel> create({
    required String namaLayanan,
    String? deskripsi,
    required double harga,
    double? diskon,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.layanan, data: {
        'nama_layanan': namaLayanan,
        'deskripsi': deskripsi,
        'harga': harga,
        if (diskon != null) 'diskon': diskon,
      });
      return LayananModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menambah layanan.');
    }
  }

  /// [Admin] Update layanan.
  Future<LayananModel> update({
    required int idLayanan,
    required String namaLayanan,
    String? deskripsi,
    required double harga,
    double? diskon,
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.layananDetail(idLayanan), data: {
        'nama_layanan': namaLayanan,
        'deskripsi': deskripsi,
        'harga': harga,
        if (diskon != null) 'diskon': diskon,
      });
      return LayananModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal mengubah layanan.');
    }
  }

  /// [Admin] Hapus layanan.
  Future<void> delete(int idLayanan) async {
    try {
      await _dio.delete(ApiEndpoints.layananDetail(idLayanan));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menghapus layanan.');
    }
  }
}