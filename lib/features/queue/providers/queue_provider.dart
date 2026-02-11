import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/queue_repository.dart';
import '../data/queue_status_model.dart';
import 'package:uuid/uuid.dart';

class QueueProvider extends ChangeNotifier {
  final QueueRepository _repository;
  
  String? _guestId;
  String? _businessId;
  QueueStatus? _status;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  QueueProvider(this._repository) {
    _loadState();
  }

  // Getters
  String? get guestId => _guestId;
  String? get businessId => _businessId;
  QueueStatus? get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get inQueue => _businessId != null && _guestId != null;

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _guestId = prefs.getString('guest_id');
    _businessId = prefs.getString('business_id');
    
    if (_guestId == null) {
      _guestId = const Uuid().v4();
      await prefs.setString('guest_id', _guestId!);
    }

    if (_businessId != null) {
      startPolling();
    }
    notifyListeners();
  }

  Future<void> joinQueue(String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_guestId == null) {
         final prefs = await SharedPreferences.getInstance();
         _guestId = const Uuid().v4();
         await prefs.setString('guest_id', _guestId!);
      }

      await _repository.joinQueue(businessId, _guestId!);
      
      _businessId = businessId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('business_id', businessId);

      await _updateStatus();
      startPolling();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveQueue() async {
    if (_businessId == null || _guestId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.leaveQueue(_businessId!, _guestId!);
      _businessId = null;
      _status = null;
      _stopPolling();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('business_id');
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _updateStatus(); // Immediate update
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) => _updateStatus());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  Future<void> _updateStatus() async {
    if (_businessId == null) return;
    
    try {
      final newStatus = await _repository.getQueueStatus(_businessId!, userId: _guestId);
      _status = newStatus;
      _error = null;
      
      // If position is 0, it might mean we are served or removed. 
      // For now, we just update the status. Valid positions are 1+.
      notifyListeners();
    } catch (e) {
      print("Polling error: $e");
      // Don't set global error to avoid disrupting UI on temporary network blip
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
