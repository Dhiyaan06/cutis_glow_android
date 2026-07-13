import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';

class DashboardDokterScreen extends ConsumerWidget {
  const DashboardDokterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    final menuItems = [
      _MenuItem(icon: Icons.calendar_month, label: 'Jadwal Booking', onTap: () {}),
      _MenuItem(icon: Icons.schedule, label: 'Jadwal Praktek', onTap: () {}),
      _MenuItem(icon: Icons.history, label: 'Riwayat Layanan', onTap: () {}),
      _MenuItem(icon: Icons.notifications, label: 'Notifikasi', onTap: () {}),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutis Glow - Dokter'),
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
              'Halo, Dr. ${user?.name ?? ''}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Dokter', style: TextStyle(color: Colors.grey)),
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