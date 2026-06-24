import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  late Future<Map<String, dynamic>> report;

  @override
  void initState() {
    super.initState();
    report = ApiService.getReport();
  }

  Future<void> _refreshReport() async {
    setState(() {
      report = ApiService.getReport();
    });

    await report;
  }

  Future<void> syncToServer() async {
    final collections = await DatabaseService.getCollections();

    try {
      for (final item in collections) {
        await ApiService.submitCollection(
          supplierCode: item['supplierCode'],
          clearKg: item['clearKg'],
          coloredKg: item['coloredKg'],
          condition: item['condition'],
        );
      }

      await DatabaseService.clearCollections();
      final remaining = await DatabaseService.getCollections();
      debugPrint("LOCAL RECORDS: ${remaining.length}");

      if (!mounted) return;

      setState(() {
        report = ApiService.getReport();
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: const Text('All records synced successfully.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                setState(() {
                  report = ApiService.getReport();
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sync Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9EF),

      appBar: AppBar(
        title: const Text('Trip Summary'),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                report = ApiService.getReport();
              });
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshReport,

        child: FutureBuilder<Map<String, dynamic>>(
          future: report,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              );
            }

            if (!snapshot.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            final data = snapshot.data!;

            final suppliers = List.from(data['suppliers'] ?? []);

            suppliers.sort(
              (a, b) => a['supplierCode'].compareTo(b['supplierCode']),
            );

            final allCollected =
                data['collectedSuppliers'] == data['totalSuppliers'];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _reportCard(
                  icon: Icons.people,
                  title: 'Total Suppliers',
                  value: data['totalSuppliers'].toString(),
                ),

                _reportCard(
                  icon: Icons.check_circle,
                  title: 'Collected Suppliers',
                  value: data['collectedSuppliers'].toString(),
                ),

                _reportCard(
                  icon: Icons.circle_outlined,
                  title: 'Clear Glass',
                  value: '${data['totalClearKg']} kg',
                ),

                _reportCard(
                  icon: Icons.recycling,
                  title: 'Colored Glass',
                  value: '${data['totalColoredKg']} kg',
                ),

                _reportCard(
                  icon: Icons.scale,
                  title: 'Total Glass',
                  value: '${data['totalCollectedKg']} kg',
                ),

                _reportCard(
                  icon: Icons.timer,
                  title: 'Trip Duration',
                  value: data['tripDuration'] ?? '25 Minutes',
                ),
                if (allCollected)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.celebration, color: Colors.green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Trip Completed Successfully!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                const SizedBox(height: 20),

                const Text(
                  "Supplier Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ...suppliers.map<Widget>((supplier) {
                  final expected = supplier['expectedQuantity'];

                  final collected = supplier['collectedQuantity'];

                  final shortfall = collected > 0 && collected < expected;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${supplier['supplierCode']} - ${supplier['supplierName']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text('Expected: $expected kg'),

                          Text('Collected: $collected kg'),

                          if (shortfall)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⚠ Below Expected Quantity',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                if (allCollected)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Sync To Server'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BCB77),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: syncToServer,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _reportCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFF6BCB77),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
    );
  }
}
