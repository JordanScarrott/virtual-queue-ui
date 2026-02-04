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
}
