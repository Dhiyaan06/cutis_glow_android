import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class DioClient {
  static Dio? _dio;
  static final _storageService = SecureStorageService();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) {
          handler.next(_mapDioError(error));
        },
      ),
    );

    return dio;
  }

  /// Base URL berbeda tergantung platform:
  /// - Web (Chrome)    -> localhost
  /// - Android Emulator -> 10.0.2.2 (alias host machine dari emulator)
  /// - Production       -> domain asli, diambil dari .env.production
  static String _resolveBaseUrl() {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // Fallback kalau .env belum termuat
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    return 'http://10.0.2.2:8000/api';
  }

  static DioException _mapDioError(DioException error) {
    ApiException apiException;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        apiException = ApiException.timeout();
        break;

      case DioExceptionType.connectionError:
        apiException = ApiException.network();
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 401:
            apiException = ApiException.unauthorized();
            break;
          case 403:
            apiException = ApiException.forbidden();
            break;
          case 404:
            apiException = ApiException.notFound();
            break;
          case 422:
            apiException = ApiException(
              message: (data is Map && data['message'] != null)
                  ? data['message']
                  : 'Data yang dimasukkan tidak valid.',
              statusCode: 422,
              errors: (data is Map && data['errors'] != null)
                  ? Map<String, dynamic>.from(data['errors'])
                  : null,
            );
            break;
          case 500:
            apiException = ApiException.server();
            break;
          default:
            apiException = ApiException(
              message: (data is Map && data['message'] != null)
                  ? data['message']
                  : 'Terjadi kesalahan tidak terduga.',
              statusCode: statusCode,
            );
        }
        break;

      default:
        apiException = ApiException(message: 'Terjadi kesalahan tidak terduga.');
    }

    return error.copyWith(error: apiException);
  }
}