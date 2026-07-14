import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/riwayat_provider.dart';

class RiwayatScreen extends ConsumerWidget {
  const RiwayatScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'batal':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatRupiah(double value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp$buffer';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatAsync = ref.watch(riwayatListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Layanan')),
      body: riwayatAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString().replaceAll('ApiException: ', '')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(riwayatListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (riwayatList) {
          if (riwayatList.isEmpty) {
            return const Center(child: Text('Belum ada riwayat layanan.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(riwayatListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: riwayatList.length,
              itemBuilder: (context, index) {
                final riwayat = riwayatList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                riwayat.namaLayanan ?? 'Layanan #${riwayat.idLayanan}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(riwayat.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                riwayat.status,
                                style: TextStyle(color: _statusColor(riwayat.status), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Dokter: ${riwayat.namaDokter ?? '#${riwayat.idDokter}'}'),
                        if (riwayat.namaPasien != null)
                          Text('Pasien: ${riwayat.namaPasien}'),
                        Text(
                          '${riwayat.tanggalTreatment.day}/${riwayat.tanggalTreatment.month}/${riwayat.tanggalTreatment.year}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatRupiah(riwayat.harga)} x ${riwayat.qty} = ${_formatRupiah(riwayat.total)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (riwayat.catatan != null && riwayat.catatan!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Catatan: ${riwayat.catatan}', style: const TextStyle(color: Colors.grey)),
                        ],
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