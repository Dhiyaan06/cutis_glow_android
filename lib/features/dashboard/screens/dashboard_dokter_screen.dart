import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../riwayat/screens/riwayat_screen.dart';
import '../../notifikasi/screens/notifikasi_screen.dart';
import '../../booking/screens/booking_list_screen.dart';
import '../../dokter/providers/dokter_provider.dart';
import '../../dokter/screens/dokter_jadwal_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../realtime/providers/realtime_provider.dart';

class DashboardDokterScreen extends ConsumerWidget {
  const DashboardDokterScreen({super.key});

  Future<void> _openJadwalPraktek(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dokter = await ref.read(dokterServiceProvider).getMyProfile();
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading dialog
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DokterJadwalScreen(dokter: dokter)),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(realtimeListenerProvider);
    final user = ref.watch(authProvider).user;

    final menuItems = [
      _MenuItem(
        icon: Icons.calendar_month,
        label: 'Jadwal Booking',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BookingListScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.schedule,
        label: 'Jadwal Praktek',
        onTap: () => _openJadwalPraktek(context, ref),
      ),
      _MenuItem(
        icon: Icons.history,
        label: 'Riwayat Layanan',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RiwayatScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.notifications,
        label: 'Notifikasi',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cutis Glow - Dokter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
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
