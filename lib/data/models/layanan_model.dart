class LayananModel {
  final int idLayanan;
  final String namaLayanan;
  final String? deskripsi;
  final double harga;
  final double? diskon;

  LayananModel({
    required this.idLayanan,
    required this.namaLayanan,
    this.deskripsi,
    required this.harga,
    this.diskon,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      idLayanan: json['id_layanan'] is String
          ? int.parse(json['id_layanan'])
          : json['id_layanan'] as int,
      namaLayanan: json['nama_layanan'] ?? '',
      deskripsi: json['deskripsi'],
      harga: double.tryParse(json['harga'].toString()) ?? 0,
      diskon: json['diskon'] != null
          ? double.tryParse(json['diskon'].toString())
          : null,
    );
  }

  /// Dipakai saat kirim data create/update ke API (admin).
  Map<String, dynamic> toJson() {
    return {
      'nama_layanan': namaLayanan,
      'deskripsi': deskripsi,
      'harga': harga,
      'diskon': diskon,
    };
  }

  /// Harga setelah dipotong diskon (kalau ada)
  double get hargaSetelahDiskon {
    if (diskon == null || diskon == 0) return harga;
    return harga - (harga * diskon! / 100);
  }
}