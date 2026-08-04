import 'dart:convert';

class SesiRequestModel {
    final String namaEvent;
    final DateTime waktuMulai;
    final DateTime tenggatWaktu;
    final String token;
    final String area;
    final List<String> ble;

    SesiRequestModel({
        required this.namaEvent,
        required this.waktuMulai,
        required this.tenggatWaktu,
        required this.token,
        required this.area,
        required this.ble,
    });
    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        "nama_event": namaEvent,
        "waktu_mulai": waktuMulai.toIso8601String(),
        "tenggat_waktu": tenggatWaktu.toIso8601String(),
        "token": token,
        "area": area,
        "ble": List<dynamic>.from(ble.map((x) => x)),
    };
}
