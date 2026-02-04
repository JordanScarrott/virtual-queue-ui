import 'package:equatable/equatable.dart';

class QueueStatus extends Equatable {
  final String status;
  final int position;

  const QueueStatus({
    required this.status,
    required this.position,
  });

  @override
  List<Object?> get props => [status, position];
}
