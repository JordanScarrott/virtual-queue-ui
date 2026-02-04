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
    on<CreateQueue>(_onCreateQueue);
    on<LeaveQueue>(_onLeaveQueue);
    on<CheckQueue>(_onCheckQueue);
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

  Future<void> _onCreateQueue(CreateQueue event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    try {
      await repository.createQueue(event.businessId);
      emit(QueueCreated(event.businessId));
    } catch (e) {
      emit(QueueError(e.toString()));
    }
  }

  Future<void> _onLeaveQueue(LeaveQueue event, Emitter<QueueState> emit) async {
    final currentState = state;
    if (currentState is QueueJoined) {
      emit(QueueLoading());
      try {
        await repository.leaveQueue(
          businessId: currentState.businessId,
          userId: currentState.userId,
        );
        _stopPolling();
        emit(QueueLeft());
      } catch (e) {
        emit(QueueError(e.toString()));
        // If error, should we go back to joined?
        // Let's go back to joined to allow retry
         emit(QueueJoined(
          position: currentState.position,
          status: currentState.status,
          businessId: currentState.businessId,
          userId: currentState.userId,
        ));
        _startPolling();
      }
    }
  }

  Future<void> _onCheckQueue(CheckQueue event, Emitter<QueueState> emit) async {
    emit(QueueLoading());
    try {
      final result = await repository.getQueue(event.businessId);
      emit(QueueInfoLoaded(result, event.businessId));
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
    _stopPolling();
    emit(QueueInitial());
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      add(const PollQueueStatus());
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
