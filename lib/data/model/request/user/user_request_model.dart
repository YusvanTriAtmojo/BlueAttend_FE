import 'dart:convert';

class UserRequestModel {
  final String? nama;
  final String? nip;
  final String? email;
  final String? notlp;
  final String? alamat;

  UserRequestModel({
    this.nama,
    this.nip,
    this.email,
    this.notlp,
    this.alamat,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "nama": nama,
        "nip": nip,
        "email": email,
        "notlp": notlp,
        "alamat": alamat,
      };
}