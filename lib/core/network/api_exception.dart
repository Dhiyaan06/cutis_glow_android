/// Representasi error API yang terstruktur, dipetakan dari response Laravel.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors; // untuk validation error (422)

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  /// Error khusus tidak ada koneksi internet / timeout
  factory ApiException.network() {
    return ApiException(
      message: 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
    );
  }

  factory ApiException.timeout() {
    return ApiException(
      message: 'Permintaan memakan waktu terlalu lama. Coba lagi.',
    );
  }

  factory ApiException.unauthorized() {
    return ApiException(
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      statusCode: 401,
    );
  }

  factory ApiException.forbidden() {
    return ApiException(
      message: 'Anda tidak memiliki akses untuk melakukan ini.',
      statusCode: 403,
    );
  }

  factory ApiException.notFound() {
    return ApiException(
      message: 'Data tidak ditemukan.',
      statusCode: 404,
    );
  }

  factory ApiException.server() {
    return ApiException(
      message: 'Terjadi kesalahan pada server. Coba lagi nanti.',
      statusCode: 500,
    );
  }

  @override
  String toString() => message;
}