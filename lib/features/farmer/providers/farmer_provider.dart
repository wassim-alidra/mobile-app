import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/farmer_order_model.dart';
import '../../auth/models/user_model.dart';

class FarmerProvider extends ChangeNotifier {
  UserModel? _user;

  String? _token;

  // ── State ──────────────────────────────────────────────────────
  FarmerStatsModel? _stats;
  FarmerChartStats? _chartStats;
  List<FarmerOrderModel> _orders = [];
  List<FireAlert> _fireAlerts = [];
  bool _hasFireAlert = false;

  bool _loadingStats = false;
  bool _loadingOrders = false;
  bool _loadingChart = false;
  String? _error;

  Timer? _iotTimer;

  // ── Getters ────────────────────────────────────────────────────
  UserModel? get user => _user;
  FarmerStatsModel? get stats => _stats;
  FarmerChartStats? get chartStats => _chartStats;
  List<FarmerOrderModel> get orders => _orders;
  List<FireAlert> get fireAlerts => _fireAlerts;
  bool get hasFireAlert => _hasFireAlert;
  bool get loadingStats => _loadingStats;
  bool get loadingOrders => _loadingOrders;
  bool get loadingChart => _loadingChart;
  String? get error => _error;

  List<FarmerOrderModel> get pendingOrders =>
      _orders.where((o) => o.status == 'PENDING').toList();
  List<FarmerOrderModel> get acceptedOrders =>
      _orders.where((o) => o.status == 'ACCEPTED').toList();
  List<FarmerOrderModel> get completedOrders =>
      _orders.where((o) => o.status == 'DELIVERED').toList();

  // ── Token management ───────────────────────────────────────────
  void setUserAndToken(UserModel? user, String? token) {
    _user = user;
    if (_token != token) {
      _token = token;
      if (token != null) {
        _startIotPolling();
        fetchStats();
        fetchOrders();
        fetchChartStats();
      } else {
        _stopIotPolling();
      }
    }
    notifyListeners();
  }

  ApiService get _api => ApiService(token: _token);

  // ── Fetch Stats ────────────────────────────────────────────────
  Future<void> fetchStats() async {
    _loadingStats = true;
    notifyListeners();
    try {
      final data = await _api.get('/market/products/stats/');
      _stats = FarmerStatsModel.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingStats = false;
      notifyListeners();
    }
  }

  // ── Fetch Chart Stats ──────────────────────────────────────────
  Future<void> fetchChartStats() async {
    _loadingChart = true;
    notifyListeners();
    try {
      final data = await _api.get('/setistics/farmer-stats/');
      _chartStats = FarmerChartStats.fromJson(data);
    } catch (e) {
      debugPrint('Chart stats error: $e');
    } finally {
      _loadingChart = false;
      notifyListeners();
    }
  }

  // ── Fetch Orders ───────────────────────────────────────────────
  Future<void> fetchOrders() async {
    _loadingOrders = true;
    notifyListeners();
    try {
      final data = await _api.get('/market/orders/');
      final list = data is List ? data : (data['results'] ?? data['data'] ?? []);
      _orders = (list as List).map((e) => FarmerOrderModel.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingOrders = false;
      notifyListeners();
    }
  }

  // ── Accept / Reject Order ──────────────────────────────────────
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      await _api.patch('/market/orders/$orderId/', {'status': status});
      await fetchOrders();
      await fetchStats();
      return true;
    } catch (e) {
      debugPrint('Order update error: $e');
      return false;
    }
  }

  // ── IoT Fire Alert Polling ─────────────────────────────────────
  void _startIotPolling() {
    _stopIotPolling();
    _fetchFireAlerts();
    _iotTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchFireAlerts();
    });
  }

  void _stopIotPolling() {
    _iotTimer?.cancel();
    _iotTimer = null;
  }

  Future<void> _fetchFireAlerts() async {
    try {
      final data = await _api.get('/iot/active-alerts/');
      _hasFireAlert = data['has_fire'] == true;
      _fireAlerts = (data['alerts'] as List? ?? [])
          .map((e) => FireAlert.fromJson(e))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> resolveFireAlert(int alertId) async {
    try {
      await _api.post('/iot/resolve-alert/$alertId/', {});
      await _fetchFireAlerts();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _stopIotPolling();
    super.dispose();
  }
}
