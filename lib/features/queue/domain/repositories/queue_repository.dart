import '../entities/queue_status.dart';

abstract class QueueRepository {
  Future<QueueStatus> joinQueue({required String businessId, required String userId});
  Future<QueueStatus> getQueueStatus({required String businessId, required String userId});
}
