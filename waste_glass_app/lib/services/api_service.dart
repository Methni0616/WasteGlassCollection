import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.91.36.1:5297/api';

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
}
