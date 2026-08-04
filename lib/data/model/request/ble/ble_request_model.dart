import 'dart:convert';

class BleRequestModel {
    final String uuid;
    final String namaDevice;

    BleRequestModel({
        required this.uuid,
        required this.namaDevice,
    });


    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        "uuid": uuid,
        "nama_device": namaDevice,
    };
}
