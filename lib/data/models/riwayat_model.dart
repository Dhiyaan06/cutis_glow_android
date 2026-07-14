class RiwayatModel {
  final int idRiwayat;
  final int? idBooking;
  final int idPasien;
  final int idDokter;
  final int idLayanan;
  final String? namaDokter;
  final String? namaLayanan;
  final String? namaPasien;
  final DateTime tanggalTreatment;
  final String status; // selesai, batal
  final String? catatan;
  final double harga;
  final int qty;

  RiwayatModel({
    required this.idRiwayat,
    this.idBooking,
    required this.idPasien,
    required this.idDokter,
    required this.idLayanan,
    this.namaDokter,
    this.namaLayanan,
    this.namaPasien,
    required this.tanggalTreatment,
    required this.status,
    this.catatan,
    required this.harga,
    required this.qty,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    return RiwayatModel(
      idRiwayat: _parseInt(json['id_riwayat']),
      idBooking: json['id_booking'] != null ? _parseInt(json['id_booking']) : null,
      idPasien: _parseInt(json['id_pasien']),
      idDokter: _parseInt(json['id_dokter']),
      idLayanan: _parseInt(json['id_layanan']),
      namaDokter: json['dokter']?['nama'] ?? json['nama_dokter'],
      namaLayanan: json['layanan']?['nama_layanan'] ?? json['nama_layanan'],
      namaPasien: json['pasien']?['nama'] ?? json['nama_pasien'],
      tanggalTreatment: DateTime.tryParse(json['tanggal_treatment'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'selesai',
      catatan: json['catatan'],
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      qty: _parseInt(json['qty']),
    );
  }

  /// Total = harga x qty, dipakai untuk ditampilkan di kartu riwayat
  double get total => harga * qty;

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}