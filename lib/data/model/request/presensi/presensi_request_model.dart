import 'dart:convert';

class PresensiRequestModel {
  final String idUser;
  final String token;
  final String area;
  final List<String> serviceUuid;
  final String data;
  final List<double> faceEmbedding;

  PresensiRequestModel({
    required this.idUser,
    required this.token,
    required this.area,
    required this.serviceUuid,
    required this.data,
    required this.faceEmbedding,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() {
    return {
      "id_user": idUser,
      "token": token,
      "area": area,
      "service_uuid": serviceUuid,
      "data": data,
      'face_embedding': faceEmbedding,
    };
  }
}