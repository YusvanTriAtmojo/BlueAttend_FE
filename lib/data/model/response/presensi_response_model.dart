import 'dart:convert';

class PresensiResponseModel {
  final String message;
  final int statusCode;
  final double? similarity;

  PresensiResponseModel({
    required this.message,
    required this.statusCode,
    this.similarity,
  });

  factory PresensiResponseModel.fromRawJson(String str) =>
      PresensiResponseModel.fromJson(
        json.decode(str),
      );

  factory PresensiResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json["data"];

    return PresensiResponseModel(
      message: json["message"] ?? "",
      statusCode: json["status_code"] ?? 0,
      similarity: data?["similarity"] != null
          ? (data["similarity"] as num).toDouble()
          : null,
    );
  }
}