import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/booking_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../layanan/providers/layanan_provider.dart';
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
        return Colors.orange; // menunggu / pending
    }
  }

  Future<void> _confirmAndRun(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
    required Future<void> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Lanjut')),
        ],
      ),
    );
    if (confirmed != true) return;

    await action();

    if (!context.mounted) return;
    final actionState = ref.read(bookingActionProvider);
    if (actionState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(actionState.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diperbarui')),
      );
    }
    ref.read(bookingActionProvider.notifier).reset();
  }

  Future<void> _showSelesaiDialog(BuildContext context, WidgetRef ref, BookingModel booking) async {
    final layananAsync = ref.read(layananListProvider);
    final qtyController = TextEditingController(text: '1');
    final catatanController = TextEditingController();
    int? selectedLayananId;
    DateTime tanggalTreatment = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Selesaikan Booking'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    layananAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text('Gagal memuat layanan: $e'),
                      data: (layananList) {
                        return DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Layanan yang diberikan'),
                          items: layananList
                              .map((l) => DropdownMenuItem(value: l.idLayanan, child: Text(l.namaLayanan)))
                              .toList(),
                          onChanged: (val) => setState(() => selectedLayananId = val),
                          validator: (val) => val == null ? 'Pilih layanan' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tanggal Treatment'),
                      subtitle: Text(
                        '${tanggalTreatment.day}/${tanggalTreatment.month}/${tanggalTreatment.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: tanggalTreatment,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => tanggalTreatment = picked);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: catatanController,
                      decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                FilledButton(
                  onPressed: selectedLayananId == null
                      ? null
                      : () async {
                          final qty = int.tryParse(qtyController.text) ?? 1;
                          final tanggalStr =
                              '${tanggalTreatment.year.toString().padLeft(4, '0')}-${tanggalTreatment.month.toString().padLeft(2, '0')}-${tanggalTreatment.day.toString().padLeft(2, '0')}';
                          Navigator.pop(ctx);
                          await ref.read(bookingActionProvider.notifier).selesai(
                                idBooking: booking.idBooking,
                                idLayanan: selectedLayananId!,
                                tanggalTreatment: tanggalStr,
                                qty: qty,
                                catatan: catatanController.text,
                              );
                          if (!context.mounted) return;
                          final actionState = ref.read(bookingActionProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(actionState.errorMessage ?? 'Booking selesai & riwayat tercatat'),
                            ),
                          );
                          ref.read(bookingActionProvider.notifier).reset();
                        },
                  child: const Text('Selesaikan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingListProvider);
    final role = ref.watch(authProvider).user?.role ?? 'pasien';
    final isPasien = role == 'pasien';

    return Scaffold(
      appBar: AppBar(title: Text(isPasien ? 'Booking Saya' : 'Kelola Booking')),
      floatingActionButton: isPasien
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BookingFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Booking'),
            )
          : null,
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
            return Center(
              child: Text(isPasien ? 'Belum ada booking. Tekan tombol + untuk membuat.' : 'Belum ada booking.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookingListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookingList.length,
              itemBuilder: (context, index) {
                final booking = bookingList[index];
                final canAct = !isPasien &&
                    (booking.status == 'pending' || booking.status == 'dikonfirmasi');

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
                        if (!isPasien && booking.namaPasien != null)
                          Text('Pasien: ${booking.namaPasien}'),
                        Text(
                          '${booking.tanggalBooking.day}/${booking.tanggalBooking.month}/${booking.tanggalBooking.year} - ${booking.jamBooking}',
                        ),
                        if (booking.catatan != null && booking.catatan!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('Catatan: ${booking.catatan}', style: const TextStyle(color: Colors.grey)),
                        ],
                        if (canAct) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (booking.status == 'pending')
                                OutlinedButton(
                                  onPressed: () => _confirmAndRun(
                                    context,
                                    ref,
                                    title: 'Konfirmasi Booking',
                                    message: 'Konfirmasi booking ini?',
                                    action: () => ref.read(bookingActionProvider.notifier).konfirmasi(booking.idBooking),
                                  ),
                                  child: const Text('Konfirmasi'),
                                ),
                              if (booking.status == 'dikonfirmasi')
                                FilledButton(
                                  onPressed: () => _showSelesaiDialog(context, ref, booking),
                                  child: const Text('Selesaikan'),
                                ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                onPressed: () => _confirmAndRun(
                                  context,
                                  ref,
                                  title: 'Batalkan Booking',
                                  message: 'Yakin batalkan booking ini?',
                                  action: () => ref.read(bookingActionProvider.notifier).batal(booking.idBooking),
                                ),
                                child: const Text('Batalkan'),
                              ),
                            ],
                          ),
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