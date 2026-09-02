import 'dart:convert';

class FaceResponseModel {
  final int statusCode;
  final String message;

  FaceResponseModel({
    required this.statusCode,
    required this.message,
  });

  factory FaceResponseModel.fromRawJson(String str) =>
      FaceResponseModel.fromJson(json.decode(str));

  factory FaceResponseModel.fromJson(Map<String, dynamic> json) {
    return FaceResponseModel(
      statusCode: json["status_code"],
      message: json["message"],
    );
  }
}