import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://glasstrack-api-methni-csdphea5b9bfddar.southeastasia-01.azurewebsites.net/api';

  static Future<List<dynamic>> getSuppliers() async {
    final response = await http.get(Uri.parse('$baseUrl/suppliers'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load suppliers');
  }

  static Future<Map<String, dynamic>> getRoute() async {
    final response = await http.get(Uri.parse('$baseUrl/route'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load route');
  }

  static Future<Map<String, dynamic>> getReport() async {
    final response = await http.get(Uri.parse('$baseUrl/report'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load report');
  }
  static Future<void> submitCollection({
  required String supplierCode,
  required double clearKg,
  required double coloredKg,
  required String condition,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/collection'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'supplierCode': supplierCode,
      'clearKg': clearKg,
      'coloredKg': coloredKg,
      'condition': condition,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
}