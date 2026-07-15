import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> update({
    required String name,
    required String noHp,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final response = await _dio.put(ApiEndpoints.profile, data: {
        'name': name,
        'no_hp': noHp,
        if (password != null && password.isNotEmpty) 'password': password,
        if (password != null && password.isNotEmpty)
          'password_confirmation': passwordConfirmation,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memperbarui profil.');
    }
  }
}