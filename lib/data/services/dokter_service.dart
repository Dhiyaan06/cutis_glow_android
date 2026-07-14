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

  // ==================== [Admin] CRUD Dokter ====================

  /// Tambah dokter baru. Otomatis membuat akun login (User) dengan role dokter.
  Future<DokterModel> create({
    required String name,
    required String email,
    required String password,
    required String spesialis,
    required String noStr,
    required String noHp,
    required String alamat,
    String statusAktif = 'aktif',
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.dokter, data: {
        'name': name,
        'email': email,
        'password': password,
        'spesialis': spesialis,
        'no_str': noStr,
        'no_hp': noHp,
        'alamat': alamat,
        'status_aktif': statusAktif,
      });
      return DokterModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menambah dokter.');
    }
  }

  /// Update data dokter. `password` opsional -- isi hanya jika ingin diganti.
  Future<DokterModel> update({
    required int idDokter,
    required String name,
    required String email,
    String? password,
    required String spesialis,
    required String noStr,
    required String noHp,
    required String alamat,
    String? statusAktif,
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.dokterDetail(idDokter), data: {
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        'spesialis': spesialis,
        'no_str': noStr,
        'no_hp': noHp,
        'alamat': alamat,
        if (statusAktif != null) 'status_aktif': statusAktif,
      });
      return DokterModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal mengubah data dokter.');
    }
  }

  Future<void> delete(int idDokter) async {
    try {
      await _dio.delete(ApiEndpoints.dokterDetail(idDokter));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menghapus dokter.');
    }
  }

  // ==================== [Admin] CRUD Jadwal Praktek ====================

  Future<JadwalDokterModel> createJadwal({
    required int idDokter,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
    String status = 'aktif',
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.jadwalDokter, data: {
        'id_dokter': idDokter,
        'hari': hari,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'status': status,
      });
      return JadwalDokterModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menambah jadwal.');
    }
  }

  Future<JadwalDokterModel> updateJadwal({
    required int idJadwal,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
    String status = 'aktif',
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.jadwalDokterDetail(idJadwal), data: {
        'hari': hari,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'status': status,
      });
      return JadwalDokterModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal mengubah jadwal.');
    }
  }

  Future<void> deleteJadwal(int idJadwal) async {
    try {
      await _dio.delete(ApiEndpoints.jadwalDokterDetail(idJadwal));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menghapus jadwal.');
    }
  }
}