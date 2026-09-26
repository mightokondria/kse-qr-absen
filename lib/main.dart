import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi KSE QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const ScannerScreen(),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isProcessing = false;

  // URL API Backend VPS Keno / Google Apps Script
  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbwh7r5Dn8thxaA0ndDuN4vxvvnuF0mWZyps1fC0giRynjKiGjSMNTAwLDFEJHZmWWZi/exec";

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isProcessing = true;
        });

        String qrData = barcode.rawValue!;
        await _sendDataToBackend(qrData, "QR_Scan");

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            isProcessing = false;
          });
        }
        break;
      }
    }
  }

  Future<void> _sendDataToBackend(String uidData, String method) async {
    setState(() {
      isProcessing = true;
    });

    try {
      Map<String, dynamic> payload = {
        "uid": uidData,
        "method": method,
        "timestamp": DateTime.now().toIso8601String(),
      };

      // Mengirim request POST ke Google Apps Script / VPS
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Absen Berhasil! (UID: $uidData)"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Gagal Absen: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  // Dialog Popup Input Manual (Mengambang di Tengah Layar)
  void _showManualInputDialog() {
    final TextEditingController uidController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: Colors.deepOrange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Input Manual UID",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Masukkan ID Registrasi Yayasan jika anggota lupa membawa KTA.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: uidController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: "Contoh: KSE26-001",
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          String uid = uidController.text.trim();
                          if (uid.isNotEmpty) {
                            Navigator.pop(context);
                            _sendDataToBackend(uid, "Manual_Input");
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("UID tidak boleh kosong!"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text("Simpan"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi KSE UNS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 1. Kamera Pemindai QR
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: (capture) {
              // Logika pemindaian data QR
              _onDetect(capture);
            },
          ),

          // 2. Bingkai Pemindai di Tengah Layar
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepOrange, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 3. Tombol Melayang (Floating) di Tengah Bawah Layar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _showManualInputDialog,
                icon: const Icon(Icons.edit_note, size: 22),
                label: const Text(
                  "Input UID Manual",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // 4. Indicator Saat Mengirim Data
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            ),
        ],
      ),
    );
  }
}
