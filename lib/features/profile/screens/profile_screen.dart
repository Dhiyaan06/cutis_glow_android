import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noHpController;
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _noHpController = TextEditingController(text: user?.noHp ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text.isNotEmpty &&
        _passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Konfirmasi password tidak cocok')));
      return;
    }

    final service = ref.read(profileServiceProvider);
    final notifier = ref.read(profileActionProvider.notifier);

    final ok = await notifier.run(() => service.update(
          name: _nameController.text,
          noHp: _noHpController.text,
          password: _passwordController.text.isEmpty ? null : _passwordController.text,
          passwordConfirmation:
              _passwordController.text.isEmpty ? null : _passwordConfirmController.text,
        ));

    if (!mounted) return;
    final state = ref.read(profileActionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profil berhasil diperbarui' : (state.errorMessage ?? 'Gagal menyimpan'))),
    );
    notifier.reset();
    if (ok) {
      _passwordController.clear();
      _passwordConfirmController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final actionState = ref.watch(profileActionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: user?.email ?? '',
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(labelText: 'No. HP'),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              const Text('Ganti Password (opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password baru'),
                obscureText: true,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordConfirmController,
                decoration: const InputDecoration(labelText: 'Konfirmasi password baru'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: actionState.isLoading ? null : _submit,
                child: actionState.isLoading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}