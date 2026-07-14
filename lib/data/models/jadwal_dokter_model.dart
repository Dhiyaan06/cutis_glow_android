class JadwalDokterModel {
  final int idJadwal;
  final int idDokter;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  JadwalDokterModel({
    required this.idJadwal,
    required this.idDokter,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory JadwalDokterModel.fromJson(Map<String, dynamic> json) {
    return JadwalDokterModel(
      idJadwal: json['id_jadwal'] is String
          ? int.parse(json['id_jadwal'])
          : json['id_jadwal'] as int,
      idDokter: json['id_dokter'] is String
          ? int.parse(json['id_dokter'])
          : json['id_dokter'] as int,
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
    );
  }
}