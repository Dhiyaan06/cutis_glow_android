import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>((ref) => BookingService());

/// List booking -- read-only, pola sama seperti Layanan & Dokter
final bookingListProvider = FutureProvider<List<BookingModel>>((ref) async {
  final service = ref.watch(bookingServiceProvider);
  return service.getAll();
});

/// State terpisah untuk proses create booking (perlu loading/error/success
/// yang lebih rinci daripada FutureProvider biasa, makanya pakai StateNotifier)
class BookingFormState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const BookingFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  final BookingService _service;

  BookingFormNotifier(this._service) : super(const BookingFormState());

  Future<void> submit({
    required int idDokter,
    required int idLayanan,
    required String tanggalBooking,
    required String jamBooking,
    String? catatan,
  }) async {
    state = const BookingFormState(isLoading: true);
    try {
      await _service.create(
        idDokter: idDokter,
        idLayanan: idLayanan,
        tanggalBooking: tanggalBooking,
        jamBooking: jamBooking,
        catatan: catatan,
      );
      state = const BookingFormState(isSuccess: true);
    } on ApiException catch (e) {
      state = BookingFormState(errorMessage: e.message);
    }
  }

  void reset() => state = const BookingFormState();
}

final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier(ref.watch(bookingServiceProvider));
});

/// State untuk aksi admin/dokter: konfirmasi, batal, selesai
class BookingActionState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const BookingActionState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

class BookingActionNotifier extends StateNotifier<BookingActionState> {
  final BookingService _service;
  final Ref _ref;

  BookingActionNotifier(this._service, this._ref) : super(const BookingActionState());

  Future<void> konfirmasi(int idBooking) async {
    state = const BookingActionState(isLoading: true);
    try {
      await _service.konfirmasi(idBooking);
      state = const BookingActionState(isSuccess: true);
      _ref.invalidate(bookingListProvider);
    } on ApiException catch (e) {
      state = BookingActionState(errorMessage: e.message);
    }
  }

  Future<void> batal(int idBooking) async {
    state = const BookingActionState(isLoading: true);
    try {
      await _service.batal(idBooking);
      state = const BookingActionState(isSuccess: true);
      _ref.invalidate(bookingListProvider);
    } on ApiException catch (e) {
      state = BookingActionState(errorMessage: e.message);
    }
  }

  Future<void> selesai({
    required int idBooking,
    required int idLayanan,
    required String tanggalTreatment,
    required int qty,
    String? catatan,
  }) async {
    state = const BookingActionState(isLoading: true);
    try {
      await _service.selesai(
        idBooking: idBooking,
        idLayanan: idLayanan,
        tanggalTreatment: tanggalTreatment,
        qty: qty,
        catatan: catatan,
      );
      state = const BookingActionState(isSuccess: true);
      _ref.invalidate(bookingListProvider);
    } on ApiException catch (e) {
      state = BookingActionState(errorMessage: e.message);
    }
  }

  void reset() => state = const BookingActionState();
}

final bookingActionProvider =
    StateNotifierProvider<BookingActionNotifier, BookingActionState>((ref) {
  return BookingActionNotifier(ref.watch(bookingServiceProvider), ref);
});