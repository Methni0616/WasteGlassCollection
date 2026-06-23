import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'scan_collect_screen.dart';

class RouteDashboardScreen extends StatefulWidget {
  const RouteDashboardScreen({super.key});

  @override
  State<RouteDashboardScreen> createState() => _RouteDashboardScreenState();
}

class _RouteDashboardScreenState extends State<RouteDashboardScreen> {
  List suppliers = [];

  @override
  void initState() {
    super.initState();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final data = await ApiService.getRoute();

    setState(() {
      suppliers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final collected = suppliers.where((s) => s['status'] == 'Collected').length;

    final remaining = suppliers.length - collected;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF9EF),

      appBar: AppBar(title: const Text('Route Dashboard')),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6BCB77),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.route, color: Colors.white, size: 50),

                const SizedBox(height: 10),

                const Text(
                  "Today's Route",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat(suppliers.length.toString(), "Stops"),
                    _stat(collected.toString(), "Done"),
                    _stat(remaining.toString(), "Left"),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];

                final bool isCollected = supplier['status'] == 'Collected';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),

                  child: ListTile(
                    onTap: isCollected
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScanCollectScreen(
                                  expectedSupplier: supplier['supplierCode'],
                                ),
                              ),
                            );
                          },

                    leading: CircleAvatar(
                      backgroundColor: isCollected
                          ? Colors.green
                          : Colors.orange,
                      child: Icon(
                        isCollected ? Icons.check : Icons.route,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      supplier['supplierCode'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(supplier['status'] ?? ''),

                    trailing: Icon(
                      isCollected ? Icons.check_circle : Icons.pending,
                      color: isCollected ? Colors.green : Colors.orange,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
