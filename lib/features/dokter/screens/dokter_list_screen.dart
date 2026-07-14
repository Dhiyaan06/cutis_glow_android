import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dokter_provider.dart';
import 'dokter_jadwal_screen.dart';

class DokterListScreen extends ConsumerWidget {
  const DokterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dokterAsync = ref.watch(dokterListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dokter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama dokter...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) =>
                  ref.read(dokterSearchQueryProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: dokterAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error.toString().replaceAll('ApiException: ', '')),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(dokterListProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (dokterList) {
                if (dokterList.isEmpty) {
                  return const Center(child: Text('Dokter tidak ditemukan.'));
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(dokterListProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dokterList.length,
                    itemBuilder: (context, index) {
                      final dokter = dokterList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(dokter.nama.isNotEmpty ? dokter.nama[0] : '?'),
                          ),
                          title: Text(dokter.nama),
                          subtitle: Text(dokter.spesialis ?? 'Spesialis tidak tersedia'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DokterJadwalScreen(dokter: dokter),
                            ),
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