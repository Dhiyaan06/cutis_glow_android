import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/layanan_provider.dart';

class LayananListScreen extends ConsumerWidget {
  const LayananListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layananAsync = ref.watch(layananListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Layanan')),
      body: layananAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  error.toString().replaceAll('ApiException: ', ''),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(layananListProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (layananList) {
          if (layananList.isEmpty) {
            return const Center(child: Text('Belum ada layanan tersedia.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(layananListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: layananList.length,
              itemBuilder: (context, index) {
                final layanan = layananList[index];
                final adaDiskon = layanan.diskon != null && layanan.diskon! > 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layanan.namaLayanan,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (layanan.deskripsi != null && layanan.deskripsi!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(layanan.deskripsi!, style: const TextStyle(color: Colors.grey)),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (adaDiskon) ...[
                              Text(
                                'Rp ${layanan.harga.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'Rp ${layanan.hargaSetelahDiskon.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (adaDiskon) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-${layanan.diskon!.toStringAsFixed(0)}%',
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
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