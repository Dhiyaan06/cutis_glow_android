import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pasien_model.dart';
import '../providers/pasien_provider.dart';

class PasienFormScreen extends ConsumerStatefulWidget {
  final PasienModel? existing;

  const PasienFormScreen({super.key, this.existing});

  @override
  ConsumerState<PasienFormScreen> createState() => _PasienFormScreenState();
}

class _PasienFormScreenState extends ConsumerState<PasienFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  late final TextEditingController _noHpController;
  late final TextEditingController _alamatController;
  DateTime? _tanggalLahir;
  String _jenisKelamin = 'L';
  String _statusAktif = 'aktif';

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _emailController = TextEditingController(text: e?.email ?? '');
    _noHpController = TextEditingController(text: e?.noHp ?? '');
    _alamatController = TextEditingController(text: e?.alamat ?? '');
    _jenisKelamin = e?.jenisKelamin ?? 'L';
    _statusAktif = e?.statusAktif ?? 'aktif';
    if (e?.tanggalLahir != null) {
      _tanggalLahir = DateTime.tryParse(e!.tanggalLahir!);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir wajib diisi')),
      );
      return;
    }

    final tanggalStr =
        '${_tanggalLahir!.year.toString().padLeft(4, '0')}-${_tanggalLahir!.month.toString().padLeft(2, '0')}-${_tanggalLahir!.day.toString().padLeft(2, '0')}';

    final service = ref.read(pasienServiceProvider);
    final notifier = ref.read(pasienActionProvider.notifier);

    final ok = await notifier.run(() async {
      if (!isEdit) {
        await service.create(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          noHp: _noHpController.text,
          alamat: _alamatController.text,
          tanggalLahir: tanggalStr,
          jenisKelamin: _jenisKelamin,
          statusAktif: _statusAktif,
        );
      } else {
        await service.update(
          idPasien: widget.existing!.idPasien,
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text.isEmpty ? null : _passwordController.text,
          noHp: _noHpController.text,
          alamat: _alamatController.text,
          tanggalLahir: tanggalStr,
          jenisKelamin: _jenisKelamin,
          statusAktif: _statusAktif,
        );
      }
    });

    if (!mounted) return;
    final state = ref.read(pasienActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Data pasien tersimpan' : (state.errorMessage ?? 'Gagal menyimpan'))),
    );
    notifier.reset();
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(pasienActionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Ubah Pasien' : 'Tambah Pasien')),
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Lahir'),
                subtitle: Text(_tanggalLahir == null
                    ? 'Belum dipilih'
                    : '${_tanggalLahir!.day}/${_tanggalLahir!.month}/${_tanggalLahir!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggalLahir ?? DateTime(2000, 1, 1),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _tanggalLahir = picked);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _jenisKelamin,
                decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => _jenisKelamin = v ?? 'L'),
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
            ],
          ),
        ),
      ),
    );
  }
}