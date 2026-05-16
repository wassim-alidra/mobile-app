import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/equipment_model.dart';
import '../models/equipment_booking_model.dart';
import '../models/equipment_provider_stats.dart';

enum EpLoadState { idle, loading, loaded, error }

class EquipmentProviderProvider extends ChangeNotifier {
  String? _token;

  List<EquipmentModel> _equipment = [];
  List<EquipmentBookingModel> _bookings = [];
  EquipmentProviderStats _stats = EquipmentProviderStats.empty();
  EpLoadState _state = EpLoadState.idle;
  String? _errorMessage;
  Timer? _pollingTimer;

  List<EquipmentModel> get equipment => _equipment;
  List<EquipmentBookingModel> get bookings => _bookings;
  EquipmentProviderStats get stats => _stats;
  EpLoadState get state => _state;
  bool get isLoading => _state == EpLoadState.loading;
  String? get errorMessage => _errorMessage;

  List<EquipmentBookingModel> get pendingBookings =>
      _bookings.where((b) => b.isPending).toList();

  List<EquipmentBookingModel> get activeBookings =>
      _bookings.where((b) => b.isAccepted).toList();

  List<EquipmentBookingModel> get historyBookings =>
      _bookings.where((b) => b.isCompleted || b.isRejected).toList();

  void setToken(String? token) {
    if (_token != token) {
      _token = token;
      if (token != null) {
        fetchAll();
        _startPolling();
      } else {
        _stopPolling();
        _equipment = [];
        _bookings = [];
        notifyListeners();
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: kPollingIntervalSeconds),
      (_) => fetchAll(silent: true),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchAll({bool silent = false}) async {
    await Future.wait([
      fetchEquipment(silent: silent),
      fetchBookings(silent: silent),
    ]);
  }

  Future<void> fetchEquipment({bool silent = false}) async {
    if (_token == null) return;
    if (!silent) {
      _state = EpLoadState.loading;
      notifyListeners();
    }
    try {
      final api = ApiService(token: _token);
      final data = await api.get(kEquipmentEndpoint) as dynamic;
      List<dynamic> list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      _equipment = list
          .map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _state = EpLoadState.loaded;
      _errorMessage = null;
      _computeStats();
    } on ApiException catch (e) {
      _state = EpLoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = EpLoadState.error;
      _errorMessage = 'Failed to load equipment';
    }
    notifyListeners();
  }

  Future<void> fetchBookings({bool silent = false}) async {
    if (_token == null) return;
    if (!silent) {
      _state = EpLoadState.loading;
      notifyListeners();
    }
    try {
      final api = ApiService(token: _token);
      final data = await api.get(kEquipmentBookingsEndpoint) as dynamic;
      List<dynamic> list;
      if (data is Map && data.containsKey('results')) {
        list = data['results'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        list = [];
      }
      _bookings = list
          .map((e) => EquipmentBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _state = EpLoadState.loaded;
      _errorMessage = null;
      _computeStats();
    } on ApiException catch (e) {
      _state = EpLoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = EpLoadState.error;
      _errorMessage = 'Failed to load bookings';
    }
    notifyListeners();
  }

  void _computeStats() {
    final totalEquipment = _equipment.length;
    final availableFleet =
        _equipment.where((e) => e.isActuallyAvailable).length;
    final totalBookings = _bookings.length;
    final pendingCount = _bookings.where((b) => b.isPending).length;
    final activeCount = _bookings.where((b) => b.isAccepted).length;
    final completedCount = _bookings.where((b) => b.isCompleted).length;
    final totalRevenue = _bookings
        .where((b) => b.isAccepted || b.isCompleted)
        .fold<double>(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));

    _stats = EquipmentProviderStats(
      totalEquipment: totalEquipment,
      totalBookings: totalBookings,
      pendingBookings: pendingCount,
      activeBookings: activeCount,
      completedBookings: completedCount,
      totalRevenue: totalRevenue,
      availableFleet: availableFleet,
    );
  }

  Future<bool> createEquipment(Map<String, dynamic> data) async {
    if (_token == null) return false;
    try {
      final api = ApiService(token: _token);
      await api.post(kEquipmentEndpoint, data);
      await fetchEquipment(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create equipment';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEquipment(int id, Map<String, dynamic> data) async {
    if (_token == null) return false;
    try {
      final api = ApiService(token: _token);
      await api.patch('$kEquipmentEndpoint$id/', data);
      await fetchEquipment(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update equipment';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEquipment(int id) async {
    if (_token == null) return false;
    try {
      final api = ApiService(token: _token);
      final response = await api.delete('$kEquipmentEndpoint$id/');
      if (response == true || response == null || response == {}) {
        _equipment.removeWhere((e) => e.id == id);
        _computeStats();
        notifyListeners();
        return true;
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete equipment';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    if (_token == null) return false;
    try {
      final api = ApiService(token: _token);
      await api.patch('$kEquipmentBookingsEndpoint$bookingId/', {'status': status});
      await fetchBookings(silent: true);
      await fetchEquipment(silent: true);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update booking status';
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
