import 'dart:convert';
import 'dart:io';

import 'package:blueattend/data/model/response/face_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';
import 'package:dartz/dartz.dart';

class FaceRepository {
  final ServiceHttpClient httpClient;

  FaceRepository(this.httpClient);

  Future<Either<String, FaceResponseModel>> registerFace({
    required File fotoProfile,
    required List<double> faceEmbedding,
  }) async {
    try {
      final response = await httpClient.postMultipartWithToken(
        'face/register',
        fields: {'face_embedding': jsonEncode(faceEmbedding)},
        files: {'foto_profile': fotoProfile},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = FaceResponseModel.fromJson(responseData);
        return Right(result);
      } else {
        return Left(responseData['message'] ?? 'Gagal mendaftarkan wajah');
      }
    } catch (e) {
      return _infopenyimpangan(e);
    }
  }

  Either<String, T> _infopenyimpangan<T>(Object e) {
    if (e is SocketException) {
      return Left("Tidak ada koneksi internet");
    } else if (e is HttpException) {
      return Left("Kesalahan HTTP: ${e.message}");
    } else if (e is FormatException) {
      return Left("Format respons tidak valid");
    } else {
      return Left("Terjadi kesalahan tak terduga: $e");
    }
  }
}
