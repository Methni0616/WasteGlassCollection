import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlassTrack',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primaryColor: const Color(0xFF6BCB77),
        scaffoldBackgroundColor: const Color(0xFFEFF9EF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6BCB77),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late Future<List<dynamic>> suppliers;

  @override
  void initState() {
    super.initState();
    suppliers = ApiService.getSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: suppliers,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final supplier = data[index];

              final bool collected =
                  supplier['status'] == 'Collected';

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 12),

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(12),

                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        const Color(0xFF6BCB77),

                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    supplier['supplierCode'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  subtitle: Padding(
                    padding:
                        const EdgeInsets.only(top: 6),
                    child: Text(
                      supplier['status'] ?? '',
                      style: TextStyle(
                        color: collected
                            ? Colors.green
                            : Colors.orange,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),

                  trailing: Icon(
                    collected
                        ? Icons.check_circle
                        : Icons.pending,
                    color: collected
                        ? Colors.green
                        : Colors.orange,
                    size: 32,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}