import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AttendanceScanner(),
  ),
);

class AttendanceScanner extends StatefulWidget {
  const AttendanceScanner({super.key});

  @override
  State<AttendanceScanner> createState() => _AttendanceScannerState();
}

class _AttendanceScannerState extends State<AttendanceScanner> {
  final String scriptUrl =
      "https://script.google.com/macros/s/AKfycbz9Mg79xKuSLPFq7dBcJ4laRqYZhjyc6PigKIZh5XBkpURmdfIORXbezVHu_eOhynRO/exec";
  bool isProcessing = false;

  Future<void> sendData(String id) async {
    setState(() => isProcessing = true);
    try {
      final response = await http.post(Uri.parse("$scriptUrl?studentId=$id"));
      _showResult(response.body);
    } catch (e) {
      _showResult("Error connecting to server");
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isProcessing = false);
  }

  void _showResult(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hacktoberfest Scanner")),
      body: isProcessing
          ? const Center(child: CircularProgressIndicator())
          : MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  sendData(barcodes.first.rawValue ?? "");
                }
              },
            ),
    );
  }
}
