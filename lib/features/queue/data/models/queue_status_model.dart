import '../../domain/entities/queue_status.dart';

class QueueStatusModel extends QueueStatus {
  const QueueStatusModel({
    required super.status,
    required super.position,
  });

  factory QueueStatusModel.fromJson(Map<String, dynamic> json) {
    return QueueStatusModel(
      status: json['status'] as String,
      position: (json['position'] as num).toInt(),
    );
  }
}
