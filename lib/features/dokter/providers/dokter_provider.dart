import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dokter_model.dart';
import '../../../data/models/jadwal_dokter_model.dart';
import '../../../data/services/dokter_service.dart';

final dokterServiceProvider = Provider<DokterService>((ref) => DokterService());

/// State untuk search/filter -- disimpan terpisah biar bisa dipakai ulang
final dokterSearchQueryProvider = StateProvider<String>((ref) => '');
final dokterSpesialisFilterProvider = StateProvider<String?>((ref) => null);

final dokterListProvider = FutureProvider<List<DokterModel>>((ref) async {
  final service = ref.watch(dokterServiceProvider);
  final search = ref.watch(dokterSearchQueryProvider);
  final spesialis = ref.watch(dokterSpesialisFilterProvider);
  return service.getAll(search: search, spesialis: spesialis);
});

/// family provider -- tiap dokter punya jadwal berbeda, di-cache per idDokter
final jadwalDokterProvider =
    FutureProvider.family<List<JadwalDokterModel>, int>((ref, idDokter) async {
  final service = ref.watch(dokterServiceProvider);
  return service.getSchedules(idDokter: idDokter);
});