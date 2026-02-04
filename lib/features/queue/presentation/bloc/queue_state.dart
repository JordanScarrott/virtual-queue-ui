part of 'queue_bloc.dart';

sealed class QueueState extends Equatable {
  const QueueState();

  @override
  List<Object> get props => [];
}

final class QueueInitial extends QueueState {}

final class QueueLoading extends QueueState {}

final class QueueJoined extends QueueState {
  final int position;
  final String status;
  final String businessId;
  final String userId;

  const QueueJoined({
    required this.position,
    required this.status,
    required this.businessId,
    required this.userId,
  });

  @override
  List<Object> get props => [position, status, businessId, userId];
}

final class QueueError extends QueueState {
  final String message;

  const QueueError(this.message);

  @override
  List<Object> get props => [message];
}
