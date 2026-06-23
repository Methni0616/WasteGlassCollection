import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() =>
      _BarcodeScannerPageState();
}

class _BarcodeScannerPageState
    extends State<BarcodeScannerPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        centerTitle: true,
      ),

      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;

          final Barcode? barcode =
              capture.barcodes.isNotEmpty
                  ? capture.barcodes.first
                  : null;

          final String? code =
              barcode?.rawValue;

          if (code != null) {
            scanned = true;

            Navigator.pop(
              context,
              code,
            );
          }
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(
            context,
            'SUP001',
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}