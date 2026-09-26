import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter/services.dart';

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi KSE UNS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. HALAMAN UTAMA (2 TOMBOL BESAR)
// -----------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Absensi KSE UNS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              size: 80,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 12),
            const Text(
              "Sistem Presensi Kegiatan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Pilih metode pencatatan kehadiran beswan",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // TOMBOL 1: SCAN QR
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text(
                'Scan QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // TOMBOL 2: INPUT MANUAL UID
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepOrange,
                side: const BorderSide(color: Colors.deepOrange, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _showManualInputDialog(context);
              },
              icon: const Icon(Icons.keyboard_alt_outlined, size: 28),
              label: const Text(
                'Input Manual UID',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG POPUP INPUT MANUAL (Floating di Tengah)
  void _showManualInputDialog(BuildContext context) {
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
                  "Masukkan ID Registrasi Yayasan jika anggota tidak membawa QR.",
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
                    hintText: "Contoh: KSE-001",
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
                            sendDataToBackend(context, uid, "Manual_Input");
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
}

// -----------------------------------------------------------------------------
// 2. HALAMAN SCANNER KAMERA
// -----------------------------------------------------------------------------
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isProcessing = true;
        });

        String qrData = barcode.rawValue!.trim();
        await sendDataToBackend(context, qrData, "QR_Scan");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code'), elevation: 0),
      body: Stack(
        children: [
          MobileScanner(fit: BoxFit.cover, onDetect: _onDetect),
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

// -----------------------------------------------------------------------------
// 3. FUNGSI KIRIM DATA KE GOOGLE APPS SCRIPT
// -----------------------------------------------------------------------------
Future<void> sendDataToBackend(
  BuildContext context,
  String uidData,
  String method,
) async {
  // Ganti dengan Web App URL Google Apps Script milikmu
  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbwh7r5Dn8thxaA0ndDuN4vxvvnuF0mWZyps1fC0giRynjKiGjSMNTAwLDFEJHZmWWZi/exec";

  try {
    Map<String, dynamic> payload = {
      "uid": uidData,
      "method": method,
      "timestamp": DateTime.now().toIso8601String(),
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 302) {
      HapticFeedback.vibrate();
      if (context.mounted) {
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
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Gagal Absen: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
