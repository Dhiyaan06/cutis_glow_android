class UserModel {
  final int idPengguna;
  final String name;
  final String email;
  final String role; // admin | dokter | pasien
  final String? noHp;
  final String? statusAktif;

  UserModel({
    required this.idPengguna,
    required this.name,
    required this.email,
    required this.role,
    this.noHp,
    this.statusAktif,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idPengguna: json['id_pengguna'] is String
          ? int.parse(json['id_pengguna'])
          : json['id_pengguna'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'pasien',
      noHp: json['no_hp'],
      statusAktif: json['status_aktif']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengguna': idPengguna,
      'name': name,
      'email': email,
      'role': role,
      'no_hp': noHp,
      'status_aktif': statusAktif,
    };
  }
}