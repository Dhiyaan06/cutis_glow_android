import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/dokter_model.dart';
import '../models/jadwal_dokter_model.dart';

class DokterService {
  final Dio _dio = DioClient.instance;

  Future<List<DokterModel>> getAll({String? search, String? spesialis}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.dokter,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (spesialis != null && spesialis.isNotEmpty) 'spesialis': spesialis,
        },
      );
      final List data = response.data['data'];
      return data.map((json) => DokterModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat data dokter.');
    }
  }

  Future<List<JadwalDokterModel>> getSchedules({required int idDokter}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.dokterSchedules,
        queryParameters: {'id_dokter': idDokter},
      );
      final List data = response.data['data'];
      return data.map((json) => JadwalDokterModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat jadwal dokter.');
    }
  }
}