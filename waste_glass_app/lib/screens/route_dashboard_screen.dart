import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'scan_collect_screen.dart';

class RouteDashboardScreen extends StatefulWidget {
  const RouteDashboardScreen({super.key});

  @override
  State<RouteDashboardScreen> createState() =>
      _RouteDashboardScreenState();
}

class _RouteDashboardScreenState
    extends State<RouteDashboardScreen> {
  List suppliers = [];
  double totalDistance = 0;

  @override
  void initState() {
    super.initState();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final data = await ApiService.getRoute();

    setState(() {
      suppliers = data['suppliers'];
      totalDistance =
          (data['totalDistance'] ?? 0).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final collected =
        suppliers.where((s) => s['status'] == 'Collected').length;

    final remaining = suppliers.length - collected;

    final tripCompleted = remaining == 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF9EF),

      appBar: AppBar(
        title: const Text('Route Dashboard'),
      ),

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
                const Icon(
                  Icons.route,
                  color: Colors.white,
                  size: 50,
                ),

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
                  mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                  children: [
                    _stat(
                      suppliers.length.toString(),
                      "Stops",
                    ),
                    _stat(
                      collected.toString(),
                      "Done",
                    ),
                    _stat(
                      remaining.toString(),
                      "Left",
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  '$totalDistance KM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Total Distance',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                if (tripCompleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text(
                      'Trip Completed 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];

                final String status =
                    supplier['status'];

                final bool isCollected =
                    status == 'Collected';

                Color statusColor;

                if (status == "Collected") {
                  statusColor = Colors.green;
                } else if (status == "Next") {
                  statusColor = Colors.blue;
                } else {
                  statusColor = Colors.orange;
                }

                IconData statusIcon;

                if (status == "Collected") {
                  statusIcon =
                      Icons.check_circle;
                } else if (status == "Next") {
                  statusIcon =
                      Icons.navigation;
                } else {
                  statusIcon =
                      Icons.pending;
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),

                  child: ListTile(
                    onTap: isCollected
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ScanCollectScreen(
                                  expectedSupplier:
                                      supplier[
                                          'supplierCode'],
                                ),
                              ),
                            );

                            loadSuppliers();
                          },

                    leading: CircleAvatar(
                      backgroundColor:
                          statusColor,
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      '${supplier['supplierCode']} - ${supplier['supplierName']}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    trailing: Icon(
                      statusIcon,
                      color: statusColor,
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

  Widget _stat(
    String value,
    String label,
  ) {
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
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}