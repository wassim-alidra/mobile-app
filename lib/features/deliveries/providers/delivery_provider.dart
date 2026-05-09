import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/delivery_model.dart';

enum DeliveryLoadState { idle, loading, loaded, error }

class DeliveryProvider extends ChangeNotifier {
  String? _token;
  List<DeliveryModel> _deliveries = [];
  List<dynamic> _availableRequests = [];
  DeliveryModel? _currentDelivery;
  DeliveryLoadState _state = DeliveryLoadState.idle;
  bool _isAccepting = false;

  String? _errorMessage;
  Timer? _pollingTimer;

  List<DeliveryModel> get deliveries => _deliveries;
  List<dynamic> get availableRequests => _availableRequests;
  DeliveryModel? get currentDelivery => _currentDelivery;
  DeliveryLoadState get state => _state;
  bool get isAccepting => _isAccepting;
  String? get errorMessage => _errorMessage;


  List<DeliveryModel> get activeDeliveries =>
      _deliveries.where((d) => d.isActive).toList();

  List<DeliveryModel> get completedDeliveries =>
      _deliveries.where((d) => d.isCompleted).toList();

  void setToken(String? token) {
    if (_token != token) {
      _token = token;
      if (token != null) {
        fetchDeliveries();
        fetchAvailableRequests();
        _startPolling();

      } else {
        _stopPolling();
        _deliveries = [];
        notifyListeners();
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: kPollingIntervalSeconds),
      (_) => fetchDeliveries(silent: true),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchDeliveries({bool silent = false}) async {
    if (_token == null) return;

    if (!silent) {
      _state = DeliveryLoadState.loading;
      notifyListeners();
    }

    try {
      final api = ApiService(token: _token);
      final data = await api.getMyDeliveries();
      _deliveries = data
          .map((d) => DeliveryModel.fromJson(d as Map<String, dynamic>))
          .toList();

      // Sort: active first, then by date
      _deliveries.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.order.createdAt.compareTo(a.order.createdAt);
      });

      _state = DeliveryLoadState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _state = DeliveryLoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = DeliveryLoadState.error;
      _errorMessage = 'Failed to load deliveries';
    }

    notifyListeners();
  }

  Future<void> fetchAvailableRequests({bool silent = false}) async {
    if (_token == null) return;

    if (!silent) {
      _state = DeliveryLoadState.loading;
      notifyListeners();
    }

    try {
      final api = ApiService(token: _token);
      _availableRequests = await api.getAvailableOrders();
      _state = DeliveryLoadState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _state = DeliveryLoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = DeliveryLoadState.error;
      _errorMessage = 'Failed to load requests';
    }

    notifyListeners();
  }

  Future<bool> acceptRequest(int orderId) async {
    if (_token == null) return false;

    _isAccepting = true;
    notifyListeners();

    try {
      final api = ApiService(token: _token);
      await api.acceptDelivery(orderId);
      
      // Refresh both lists
      await fetchDeliveries(silent: true);
      await fetchAvailableRequests(silent: true);
      
      _isAccepting = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isAccepting = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to accept delivery';
      _isAccepting = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRouteData(String fWilaya, String bWilaya) async {
    if (_token == null) return null;
    try {
      final api = ApiService(token: _token);
      return await api.calculateRoute(fWilaya, bWilaya);
    } catch (e) {
      debugPrint('Error getting route data: $e');
      return null;
    }
  }


  Future<DeliveryModel?> fetchDelivery(int id) async {
    if (_token == null) return null;

    try {
      final api = ApiService(token: _token);
      final data = await api.getDelivery(id);
      final delivery = DeliveryModel.fromJson(data);

      // Update in local list
      final idx = _deliveries.indexWhere((d) => d.id == id);
      if (idx >= 0) {
        _deliveries[idx] = delivery;
      }

      _currentDelivery = delivery;
      notifyListeners();
      return delivery;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus(int deliveryId, String newStatus) async {
    if (_token == null) return false;

    try {
      final api = ApiService(token: _token);
      final data = await api.updateDeliveryStatus(deliveryId, newStatus);
      final updated = DeliveryModel.fromJson(data);

      final idx = _deliveries.indexWhere((d) => d.id == deliveryId);
      if (idx >= 0) {
        _deliveries[idx] = updated;
      }
      if (_currentDelivery?.id == deliveryId) {
        _currentDelivery = updated;
      }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
