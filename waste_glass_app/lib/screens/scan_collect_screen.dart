import 'package:flutter/material.dart';

import 'trip_report_screen.dart';
import '../services/database_service.dart';
import 'barcode_scanner_page.dart';

class ScanCollectScreen extends StatefulWidget {
  final String expectedSupplier;

  const ScanCollectScreen({super.key, required this.expectedSupplier});

  @override
  State<ScanCollectScreen> createState() => _ScanCollectScreenState();
}

class _ScanCollectScreenState extends State<ScanCollectScreen> {
  final supplierController = TextEditingController();

  final clearController = TextEditingController();

  final coloredController = TextEditingController();

  final conditionController = TextEditingController();

  String scannedSupplier = '';

  bool formUnlocked = false;

  late String expectedSupplier;

  @override
  void initState() {
    super.initState();

    expectedSupplier = widget.expectedSupplier;
  }

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

    await DatabaseService.saveCollection(
      supplierCode: supplierController.text,
      clearKg: double.parse(clearController.text),
      coloredKg: double.parse(coloredController.text),
      condition: conditionController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Collection Saved Locally')));

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TripReportScreen()),
    );
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

                const SizedBox(height: 15),

                Text(
                  'Expected Supplier : $expectedSupplier',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Barcode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BCB77),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerPage(),
                      ),
                    );

                    if (!mounted) return;

                    if (result != null) {
                      if (result == expectedSupplier) {
                        setState(() {
                          scannedSupplier = result;
                          supplierController.text = result;
                          formUnlocked = true;
                        });

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Correct Supplier'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Wrong Supplier! Expected $expectedSupplier',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 15),

                if (scannedSupplier.isNotEmpty)
                  Text(
                    'Scanned : $scannedSupplier',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),

                const SizedBox(height: 15),

                TextField(
                  controller: supplierController,
                  enabled: false,
                  decoration: fieldDecoration("Supplier Code", Icons.person),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: clearController,
                  enabled: formUnlocked,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration("Clear Glass (Kg)", Icons.scale),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: coloredController,
                  enabled: formUnlocked,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration(
                    "Colored Glass (Kg)",
                    Icons.scale,
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: conditionController,
                  enabled: formUnlocked,
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

                    onPressed: formUnlocked
                        ? () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                  'Are you sure you want to save this collection?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await submitCollection();
                            }
                          }
                        : null,
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
