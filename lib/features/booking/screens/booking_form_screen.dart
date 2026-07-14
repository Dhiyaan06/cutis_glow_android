import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dokter_model.dart';
import '../../../data/models/layanan_model.dart';
import '../../dokter/providers/dokter_provider.dart';
import '../../layanan/providers/layanan_provider.dart';
import '../providers/booking_provider.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  DokterModel? _selectedDokter;
  LayananModel? _selectedLayanan;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _catatanController = TextEditingController();

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (_selectedDokter == null ||
        _selectedLayanan == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data booking terlebih dahulu')),
      );
      return;
    }

    final tanggalFormatted =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final jamFormatted =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    await ref.read(bookingFormProvider.notifier).submit(
          idDokter: _selectedDokter!.idDokter,
          idLayanan: _selectedLayanan!.idLayanan,
          tanggalBooking: tanggalFormatted,
          jamBooking: jamFormatted,
          catatan: _catatanController.text.trim(),
        );

    if (!mounted) return;
    final formState = ref.read(bookingFormProvider);

    if (formState.isSuccess) {
      ref.invalidate(bookingListProvider); // refresh list booking setelah create
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil dibuat')),
      );
      Navigator.of(context).pop();
    } else if (formState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formState.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dokterAsync = ref.watch(dokterListProvider);
    final layananAsync = ref.watch(layananListProvider);
    final formState = ref.watch(bookingFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pilih Dokter', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            dokterAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Gagal memuat dokter: $e'),
              data: (dokterList) => DropdownButtonFormField<DokterModel>(
                initialValue: _selectedDokter,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Pilih dokter'),
                items: dokterList
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.nama)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDokter = value),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Layanan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            layananAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Gagal memuat layanan: $e'),
              data: (layananList) => DropdownButtonFormField<LayananModel>(
                initialValue: _selectedLayanan,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Pilih layanan'),
                items: layananList
                    .map((l) => DropdownMenuItem(value: l, child: Text(l.namaLayanan)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLayanan = value),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tanggal & Jam', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? 'Pilih tanggal'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Jam',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedTime == null
                            ? 'Pilih jam'
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: formState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: formState.isLoading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Buat Booking'),
            ),
          ],
        ),
      ),
    );
  }
}