class DokterModel {
  final int idDokter;
  final String nama;
  final String? spesialis;
  final String? foto;
  final String? noHp;

  // Field tambahan -- hanya terisi saat diakses lewat endpoint admin
  // (GET /dokter/{id}, atau hasil create/update admin) yang meng-include user.
  final String? email;
  final String? noStr;
  final String? alamat;
  final String? statusAktif;

  DokterModel({
    required this.idDokter,
    required this.nama,
    this.spesialis,
    this.foto,
    this.noHp,
    this.email,
    this.noStr,
    this.alamat,
    this.statusAktif,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    return DokterModel(
      idDokter: json['id_dokter'] is String
          ? int.parse(json['id_dokter'])
          : json['id_dokter'] as int,
      nama: json['nama'] ?? json['name'] ?? '',
      spesialis: json['spesialis'],
      foto: json['foto'],
      noHp: json['no_hp'],
      email: json['email'] ?? user?['email'],
      noStr: json['no_str'],
      alamat: json['alamat'],
      statusAktif: json['status_aktif']?.toString() ?? user?['status_aktif']?.toString(),
    );
  }
}