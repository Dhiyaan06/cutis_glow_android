import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notifikasi_model.dart';
import '../../../data/services/notifikasi_service.dart';

final notifikasiServiceProvider = Provider<NotifikasiService>((ref) => NotifikasiService());

class NotifikasiNotifier extends StateNotifier<AsyncValue<List<NotifikasiModel>>> {
  final NotifikasiService _service;

  NotifikasiNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.getAll();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Tandai satu notifikasi sudah dibaca -- update ke server, lalu update
  /// state lokal juga supaya UI langsung berubah tanpa nunggu reload
  Future<void> markAsRead(int idNotifikasi) async {
    final current = state.value;
    if (current == null) return;

    try {
      await _service.markAsRead(idNotifikasi);
      state = AsyncValue.data([
        for (final n in current)
          if (n.idNotifikasi == idNotifikasi) n.markAsRead() else n,
      ]);
    } catch (_) {
      // Kalau gagal, biarkan state lama -- user bisa coba tap lagi
    }
  }
}

final notifikasiProvider =
    StateNotifierProvider<NotifikasiNotifier, AsyncValue<List<NotifikasiModel>>>((ref) {
  return NotifikasiNotifier(ref.watch(notifikasiServiceProvider));
});

/// Jumlah notifikasi belum dibaca -- dipakai buat badge di ikon dashboard
final unreadNotifikasiCountProvider = Provider<int>((ref) {
  final list = ref.watch(notifikasiProvider).value ?? [];
  return list.where((n) => !n.sudahDibaca).length;
});