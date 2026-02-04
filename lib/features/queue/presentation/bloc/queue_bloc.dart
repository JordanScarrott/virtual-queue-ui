import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/queue_repository.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository repository;
  Timer? _pollingTimer;

  QueueBloc({required this.repository}) : super(QueueInitial()) {
    on<JoinQueue>(_onJoinQueue);
    on<PollQueueStatus>(_onPollQueueStatus);
    on<StopQueuePolling>(_onStopQueuePolling);
  }

  Future<void> _onJoinQueue(JoinQueue event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    try {
      final result = await repository.joinQueue(
        businessId: event.businessId,
        userId: event.userId,
      );
      emit(QueueJoined(
        position: result.position,
        status: result.status,
        businessId: event.businessId,
        userId: event.userId,
      ));
      _startPolling();
    } catch (e) {
      emit(QueueError(e.toString()));
    }
  }

  Future<void> _onPollQueueStatus(PollQueueStatus event, Emitter<QueueState> emit) async {
    final state = this.state;
    if (state is QueueJoined) {
      try {
        final result = await repository.getQueueStatus(
          businessId: state.businessId,
          userId: state.userId,
        );
        emit(QueueJoined(
          position: result.position,
          status: result.status,
          businessId: state.businessId,
          userId: state.userId,
        ));
      } catch (e) {
        // Log error but maintain state for resilience
        print('Polling error: $e');
      }
    }
  }

  void _onStopQueuePolling(StopQueuePolling event, Emitter<QueueState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    emit(QueueInitial());
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(const PollQueueStatus());
    });
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
