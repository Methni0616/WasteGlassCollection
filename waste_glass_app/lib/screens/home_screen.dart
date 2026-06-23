import 'package:flutter/material.dart';
import 'scan_collect_screen.dart';
import 'trip_report_screen.dart';
import 'route_dashboard_screen.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> report;

  @override
  void initState() {
    super.initState();
    report = ApiService.getReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF9EF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BCB77),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GlassTrack',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF6BCB77),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.recycling, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'GlassTrack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Smart Waste Glass Collection System',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Dynamic Statistics
            FutureBuilder<Map<String, dynamic>>(
              future: report,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            icon: Icons.people,
                            title: "Suppliers",
                            value: data['totalSuppliers'].toString(),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _statCard(
                            icon: Icons.check_circle,
                            title: "Collected",
                            value: data['collectedSuppliers'].toString(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _statCard(
                      icon: Icons.recycling,
                      title: "Total Glass",
                      value: "${data['totalCollectedKg']} KG",
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 25),

            // View Suppliers
            _menuButton(
              context,
              title: 'View Suppliers',
              icon: Icons.people,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RouteDashboardScreen(),
                  ),
                );

                setState(() {
                  report = ApiService.getReport();
                });
              },
            ),

            const SizedBox(height: 15),

            // Collection Entry
            _menuButton(
              context,
              title: 'Collection Entry',
              icon: Icons.qr_code_scanner,
              onTap: () async {
                final suppliers = await ApiService.getRoute();

                if (!context.mounted) return;

                showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('Select Supplier'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            return _supplierOption(context, suppliers[index]);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 15),

            // Trip Summary
            _menuButton(
              context,
              title: 'Trip Summary',
              icon: Icons.bar_chart,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TripReportScreen()),
                );

                setState(() {
                  report = ApiService.getReport();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _supplierOption(BuildContext context, dynamic supplier) {
    final String supplierCode = supplier['supplierCode'];

    final bool isCollected = supplier['status'] == 'Collected';

    return ListTile(
      leading: Icon(
        isCollected ? Icons.check_circle : Icons.pending,
        color: isCollected ? Colors.green : Colors.orange,
      ),

      title: Text(supplierCode),

      subtitle: Text(isCollected ? 'Already Collected' : 'Pending'),

      onTap: () {
        Navigator.pop(context);

        if (isCollected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$supplierCode already collected'),
              backgroundColor: Colors.orange,
            ),
          );

          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanCollectScreen(expectedSupplier: supplierCode),
          ),
        ).then((_) {
          setState(() {
            report = ApiService.getReport();
          });
        });
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6BCB77), size: 36),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BCB77),
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
      ),
    );
  }
}
