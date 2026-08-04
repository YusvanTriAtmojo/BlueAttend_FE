import 'dart:convert';

class UserResponseModel {
  final String message;
  final int statusCode;
  final DataUser? data;

  UserResponseModel({
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory UserResponseModel.fromRawJson(String str) =>
      UserResponseModel.fromJson(json.decode(str));

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      UserResponseModel(
        message: json["message"] ?? "",
        statusCode: json["status_code"] ?? 0,
        data: json["data"] != null
            ? DataUser.fromJson(json["data"])
            : null,
      );
}

class DataUser {
  final int id;
  final String nama;
  final String nip;
  final String notlp;
  final String alamat;
  final String email;

  DataUser({
    required this.id,
    required this.nama,
    required this.nip,
    required this.notlp,
    required this.alamat,
    required this.email,
  });

  factory DataUser.fromRawJson(String str) =>
      DataUser.fromJson(json.decode(str));

  factory DataUser.fromJson(Map<String, dynamic> json) => DataUser(
        id: json["id"] ?? 0,
        nama: json["nama"] ?? "",
        nip: json["nip"]?.toString() ?? "",
        notlp: json["notlp"] ?? "",
        alamat: json["alamat"] ?? "",
        email: json["email"] ?? "",
      );
}