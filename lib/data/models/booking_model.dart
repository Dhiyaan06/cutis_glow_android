class BookingModel {
  final int idBooking;
  final int? idPasien;
  final int idDokter;
  final int idLayanan;
  final String? namaDokter;
  final String? namaLayanan;
  final String? namaPasien;
  final DateTime tanggalBooking;
  final String jamBooking;
  final String status; // menunggu, dikonfirmasi, selesai, dibatalkan
  final String? catatan;

  BookingModel({
    required this.idBooking,
    this.idPasien,
    required this.idDokter,
    required this.idLayanan,
    this.namaDokter,
    this.namaLayanan,
    this.namaPasien,
    required this.tanggalBooking,
    required this.jamBooking,
    required this.status,
    this.catatan,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      idBooking: _parseInt(json['id_booking']),
      idPasien: json['id_pasien'] != null ? _parseInt(json['id_pasien']) : null,
      idDokter: _parseInt(json['id_dokter']),
      idLayanan: _parseInt(json['id_layanan']),
      namaDokter: json['dokter']?['nama'] ?? json['nama_dokter'],
      namaLayanan: json['layanan']?['nama_layanan'] ?? json['nama_layanan'],
      namaPasien: json['pasien']?['nama'] ?? json['nama_pasien'],
      tanggalBooking: DateTime.tryParse(json['tanggal_booking'] ?? '') ?? DateTime.now(),
      jamBooking: json['jam_booking'] ?? '',
      status: json['status'] ?? 'menunggu',
      catatan: json['catatan'],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}