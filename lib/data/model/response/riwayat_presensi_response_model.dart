class RiwayatPresensiResponseModel {
  final String message;
  final int statusCode;
  final List<DataPresensi> data;

  RiwayatPresensiResponseModel({
    required this.message,
    required this.statusCode,
    required this.data,
  });

  factory RiwayatPresensiResponseModel.fromJson(Map<String, dynamic> json) {
    return RiwayatPresensiResponseModel(
      message: json["message"],
      statusCode: json["status_code"],
      data: List<DataPresensi>.from(
        json["data"].map((x) => DataPresensi.fromJson(x)),
      ),
    );
  }
}

class DataPresensi {
  final int id;
  final String event;
  final String tanggal;

  DataPresensi({
    required this.id,
    required this.event,
    required this.tanggal,
  });

  factory DataPresensi.fromJson(Map<String, dynamic> json) {
    return DataPresensi(
      id: json["id"],
      event: json["nama_event"],
      tanggal: json["tanggal"],
    );
  }
}