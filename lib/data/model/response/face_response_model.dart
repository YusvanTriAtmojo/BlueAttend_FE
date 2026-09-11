import 'dart:convert';

class FaceResponseModel {
  final int statusCode;
  final String message;
  final String? fotoProfile;
  final int? embeddingDimension;

  FaceResponseModel({
    required this.statusCode,
    required this.message,
    this.fotoProfile,
    this.embeddingDimension,
  });

  factory FaceResponseModel.fromRawJson(String str) =>
      FaceResponseModel.fromJson(json.decode(str));

  factory FaceResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return FaceResponseModel(
      statusCode: json["status_code"] ?? 0,
      message: json["message"] ?? "",
      fotoProfile: data?["foto_profile"],
      embeddingDimension: data?["embedding"],
    );
  }
}