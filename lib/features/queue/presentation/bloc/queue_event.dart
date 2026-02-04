part of 'queue_bloc.dart';

sealed class QueueEvent extends Equatable {
  const QueueEvent();

  @override
  List<Object> get props => [];
}

class JoinQueue extends QueueEvent {
  final String businessId;
  final String userId;

  const JoinQueue({required this.businessId, required this.userId});

  @override
  List<Object> get props => [businessId, userId];
}

class CreateQueue extends QueueEvent {
  final String businessId;

  const CreateQueue(this.businessId);

  @override
  List<Object> get props => [businessId];
}

class LeaveQueue extends QueueEvent {
  final String? businessId;
  final String? userId;

  const LeaveQueue({this.businessId, this.userId});

  @override
  List<Object> get props => [businessId ?? '', userId ?? ''];
}

class CheckQueue extends QueueEvent {
  final String businessId;

  const CheckQueue(this.businessId);

  @override
  List<Object> get props => [businessId];
}

class PollQueueStatus extends QueueEvent {
  const PollQueueStatus();
}

class StopQueuePolling extends QueueEvent {}

class UpdateQueueStatus extends QueueEvent {
  final QueueStatus status;

  const UpdateQueueStatus(this.status);

  @override
  List<Object> get props => [status];
}
