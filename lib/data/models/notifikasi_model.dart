class NotifikasiModel {
  final int idNotifikasi;
  final int idPengguna;
  final String judul;
  final String pesan;
  final String tipe; // booking, sistem, promo
  final String statusBaca; // belum_dibaca, dibaca
  final DateTime createdAt;

  NotifikasiModel({
    required this.idNotifikasi,
    required this.idPengguna,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.statusBaca,
    required this.createdAt,
  });

  bool get sudahDibaca => statusBaca == 'dibaca';

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiModel(
      idNotifikasi: _parseInt(json['id_notifikasi']),
      idPengguna: _parseInt(json['id_pengguna']),
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? 'sistem',
      statusBaca: json['status_baca'] ?? 'belum_dibaca',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Bikin salinan dengan status_baca sudah 'dibaca', dipakai untuk
  /// update state lokal tanpa perlu fetch ulang seluruh list
  NotifikasiModel markAsRead() {
    return NotifikasiModel(
      idNotifikasi: idNotifikasi,
      idPengguna: idPengguna,
      judul: judul,
      pesan: pesan,
      tipe: tipe,
      statusBaca: 'dibaca',
      createdAt: createdAt,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}