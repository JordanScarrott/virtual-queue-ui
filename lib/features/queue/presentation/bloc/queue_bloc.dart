import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:red_duck/features/queue/domain/entities/queue_status.dart';
import 'package:red_duck/services/realtime_client.dart';
import '../../domain/repositories/queue_repository.dart';

part 'queue_event.dart';
part 'queue_state.dart';

class QueueBloc extends Bloc<QueueEvent, QueueState> {
  final QueueRepository repository;
  final RealtimeClient realtimeClient;
  StreamSubscription<QueueStatus>? _queueSubscription;

  QueueBloc({
    required this.repository,
    required this.realtimeClient,
  }) : super(QueueInitial()) {
    on<JoinQueue>(_onJoinQueue);
    on<UpdateQueueStatus>(_onUpdateQueueStatus);
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
      _subscribeToQueue(event.businessId);
    } catch (e) {
      emit(QueueError(e.toString()));
    }
  }

  void _onUpdateQueueStatus(UpdateQueueStatus event, Emitter<QueueState> emit) {
    final currentState = state;
    if (currentState is QueueJoined) {
      emit(QueueJoined(
        position: event.status.position,
        status: event.status.status,
        businessId: currentState.businessId,
        userId: currentState.userId,
      ));
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
    String? businessId = event.businessId;
    String? userId = event.userId;

    if (businessId == null || userId == null) {
      if (currentState is QueueJoined) {
        businessId ??= currentState.businessId;
        userId ??= currentState.userId;
      }
    }

    if (businessId != null && userId != null) {
      emit(QueueLoading());
      try {
        await repository.leaveQueue(
          businessId: businessId,
          userId: userId,
        );
        _stopListening();
        emit(QueueLeft());
      } catch (e) {
        emit(QueueError(e.toString()));
        // If we were joined and failed to leave, verify if we should restore state
        if (currentState is QueueJoined) {
           emit(QueueJoined(
            position: currentState.position,
            status: currentState.status,
            businessId: currentState.businessId,
            userId: currentState.userId,
          ));
          _subscribeToQueue(currentState.businessId);
        }
      }
    } else {
      emit(const QueueError('Cannot leave queue: Missing Business ID or User ID'));
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

  void _onStopQueuePolling(StopQueuePolling event, Emitter<QueueState> emit) {
    _stopListening();
    emit(QueueInitial());
  }

  void _subscribeToQueue(String businessId) {
    _queueSubscription?.cancel();
    _queueSubscription = realtimeClient.subscribeToQueue(businessId).listen(
      (status) {
        add(UpdateQueueStatus(status));
      },
      onError: (error) {
        print('Queue subscription error: $error');
      },
    );
  }

  void _stopListening() {
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  @override
  Future<void> close() {
    _stopListening();
    return super.close();
  }
}
