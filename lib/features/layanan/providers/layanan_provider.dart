import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/layanan_model.dart';
import '../../../data/services/layanan_service.dart';
import '../../../shared/providers/crud_action_state.dart';

final layananServiceProvider = Provider<LayananService>((ref) => LayananService());

/// FutureProvider otomatis handle loading/error/data state -- cocok untuk
/// data read-only sederhana seperti list layanan (tidak perlu StateNotifier).
final layananListProvider = FutureProvider<List<LayananModel>>((ref) async {
  final service = ref.watch(layananServiceProvider);
  return service.getAll();
});

/// [Admin] Provider aksi create/update/delete layanan.
/// Setelah sukses, otomatis refresh layananListProvider.
final layananActionProvider =
    StateNotifierProvider.autoDispose<CrudActionNotifier, CrudActionState>((ref) {
  return CrudActionNotifier(ref, [layananListProvider]);
});