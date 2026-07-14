import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../layanan/screens/layanan_list_screen.dart';
import '../../dokter/screens/dokter_list_screen.dart';
import '../../booking/screens/booking_list_screen.dart';
class DashboardPasienScreen extends ConsumerWidget {
  const DashboardPasienScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    final menuItems = [
      _MenuItem(
        icon: Icons.medical_services,
        label: 'Layanan',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LayananListScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.person_4,
        label: 'Dokter',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DokterListScreen()),
        ),
      ),
     _MenuItem(
        icon: Icons.calendar_month,
        label: 'Booking Saya',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookingListScreen()),
        ),
      ),
      _MenuItem(icon: Icons.history, label: 'Riwayat Layanan', onTap: () {}),
      _MenuItem(icon: Icons.notifications, label: 'Notifikasi', onTap: () {}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutis Glow - Pasien'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.name ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Pasien', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: menuItems.map((item) => _MenuCard(item: item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;

  const _MenuCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(item.label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}