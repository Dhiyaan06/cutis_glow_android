import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';

/// State generik untuk aksi create/update/delete di layar-layar admin
/// (Kelola Layanan, Kelola Dokter, Kelola Pasien, Kelola Jadwal).
class CrudActionState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const CrudActionState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

/// Notifier generik: cukup kasih `Future<void> Function()` sebagai aksinya,
/// nanti loading/error/success-nya otomatis di-handle seragam.
class CrudActionNotifier extends StateNotifier<CrudActionState> {
  final Ref _ref;
  final List<ProviderOrFamily> _providersToInvalidate;

  CrudActionNotifier(this._ref, this._providersToInvalidate)
      : super(const CrudActionState());

  Future<bool> run(Future<void> Function() action) async {
    state = const CrudActionState(isLoading: true);
    try {
      await action();
      state = const CrudActionState(isSuccess: true);
      for (final p in _providersToInvalidate) {
        _ref.invalidate(p);
      }
      return true;
    } on ApiException catch (e) {
      state = CrudActionState(errorMessage: e.message);
      return false;
    } catch (e) {
      state = CrudActionState(errorMessage: 'Terjadi kesalahan tak terduga.');
      return false;
    }
  }

  void reset() => state = const CrudActionState();
}