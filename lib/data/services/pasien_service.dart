import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/pasien_model.dart';

/// [Admin] Service untuk kelola data pasien.
class PasienService {
  final Dio _dio = DioClient.instance;

  Future<List<PasienModel>> getAll({String? search}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.pasien,
        queryParameters: {if (search != null && search.isNotEmpty) 'search': search},
      );
      final List data = response.data['data'];
      return data.map((json) => PasienModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat data pasien.');
    }
  }

  Future<PasienModel> create({
    required String name,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
    required String tanggalLahir, // yyyy-MM-dd
    required String jenisKelamin, // L | P
    String statusAktif = 'aktif',
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.pasien, data: {
        'name': name,
        'email': email,
        'password': password,
        'no_hp': noHp,
        'alamat': alamat,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
        'status_aktif': statusAktif,
      });
      return PasienModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menambah pasien.');
    }
  }

  Future<PasienModel> update({
    required int idPasien,
    required String name,
    required String email,
    String? password,
    required String noHp,
    required String alamat,
    required String tanggalLahir,
    required String jenisKelamin,
    String? statusAktif,
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.pasienDetail(idPasien), data: {
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        'no_hp': noHp,
        'alamat': alamat,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
        if (statusAktif != null) 'status_aktif': statusAktif,
      });
      return PasienModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal mengubah data pasien.');
    }
  }

  Future<void> delete(int idPasien) async {
    try {
      await _dio.delete(ApiEndpoints.pasienDetail(idPasien));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menghapus pasien.');
    }
  }
}