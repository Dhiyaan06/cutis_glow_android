import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = DioClient.instance;

  Future<List<BookingModel>> getAll() async {
    try {
      final response = await _dio.get(ApiEndpoints.bookings);
      final List data = response.data['data'];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal memuat data booking.');
    }
  }

  Future<BookingModel> create({
    required int idDokter,
    required int idLayanan,
    required String tanggalBooking, // format: yyyy-MM-dd
    required String jamBooking, // format: HH:mm
    String? catatan,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.bookings, data: {
        'id_dokter': idDokter,
        'id_layanan': idLayanan,
        'tanggal_booking': tanggalBooking,
        'jam_booking': jamBooking,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      });
      return BookingModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal membuat booking.');
    }
  }

  Future<void> konfirmasi(int idBooking) async {
    try {
      await _dio.post(ApiEndpoints.bookingKonfirmasi(idBooking));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal mengonfirmasi booking.');
    }
  }

  Future<void> batal(int idBooking) async {
    try {
      await _dio.post(ApiEndpoints.bookingBatal(idBooking));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal membatalkan booking.');
    }
  }

  /// Selesaikan booking + catat riwayat treatment yang diberikan
  Future<void> selesai({
    required int idBooking,
    required int idLayanan,
    required String tanggalTreatment, // format: yyyy-MM-dd
    required int qty,
    String? catatan,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.bookingSelesai(idBooking),
        data: {
          'id_layanan': idLayanan,
          'tanggal_treatment': tanggalTreatment,
          'qty': qty,
          if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
        },
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(message: 'Gagal menyelesaikan booking.');
    }
  }
}