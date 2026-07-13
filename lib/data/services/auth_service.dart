import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.instance;
  final SecureStorageService _storage = SecureStorageService();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String noHp,
    required String alamat,
    required String tanggalLahir, // format: yyyy-MM-dd
    required String jenisKelamin, // 'L' atau 'P'
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'no_hp': noHp,
        'alamat': alamat,
        'tanggal_lahir': tanggalLahir,
        'jenis_kelamin': jenisKelamin,
      });

      final data = response.data;
      final token = data['token'] as String;
      await _storage.saveToken(token);

      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Registrasi gagal.');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      final token = data['token'] as String;
      await _storage.saveToken(token);

      return UserModel.fromJson(data['user']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Login gagal.');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Tetap lanjut hapus token lokal meski request logout ke server gagal
      // (misal token sudah expired di server tapi masih ada di device)
    } finally {
      await _storage.deleteToken();
    }
  }

  /// Dipanggil saat app dibuka, untuk cek apakah ada sesi tersimpan (auto-login)
  Future<UserModel?> getCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(ApiEndpoints.currentUser);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final error = e.error;
      // Token invalid/expired -> hapus token lokal, anggap belum login
      if (error is ApiException && error.statusCode == 401) {
        await _storage.deleteToken();
        return null;
      }
      rethrow;
    }
  }
}