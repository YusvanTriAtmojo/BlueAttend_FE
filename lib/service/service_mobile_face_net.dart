import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ServiceMobileFaceNet {
  Interpreter? _interpreter;

  // inisialisasi model
  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
  }

  // Fungsi embedding
  Future<List<double>> generateEmbedding(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('MobileFaceNet belum diinisialisasi');
    }

    // membaca gambar
    final Uint8List imageBytes = await imageFile.readAsBytes();

    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Gambar tidak dapat dibaca');
    }

    // mengubah ukuran menjadi 112x112
    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: 112,
      height: 112,
    );

    // input tensor
    final input = List.generate(
      1,
      (_) => List.generate(
        112,
        (y) => List.generate(112, (x) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r.toDouble();
          final g = pixel.g.toDouble();
          final b = pixel.b.toDouble();
          return [(r / 127.5) - 1.0, (g / 127.5) - 1.0, (b / 127.5) - 1.0];
        }),
      ),
    );

    // output tensor
    final output = List.generate(1, (_) => List<double>.filled(192, 0.0));

    // menjalankan model
    _interpreter!.run(input, output);

    // embedding
    final embedding = List<double>.from(output[0]);
    if (embedding.length != 192) {
      throw Exception(
        'Dimensi embedding tidak sesuai: '
        '${embedding.length}',
      );
    }

    // L2 normalisasi
    final normalizedEmbedding = _l2Normalize(embedding);
    return normalizedEmbedding;
  }

  // fungsi L2 normalisasi
  List<double> _l2Normalize(List<double> embedding) {
    double sum = 0.0;
    for (final value in embedding) {
      sum += value * value;
    }

    final norm = math.sqrt(sum);

    if (norm == 0) {
      throw Exception('Embedding tidak valid');
    }
    return embedding.map((value) => value / norm).toList();
  }


  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
