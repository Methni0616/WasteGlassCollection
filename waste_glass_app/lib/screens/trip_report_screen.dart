import 'package:flutter/material.dart';
import '../services/api_service.dart';

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

      body: FutureBuilder<Map<String, dynamic>>(
        future: report,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView(
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
            ],
          );
        },
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
