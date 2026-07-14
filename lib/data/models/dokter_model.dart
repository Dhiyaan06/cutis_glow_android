class DokterModel {
  final int idDokter;
  final String nama;
  final String? spesialis;
  final String? foto;
  final String? noHp;

  DokterModel({
    required this.idDokter,
    required this.nama,
    this.spesialis,
    this.foto,
    this.noHp,
  });

  factory DokterModel.fromJson(Map<String, dynamic> json) {
    return DokterModel(
      idDokter: json['id_dokter'] is String
          ? int.parse(json['id_dokter'])
          : json['id_dokter'] as int,
      nama: json['nama'] ?? json['name'] ?? '',
      spesialis: json['spesialis'],
      foto: json['foto'],
      noHp: json['no_hp'],
    );
  }
}