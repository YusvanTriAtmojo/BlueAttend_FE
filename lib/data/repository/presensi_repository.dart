import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:blueattend/data/model/request/presensi/presensi_request_model.dart';
import 'package:blueattend/data/model/response/riwayat_presensi_response_model.dart';
import 'package:blueattend/service/service_http_client.dart';

class PresensiRepository {
  final ServiceHttpClient httpClient;
  PresensiRepository(this.httpClient);
  
  Future<Either<String, String>> createPresensi(
    PresensiRequestModel request,
  ) async {
    try {

      final response = await httpClient.postMultipartWithToken(
        "presensi",
        fields: {
          "id_user": request.idUser,
          "token": request.token,
          "area": request.area,
          "service_uuid": jsonEncode(request.serviceUuid),
          "data": request.data,
          "face_embedding": jsonEncode(request.faceEmbedding),
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return Right(body["message"] ?? "Presensi berhasil");
      }

      return Left(body["message"] ?? "Presensi gagal");
    } catch (e) {
      return _infoPenyimpangan(e);
    }
  }

  Future<Either<String, RiwayatPresensiResponseModel>> cekRiwayatPresensi() async {
    try {
      final response = await httpClient.get("presensi/riwayat");

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final responseData = RiwayatPresensiResponseModel.fromJson(body);
        return Right(responseData);
      } else {
        return Left(body["message"]);
      }
    } catch (e) {
      return _infoPenyimpangan(e);
    }
  }

  Either<String, T> _infoPenyimpangan<T>(Object e) {
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
