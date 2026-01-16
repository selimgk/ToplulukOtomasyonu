import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/common_app_bar.dart';

import '../database_helper.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanned = true;
        });
        
        try {
          final data = jsonDecode(barcode.rawValue!);
          if (data['type'] == 'ticket' && data['eventId'] != null) {
            final eventId = data['eventId'];
            final event = await DatabaseHelper.instance.readEvent(eventId);
            _showResultDialog(true, 'Bilet Onaylandı', 
              'Etkinlik: ${event.title}\nKişi bu etkinliğe giriş yapabilir.');
          } else {
             _showResultDialog(false, 'Geçersiz QR', 'Bu QR kod bir etkinlik bileti değil.');
          }
        } catch (e) {
          _showResultDialog(false, 'Hata', 'QR kod okunamadı: $e');
        }
        break; // Process only first valid code
      }
    }
  }
  
  void _showResultDialog(bool success, String title, String message) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, 
                 color: success ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                 _isScanned = false; // Reset scan
              });
            },
            child: const Text('Tamam'),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'QR Bilet Tara', showHome: true),
      body: MobileScanner(
        onDetect: _onDetect,
      ),
    );
  }
}
