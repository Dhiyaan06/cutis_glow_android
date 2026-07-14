import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dokter_model.dart';
import '../providers/dokter_provider.dart';

class DokterJadwalScreen extends ConsumerWidget {
  final DokterModel dokter;

  const DokterJadwalScreen({super.key, required this.dokter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalAsync = ref.watch(jadwalDokterProvider(dokter.idDokter));

    return Scaffold(
      appBar: AppBar(title: Text('Jadwal ${dokter.nama}')),
      body: jadwalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(error.toString().replaceAll('ApiException: ', '')),
        ),
        data: (jadwalList) {
          if (jadwalList.isEmpty) {
            return const Center(child: Text('Belum ada jadwal praktek.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jadwalList.length,
            itemBuilder: (context, index) {
              final jadwal = jadwalList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(jadwal.hari),
                  subtitle: Text('${jadwal.jamMulai} - ${jadwal.jamSelesai}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}