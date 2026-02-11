import 'dart:convert';
import 'package:http/http.dart' as http;
import 'queue_status_model.dart';

class QueueRepository {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator/macOS
  // Since we are running on macOS desktop app (based on "flutter run -d macos"), localhost is correct.
  final String baseUrl = 'http://localhost:2015';

  Future<Map<String, dynamic>> joinQueue(String businessId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/join_queue?business_id=$businessId&queue_id=$businessId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to join queue: ${response.body}');
    }
  }

  Future<QueueStatus> getQueueStatus(String businessId, {String? userId}) async {
    String url = '$baseUrl/queue_status?business_id=$businessId&queue_id=$businessId';
    if (userId != null) {
      url += '&user_id=$userId';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return QueueStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get status: ${response.statusCode}');
    }
  }

  Future<void> leaveQueue(String businessId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leave_queue?business_id=$businessId&queue_id=$businessId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to leave queue: ${response.body}');
    }
  }
}
