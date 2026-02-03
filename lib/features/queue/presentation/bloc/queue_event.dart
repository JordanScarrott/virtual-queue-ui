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

class PollQueueStatus extends QueueEvent {
  const PollQueueStatus();
}

class StopQueuePolling extends QueueEvent {}
