class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String currentUser = '/user';

  // Layanan
  static const String layanan = '/layanan';
  static String layananDetail(int id) => '/layanan/$id';

  // Dokter
  static const String dokter = '/dokter';
  static const String dokterSchedules = '/dokter/schedules';
  static String dokterDetail(int id) => '/dokter/$id';

  /// [Dokter] Profil dokter milik akun yang sedang login.
  static const String myDokterProfile = '/me/dokter';

  // Jadwal Dokter (admin)
  static const String jadwalDokter = '/jadwal-dokter';
  static String jadwalDokterDetail(int id) => '/jadwal-dokter/$id';

  // Pasien (admin)
  static const String pasien = '/pasien';
  static String pasienDetail(int id) => '/pasien/$id';

  // Booking
  static const String bookings = '/bookings';
  static String bookingKonfirmasi(int id) => '/bookings/$id/konfirmasi';
  static String bookingBatal(int id) => '/bookings/$id/batal';
  static String bookingSelesai(int id) => '/bookings/$id/selesai';
  static const String riwayatLayanan = '/riwayat-layanan';

  // Notifikasi
  static const String notifikasi = '/notifikasi';
  static String notifikasiRead(int id) => '/notifikasi/$id/read';

  static const String profile = '/profile';

  static const String realtimeUpdates = '/realtime-updates';
}
