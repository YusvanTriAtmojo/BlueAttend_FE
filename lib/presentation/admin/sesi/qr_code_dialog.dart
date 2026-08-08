import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrTokenDialog extends StatefulWidget {
  final String token;
  final String event;

  const QrTokenDialog({super.key, required this.token, required this.event});

  @override
  State<QrTokenDialog> createState() => _QrTokenDialogState();
}

class _QrTokenDialogState extends State<QrTokenDialog> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _shareQr() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception("Gagal membuat gambar QR.");
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/token_qr.png");

      await file.writeAsBytes(pngBytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: "Token Presensi ${widget.event}",
        ),
      );
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Gagal membagikan QR\n$e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("QR Token Presensi", style: TextStyle(color: Color(0xFF6C9BD2), fontWeight: FontWeight.bold, fontSize: 20,),  textAlign: TextAlign.center,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.token.isEmpty)
            const Text("Token kosong", style: TextStyle(color: Colors.red))
          else
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: PrettyQrView.data(data: widget.token),
                ),
              ),
            ),

          const SizedBox(height: 10),

          SelectableText( '[${widget.token}]', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6C9BD2), fontWeight: FontWeight.bold),),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF6C9BD2)),),
            ),
            ElevatedButton.icon(
           style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6C9BD2),
            foregroundColor: Colors.white, 
          ),
          onPressed: widget.token.isEmpty ? null : _shareQr,
          icon: const Icon(Icons.share, color: Colors.white,),
          label: const Text("Bagikan"),
        ),
          ],
        ),
      ],
    );
  }
}
