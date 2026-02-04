import '../../../../core/network/dio_client.dart';
import '../../domain/entities/queue_status.dart';
import '../../domain/repositories/queue_repository.dart';
import '../models/queue_status_model.dart';

class QueueRepositoryImpl implements QueueRepository {
  final NetworkClient networkClient;

  QueueRepositoryImpl({required this.networkClient});

  @override
  Future<QueueStatus> joinQueue({required String businessId, required String userId}) async {
    try {
      final response = await networkClient.dio.post(
        '/queues/$businessId/join',
        data: {
          'userID': userId,
        },
      );
      return QueueStatusModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to join queue: $e');
    }
  }

  @override
  Future<QueueStatus> getQueueStatus({required String businessId, required String userId}) async {
    try {
      final response = await networkClient.dio.get(
        '/queues/$businessId/status/$userId',
      );
      return QueueStatusModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get queue status: $e');
    }
  }

  @override
  Future<void> createQueue(String businessId) async {
    try {
      await networkClient.dio.post(
        '/queues/$businessId',
      );
    } catch (e) {
      throw Exception('Failed to create queue: $e');
    }
  }

  @override
  Future<void> leaveQueue({required String businessId, required String userId}) async {
    try {
      await networkClient.dio.post(
        '/queues/$businessId/leave',
        data: {
          'userID': userId,
        },
      );
    } catch (e) {
      throw Exception('Failed to leave queue: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getQueue(String businessId) async {
    try {
      final response = await networkClient.dio.get(
        '/queues/$businessId',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get queue info: $e');
    }
  }
}
