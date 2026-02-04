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
        '/queue/join',
        data: {
          'business_id': businessId,
          'user_id': userId,
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
        '/queue/status/$businessId/$userId',
      );
      return QueueStatusModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get queue status: $e');
    }
  }
}
