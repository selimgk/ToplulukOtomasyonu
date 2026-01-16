import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models.dart';
import '../widgets/common_app_bar.dart';
import 'package:intl/intl.dart';

class TicketScreen extends StatelessWidget {
  final Event event;

  const TicketScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Generate JSON data for QR
    final ticketData = {
      'type': 'ticket',
      'eventId': event.id,
      'valid': true,
      // In a real app, include unique Ticket ID or User ID
    };
    final qrData = jsonEncode(ticketData);

    return Scaffold(
      appBar: const CommonAppBar(title: 'Biletin', showHome: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                event.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMM yyyy').format(event.date),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                event.location,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Bu QR kodu etkinlik girişinde okutunuz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
