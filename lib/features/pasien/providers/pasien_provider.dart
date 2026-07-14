import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pasien_model.dart';
import '../../../data/services/pasien_service.dart';
import '../../../shared/providers/crud_action_state.dart';

final pasienServiceProvider = Provider<PasienService>((ref) => PasienService());

final pasienSearchQueryProvider = StateProvider<String>((ref) => '');

final pasienListProvider = FutureProvider<List<PasienModel>>((ref) async {
  final service = ref.watch(pasienServiceProvider);
  final search = ref.watch(pasienSearchQueryProvider);
  return service.getAll(search: search);
});

final pasienActionProvider =
    StateNotifierProvider.autoDispose<CrudActionNotifier, CrudActionState>((ref) {
  return CrudActionNotifier(ref, [pasienListProvider]);
});