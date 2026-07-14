import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/layanan_model.dart';
import '../providers/layanan_provider.dart';

/// Layar admin untuk menambah, mengubah, dan menghapus data layanan.
class LayananManageScreen extends ConsumerWidget {
  const LayananManageScreen({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {LayananModel? existing}) async {
    final namaController = TextEditingController(text: existing?.namaLayanan ?? '');
    final deskripsiController = TextEditingController(text: existing?.deskripsi ?? '');
    final hargaController = TextEditingController(text: existing?.harga.toStringAsFixed(0) ?? '');
    final diskonController = TextEditingController(text: existing?.diskon?.toStringAsFixed(0) ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Tambah Layanan' : 'Ubah Layanan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Layanan'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (double.tryParse(v) == null) return 'Harus angka';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: diskonController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Diskon % (opsional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final service = ref.read(layananServiceProvider);
              final notifier = ref.read(layananActionProvider.notifier);

              final ok = await notifier.run(() async {
                if (existing == null) {
                  await service.create(
                    namaLayanan: namaController.text,
                    deskripsi: deskripsiController.text.isEmpty ? null : deskripsiController.text,
                    harga: double.parse(hargaController.text),
                    diskon: diskonController.text.isEmpty ? null : double.tryParse(diskonController.text),
                  );
                } else {
                  await service.update(
                    idLayanan: existing.idLayanan,
                    namaLayanan: namaController.text,
                    deskripsi: deskripsiController.text.isEmpty ? null : deskripsiController.text,
                    harga: double.parse(hargaController.text),
                    diskon: diskonController.text.isEmpty ? null : double.tryParse(diskonController.text),
                  );
                }
              });

              if (!context.mounted) return;
              Navigator.pop(ctx);
              final state = ref.read(layananActionProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Berhasil disimpan' : (state.errorMessage ?? 'Gagal menyimpan'))),
              );
              notifier.reset();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, LayananModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text('Yakin hapus "${item.namaLayanan}"?'),
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

    final notifier = ref.read(layananActionProvider.notifier);
    final ok = await notifier.run(() => ref.read(layananServiceProvider).delete(item.idLayanan));
    if (!context.mounted) return;
    final state = ref.read(layananActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Layanan dihapus' : (state.errorMessage ?? 'Gagal menghapus'))),
    );
    notifier.reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layananAsync = ref.watch(layananListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Layanan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: layananAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString().replaceAll('ApiException: ', ''))),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Belum ada layanan. Tekan + untuk menambah.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(layananListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.namaLayanan),
                    subtitle: Text(
                      'Rp ${item.harga.toStringAsFixed(0)}'
                      '${(item.diskon != null && item.diskon! > 0) ? ' (diskon ${item.diskon!.toStringAsFixed(0)}%)' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openForm(context, ref, existing: item),
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