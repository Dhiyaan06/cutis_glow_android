import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pasien_model.dart';
import '../providers/pasien_provider.dart';
import 'pasien_form_screen.dart';

class PasienManageScreen extends ConsumerWidget {
  const PasienManageScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PasienModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pasien'),
        content: Text('Yakin hapus pasien "${item.name}"? Akun login-nya juga akan terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final notifier = ref.read(pasienActionProvider.notifier);
    final ok = await notifier.run(() => ref.read(pasienServiceProvider).delete(item.idPasien));
    if (!context.mounted) return;
    final state = ref.read(pasienActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Pasien dihapus' : (state.errorMessage ?? 'Gagal menghapus'))),
    );
    notifier.reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pasienAsync = ref.watch(pasienListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Pasien')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PasienFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama/email pasien...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => ref.read(pasienSearchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: pasienAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString().replaceAll('ApiException: ', ''))),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('Belum ada pasien.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(pasienListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(item.name),
                          subtitle: Text('${item.email}\n${item.noHp ?? '-'}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => PasienFormScreen(existing: item)),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, ref, item),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}