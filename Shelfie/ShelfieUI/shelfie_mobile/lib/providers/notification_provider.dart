import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/myNotifications.dart';
import 'base_provider.dart';
import 'package:intl/intl.dart';

class NotificationProvider extends BaseProvider<MyNotifications> {
  NotificationProvider() : super("MyNotifications");

  @override
  MyNotifications fromJson(dynamic json) => MyNotifications.fromJson(json);

  Future<List<MyNotifications>> getUserNotifications(String authHeader) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Notification/user");
    final response = await http.get(uri, headers: createHeaders(authHeader));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['items'];
      return items.map((json) => fromJson(json)).toList();
    }
    throw Exception("Failed to load user notifications");
  }

  Future<void> updateNotification(String authHeader, int id) async {
    final uri = Uri.parse("${BaseProvider.baseUrl}Notification/$id");
    final response = await http.put(
      uri,
      headers: {
        'authorization': authHeader,
        'content-type': 'application/json',
      },
      body: '{"isRead": true}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update notification');
    }
  }
}