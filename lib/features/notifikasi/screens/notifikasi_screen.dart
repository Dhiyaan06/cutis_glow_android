import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notifikasi_model.dart';
import '../providers/notifikasi_provider.dart';

class NotifikasiScreen extends ConsumerWidget {
  const NotifikasiScreen({super.key});

  IconData _tipeIcon(String tipe) {
    switch (tipe) {
      case 'booking':
        return Icons.calendar_month;
      case 'promo':
        return Icons.local_offer;
      default:
        return Icons.info_outline;
    }
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notifikasiProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: notifState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString().replaceAll('ApiException: ', '')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(notifikasiProvider.notifier).load(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (notifList) {
          if (notifList.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi.'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(notifikasiProvider.notifier).load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final NotifikasiModel notif = notifList[index];
                return Card(
                  color: notif.sudahDibaca ? null : Colors.deepPurple.withValues(alpha: 0.06),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notif.sudahDibaca
                          ? Colors.grey.shade300
                          : Theme.of(context).colorScheme.primary,
                      child: Icon(
                        _tipeIcon(notif.tipe),
                        color: notif.sudahDibaca ? Colors.grey.shade700 : Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.judul,
                      style: TextStyle(
                        fontWeight: notif.sudahDibaca ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.pesan),
                        const SizedBox(height: 4),
                        Text(
                          _formatTanggal(notif.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: notif.sudahDibaca
                        ? null
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                    onTap: notif.sudahDibaca
                        ? null
                        : () => ref.read(notifikasiProvider.notifier).markAsRead(notif.idNotifikasi),
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