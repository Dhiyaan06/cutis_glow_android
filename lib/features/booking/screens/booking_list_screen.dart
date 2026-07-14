import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/booking_provider.dart';
import 'booking_form_screen.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dikonfirmasi':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.orange; // menunggu
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookingFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Buat Booking'),
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString().replaceAll('ApiException: ', '')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookingListProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (bookingList) {
          if (bookingList.isEmpty) {
            return const Center(child: Text('Belum ada booking. Tekan tombol + untuk membuat.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookingListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                final booking = bookingList[index];
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
                            Text(
                              booking.namaLayanan ?? 'Layanan #${booking.idLayanan}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(booking.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                booking.status,
                                style: TextStyle(color: _statusColor(booking.status), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Dokter: ${booking.namaDokter ?? '#${booking.idDokter}'}'),
                        Text(
                          '${booking.tanggalBooking.day}/${booking.tanggalBooking.month}/${booking.tanggalBooking.year} - ${booking.jamBooking}',
                        ),
                        if (booking.catatan != null && booking.catatan!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Catatan: ${booking.catatan}', style: const TextStyle(color: Colors.grey)),
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