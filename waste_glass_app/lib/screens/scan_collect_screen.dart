import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'trip_report_screen.dart';
import '../services/database_service.dart';

class ScanCollectScreen extends StatefulWidget {
  const ScanCollectScreen({super.key});

  @override
  State<ScanCollectScreen> createState() => _ScanCollectScreenState();
}

class _ScanCollectScreenState extends State<ScanCollectScreen> {
  final supplierController = TextEditingController();

  final clearController = TextEditingController();

  final coloredController = TextEditingController();

  final conditionController = TextEditingController();

  Future<void> submitCollection() async {
    if (supplierController.text.isEmpty ||
        clearController.text.isEmpty ||
        coloredController.text.isEmpty ||
        conditionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));

      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:5297/api/collection'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'supplierCode': supplierController.text,
        'clearKg': double.parse(clearController.text),
        'coloredKg': double.parse(coloredController.text),
        'condition': conditionController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Save to local database
      await DatabaseService.saveCollection(
        supplierCode: supplierController.text,
        clearKg: double.parse(clearController.text),
        coloredKg: double.parse(coloredController.text),
        condition: conditionController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection Saved Successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TripReportScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed')));
    }
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon, color: const Color(0xFF6BCB77)),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9EF),

      appBar: AppBar(title: const Text('Collection Entry')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 8,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const Icon(Icons.recycling, size: 80, color: Color(0xFF6BCB77)),

                const SizedBox(height: 10),

                const Text(
                  "Record Collection",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: supplierController,
                  decoration: fieldDecoration("Supplier Code", Icons.person),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: clearController,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration("Clear Glass (Kg)", Icons.scale),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: coloredController,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration(
                    "Colored Glass (Kg)",
                    Icons.scale,
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: conditionController,
                  decoration: fieldDecoration("Condition", Icons.info),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),

                    label: const Text("Save Collection"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6BCB77),
                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    onPressed: submitCollection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
