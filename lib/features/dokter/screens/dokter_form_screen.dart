import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/dokter_model.dart';
import '../../../data/models/jadwal_dokter_model.dart';
import '../providers/dokter_provider.dart';

const _hariOptions = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at", 'Sabtu', 'Minggu'];

/// Form tambah/ubah data dokter (admin). Saat mode edit, juga menampilkan
/// pengelolaan jadwal praktek (tambah/hapus slot hari & jam).
class DokterFormScreen extends ConsumerStatefulWidget {
  final DokterModel? existing;

  const DokterFormScreen({super.key, this.existing});

  @override
  ConsumerState<DokterFormScreen> createState() => _DokterFormScreenState();
}

class _DokterFormScreenState extends ConsumerState<DokterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late final TextEditingController _spesialisController;
  late final TextEditingController _noStrController;
  late final TextEditingController _noHpController;
  late final TextEditingController _alamatController;
  String _statusAktif = 'aktif';

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.nama ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _spesialisController = TextEditingController(text: e?.spesialis ?? '');
    _noStrController = TextEditingController(text: e?.noStr ?? '');
    _noHpController = TextEditingController(text: e?.noHp ?? '');
    _alamatController = TextEditingController(text: e?.alamat ?? '');
    _statusAktif = e?.statusAktif ?? 'aktif';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = ref.read(dokterServiceProvider);
    final notifier = ref.read(dokterActionProvider.notifier);

    final ok = await notifier.run(() async {
      if (!isEdit) {
        await service.create(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          spesialis: _spesialisController.text,
          noStr: _noStrController.text,
          noHp: _noHpController.text,
          alamat: _alamatController.text,
          statusAktif: _statusAktif,
        );
      } else {
        await service.update(
          idDokter: widget.existing!.idDokter,
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text.isEmpty ? null : _passwordController.text,
          spesialis: _spesialisController.text,
          noStr: _noStrController.text,
          noHp: _noHpController.text,
          alamat: _alamatController.text,
          statusAktif: _statusAktif,
        );
      }
    });

    if (!mounted) return;
    final state = ref.read(dokterActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Data dokter tersimpan' : (state.errorMessage ?? 'Gagal menyimpan'))),
    );
    notifier.reset();
    if (ok) Navigator.pop(context);
  }

  Future<void> _openJadwalForm({JadwalDokterModel? existingJadwal}) async {
    String hari = existingJadwal?.hari ?? _hariOptions.first;
    final jamMulaiController = TextEditingController(text: existingJadwal?.jamMulai ?? '');
    final jamSelesaiController = TextEditingController(text: existingJadwal?.jamSelesai ?? '');

    Future<void> pickTime(TextEditingController controller) async {
      final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (picked != null) {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existingJadwal == null ? 'Tambah Jadwal' : 'Ubah Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: hari,
                decoration: const InputDecoration(labelText: 'Hari'),
                items: _hariOptions.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                onChanged: (v) => setState(() => hari = v ?? hari),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jamMulaiController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Jam Mulai (HH:mm)'),
                onTap: () => pickTime(jamMulaiController),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jamSelesaiController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Jam Selesai (HH:mm)'),
                onTap: () => pickTime(jamSelesaiController),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (jamMulaiController.text.isEmpty || jamSelesaiController.text.isEmpty) return;
                final service = ref.read(dokterServiceProvider);
                final notifier = ref.read(jadwalActionProvider.notifier);
                final ok = await notifier.run(() async {
                  if (existingJadwal == null) {
                    await service.createJadwal(
                      idDokter: widget.existing!.idDokter,
                      hari: hari,
                      jamMulai: jamMulaiController.text,
                      jamSelesai: jamSelesaiController.text,
                    );
                  } else {
                    await service.updateJadwal(
                      idJadwal: existingJadwal.idJadwal,
                      hari: hari,
                      jamMulai: jamMulaiController.text,
                      jamSelesai: jamSelesaiController.text,
                    );
                  }
                });
                if (!context.mounted) return;
                Navigator.pop(ctx);
                final state = ref.read(jadwalActionProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Jadwal tersimpan' : (state.errorMessage ?? 'Gagal menyimpan'))),
                );
                notifier.reset();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJadwal(JadwalDokterModel jadwal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Hapus jadwal ${jadwal.hari} ${jadwal.jamMulai}-${jadwal.jamSelesai}?'),
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
    final notifier = ref.read(jadwalActionProvider.notifier);
    await notifier.run(() => ref.read(dokterServiceProvider).deleteJadwal(jadwal.idJadwal));
    notifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(dokterActionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Ubah Dokter' : 'Tambah Dokter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Password baru (kosongkan jika tidak diubah)' : 'Password',
                ),
                obscureText: true,
                validator: (v) {
                  if (!isEdit && (v == null || v.length < 8)) return 'Minimal 8 karakter';
                  if (isEdit && v != null && v.isNotEmpty && v.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _spesialisController,
                decoration: const InputDecoration(labelText: 'Spesialis'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noStrController,
                decoration: const InputDecoration(labelText: 'No. STR'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _statusAktif,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                  DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                ],
                onChanged: (v) => setState(() => _statusAktif = v ?? 'aktif'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: actionState.isLoading ? null : _submit,
                child: actionState.isLoading
                    ? const SizedBox(
                        height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),

              if (isEdit) ...[
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jadwal Praktek', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () => _openJadwalForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Slot'),
                    ),
                  ],
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final jadwalAsync = ref.watch(jadwalDokterProvider(widget.existing!.idDokter));
                    return jadwalAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text(e.toString().replaceAll('ApiException: ', '')),
                      data: (jadwalList) {
                        if (jadwalList.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Belum ada jadwal praktek.'),
                          );
                        }
                        return Column(
                          children: jadwalList
                              .map((j) => Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.schedule),
                                      title: Text(j.hari),
                                      subtitle: Text('${j.jamMulai} - ${j.jamSelesai} (${j.status})'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _openJadwalForm(existingJadwal: j),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteJadwal(j),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}