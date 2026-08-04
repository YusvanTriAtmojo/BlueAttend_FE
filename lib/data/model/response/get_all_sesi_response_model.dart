import 'dart:convert';

import 'package:blueattend/data/model/response/get_all_ble_response_model.dart';

class GetAllSesiResponseModel {
  final String message;
  final int statusCode;
  final List<Sesi> data;

  GetAllSesiResponseModel({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory GetAllSesiResponseModel.fromRawJson(String str) =>
      GetAllSesiResponseModel.fromJson(json.decode(str));

  factory GetAllSesiResponseModel.fromJson(Map<String, dynamic> json) =>
      GetAllSesiResponseModel(
        message: json["message"],
        statusCode: json["status_code"],
        data: List<Sesi>.from(json["data"].map((x) => Sesi.fromJson(x))),
      );
}

class Sesi {
  final int id;
  final String namaEvent;
  final DateTime waktuMulai;
  final DateTime tenggatWaktu;
  final String token;
  final String area;
  final List<Ble> ble;

  Sesi({
    required this.id,
    required this.namaEvent,
    required this.waktuMulai,
    required this.tenggatWaktu,
    required this.token,
    required this.area,
    required this.ble,
  });

  factory Sesi.fromJson(Map<String, dynamic> json) => Sesi(
    id: json["id"],
    namaEvent: json["nama_event"] ?? "",
    waktuMulai:json["waktu_mulai"] != null
            ? DateTime.parse(json["waktu_mulai"])
            : DateTime.now(),
    tenggatWaktu:json["tenggat_waktu"] != null
            ? DateTime.parse(json["tenggat_waktu"])
            : DateTime.now(),
    token: json["token"] ?? "",
    area: json["area"] ?? "",
    ble:json["ble"] != null
            ? List<Ble>.from(json["ble"].map((x) => Ble.fromJson(x)))
            : [],
  );
}
