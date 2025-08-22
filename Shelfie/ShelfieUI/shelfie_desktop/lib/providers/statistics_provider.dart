import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/statistics.dart';
import 'base_provider.dart';

class StatisticsProvider extends BaseProvider<Statistics> {
  StatisticsProvider() : super("Statistics");

  @override
  Statistics fromJson(dynamic json) => Statistics.fromJson(json);

  Future<List<Statistics>> statsForUser(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Statistics/user");
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load Statistics");
  }

   Future<Statistics> getAppStatistics(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Statistics/all");
    final response = await http.get(uri, headers: {
      'Authorization': authHeader,
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Statistics.fromJson(data);
    } else {
      throw Exception("Failed to load app statistics");
    }
  }

}

