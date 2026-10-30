
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MedicalRecordQrScannerScreen extends StatefulWidget {
  const MedicalRecordQrScannerScreen({super.key});

  @override
  State<MedicalRecordQrScannerScreen> createState() =>
      _MedicalRecordQrScannerScreenState();
}

class _MedicalRecordQrScannerScreenState
    extends State<MedicalRecordQrScannerScreen> {
  bool handled = false;

  void onDetect(BarcodeCapture capture) {
    if (handled) return;

    final value = capture.barcodes
        .firstOrNull
        ?.rawValue
        ?.trim();

    if (value == null || value.isEmpty) return;

    handled = true;

    // Trả QR payload về màn hình gọi scanner.
    // Màn hình gọi sẽ xử lý token/URL và tải hồ sơ.
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR hồ sơ bệnh án')),
      body: MobileScanner(onDetect: onDetect),
    );
  }
}
