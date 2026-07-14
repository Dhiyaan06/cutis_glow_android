class PasienModel {
  final int idPasien;
  final int idPengguna;
  final String name;
  final String email;
  final String? noHp;
  final String? alamat;
  final String? tanggalLahir;
  final String? jenisKelamin; // 'L' | 'P'
  final String? statusAktif;

  PasienModel({
    required this.idPasien,
    required this.idPengguna,
    required this.name,
    required this.email,
    this.noHp,
    this.alamat,
    this.tanggalLahir,
    this.jenisKelamin,
    this.statusAktif,
  });

  factory PasienModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : <String, dynamic>{};
    return PasienModel(
      idPasien: json['id_pasien'] is String ? int.parse(json['id_pasien']) : json['id_pasien'] as int,
      idPengguna: json['id_pengguna'] is String
          ? int.parse(json['id_pengguna'])
          : json['id_pengguna'] as int,
      name: user['name'] ?? json['name'] ?? '',
      email: user['email'] ?? json['email'] ?? '',
      noHp: json['no_hp'],
      alamat: json['alamat'],
      tanggalLahir: json['tanggal_lahir']?.toString(),
      jenisKelamin: json['jenis_kelamin'],
      statusAktif: user['status_aktif']?.toString(),
    );
  }
}