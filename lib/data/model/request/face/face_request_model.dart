import 'dart:convert';

class FaceRequestModel {
  final String image;

  FaceRequestModel({
    required this.image,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "image": image,
      };
}