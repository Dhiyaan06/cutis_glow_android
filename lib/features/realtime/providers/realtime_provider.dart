import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/realtime_service.dart';
import '../../notifikasi/providers/notifikasi_provider.dart';
import '../../booking/providers/booking_provider.dart';


final realtimeServiceProvider = Provider<RealtimeService>((ref) {
  final service = RealtimeService();
  ref.onDispose(service.dispose);
  return service;
});

/// Watch provider ini SEKALI di tiap dashboard (admin/dokter/pasien).
/// Selama widget yang nge-watch masih hidup, koneksi SSE tetap terbuka
/// dan otomatis refresh list notifikasi/booking begitu ada event baru.
final realtimeListenerProvider = Provider.autoDispose<void>((ref) {
  final service = ref.watch(realtimeServiceProvider);
  service.connect();

  final subscription = service.events.listen((event) {
    switch (event.type) {
      case 'notification':
        ref.invalidate(notifikasiProvider);
        break;
      case 'booking_update':
        ref.invalidate(bookingListProvider);
        break;
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    service.disconnect();
  });
});