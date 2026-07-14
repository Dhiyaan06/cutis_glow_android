class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String currentUser = '/user';

  // Layanan
  static const String layanan = '/layanan';

  // Dokter
  static const String dokter = '/dokter';
  static const String dokterSchedules = '/dokter/schedules';

  // Booking
  static const String bookings = '/bookings';
  static String bookingKonfirmasi(int id) => '/bookings/$id/konfirmasi';
  static String bookingBatal(int id) => '/bookings/$id/batal';
  static String bookingSelesai(int id) => '/bookings/$id/selesai';
  static const String riwayatLayanan = '/riwayat-layanan';

  // Notifikasi
  static const String notifikasi = '/notifikasi';
  static String notifikasiRead(int id) => '/notifikasi/$id/read';
}