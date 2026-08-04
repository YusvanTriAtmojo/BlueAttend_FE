import 'dart:convert';

class GetAllBleResponseModel {
  final String message;
  final int statusCode;
  final List<Ble> dataBle;

  GetAllBleResponseModel({
    required this.message,
    required this.statusCode,
    required this.dataBle,
  });

  factory GetAllBleResponseModel.fromRawJson(String str) =>
      GetAllBleResponseModel.fromJson(json.decode(str));

  factory GetAllBleResponseModel.fromJson(Map<String, dynamic> json) =>
      GetAllBleResponseModel(
        message: json["message"],
        statusCode: json["status_code"],
        dataBle: List<Ble>.from(
          json["data"].map((x) => Ble.fromJson(x)),
        ),
      );
}

class Ble {
  final int id;
  final String uuid;
  final String namaDevice;

  Ble({
    required this.id,
    required this.uuid,
    required this.namaDevice
  });

  factory Ble.fromRawJson(String str) =>
      Ble.fromJson(json.decode(str));

  factory Ble.fromJson(Map<String, dynamic> json) => Ble(
        id: json["id"],
        uuid: json["uuid"],
        namaDevice: json["nama_device"],
      );

}
