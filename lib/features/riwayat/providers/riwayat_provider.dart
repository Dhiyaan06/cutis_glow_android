import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/riwayat_model.dart';
import '../../../data/services/riwayat_service.dart';

final riwayatServiceProvider = Provider<RiwayatService>((ref) => RiwayatService());

/// List riwayat layanan -- read-only, backend sudah filter otomatis
/// berdasarkan role (pasien lihat miliknya, admin/dokter lihat semua/relevan)
final riwayatListProvider = FutureProvider<List<RiwayatModel>>((ref) async {
  final service = ref.watch(riwayatServiceProvider);
  return service.getAll();
});