import 'dart:async';
import 'dart:convert';
import 'package:dart_nats/dart_nats.dart';
import 'package:red_duck/features/queue/data/models/queue_status_model.dart';
import 'package:red_duck/features/queue/domain/entities/queue_status.dart';

class RealtimeClient {
  static const String defaultNatsUrl = 'nats://localhost:4222';
  final String natsUrl;
  Client? _client;
  final Completer<void> _connected = Completer<void>();

  RealtimeClient({this.natsUrl = defaultNatsUrl});

  /// Establishes a connection to the NATS server.
  Future<void> connect() async {
    if (_client != null) return;

    _client = Client();
    try {
      await _client!.connect(Uri.parse(natsUrl));
      print('Connected to NATS at $natsUrl');
      if (!_connected.isCompleted) {
        _connected.complete();
      }
    } catch (e) {
      print('Failed to connect to NATS: $e');
      _client = null;
      rethrow;
    }
  }

  /// Subscribes to the queue updates for a specific business ID.
  /// Decodes the message payload from JSON and yields [QueueStatus].
  Stream<QueueStatus> subscribeToQueue(String businessId) async* {
    if (!_connected.isCompleted) {
       await _connected.future;
    }

    final client = _client;
    if (client == null) {
      yield* Stream.error('NATS client not connected');
      return;
    }

    final sub = client.sub('queues.$businessId');
    yield* sub.stream.asyncExpand((message) async* {
      try {
        final String payload = message.string;
        if (payload.isEmpty) return;

        final Map<String, dynamic> json = jsonDecode(payload);
        yield QueueStatusModel.fromJson(json);
      } catch (e) {
        print('Error processing NATS message: $e');
        // Log error but don't crash the stream
      }
    });
  }

  /// Closes the connection.
  Future<void> disconnect() async {
    await _client?.close();
    _client = null;
  }
}
