import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQr extends StatefulWidget {
  final Function(String) deteksi;
  const ScanQr({ required this.deteksi ,super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  bool _isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode / QR')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isScanned) return;

          final barcode = capture.barcodes.first;
          final String? value = barcode.rawValue;

          if (value != null && value.isNotEmpty) {
            _isScanned = true;
            widget.deteksi(value);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}