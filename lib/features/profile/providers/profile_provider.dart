import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/profile_service.dart';
import '../../../shared/providers/crud_action_state.dart';

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

final profileActionProvider =
    StateNotifierProvider.autoDispose<CrudActionNotifier, CrudActionState>((ref) {
  return CrudActionNotifier(ref, []); // tidak ada list provider lain yang perlu di-refresh
});