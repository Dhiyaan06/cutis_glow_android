import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dokter_model.dart';
import '../providers/dokter_provider.dart';
import 'dokter_form_screen.dart';

/// Layar admin untuk menambah, mengubah, dan menghapus data dokter.
class DokterManageScreen extends ConsumerWidget {
  const DokterManageScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, DokterModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dokter'),
        content: Text('Yakin hapus dokter "${item.nama}"? Akun login-nya juga akan terhapus.'),
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

    final notifier = ref.read(dokterActionProvider.notifier);
    final ok = await notifier.run(() => ref.read(dokterServiceProvider).delete(item.idDokter));
    if (!context.mounted) return;
    final state = ref.read(dokterActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Dokter dihapus' : (state.errorMessage ?? 'Gagal menghapus'))),
    );
    notifier.reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dokterAsync = ref.watch(dokterListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Dokter')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokterFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: dokterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString().replaceAll('ApiException: ', ''))),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada dokter. Tekan + untuk menambah.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dokterListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_4)),
                    title: Text(item.nama),
                    subtitle: Text(item.spesialis ?? '-'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => DokterFormScreen(existing: item)),
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
    );
  }
}