import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/buyer_models.dart';

class BuyerProvider extends ChangeNotifier {
  String? _token;
  List<BuyerProductModel> _products = [];
  List<BuyerOrderModel> _orders = [];
  bool _loadingProducts = false;
  bool _loadingOrders = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────
  List<BuyerProductModel> get products => _products;
  List<BuyerOrderModel> get orders => _orders;
  bool get loadingProducts => _loadingProducts;
  bool get loadingOrders => _loadingOrders;
  String? get error => _error;

  void setToken(String? token) {
    if (_token == token) return;
    _token = token;
    if (token != null && token.isNotEmpty) {
      fetchProducts();
      fetchOrders();
    }
  }

  ApiService get _api => ApiService(token: _token);

  // ── Fetch Products ─────────────────────────────────────────────
  Future<void> fetchProducts() async {
    _loadingProducts = true;
    notifyListeners();
    try {
      final data = await _api.get('/market/products/');
      final list = data is List ? data : (data['results'] ?? data['data'] ?? []);
      _products = (list as List).map((e) => BuyerProductModel.fromJson(e)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingProducts = false;
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
      _orders = (list as List).map((e) => BuyerOrderModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Fetch orders error: $e');
    } finally {
      _loadingOrders = false;
      notifyListeners();
    }
  }

  // ── Create Order ───────────────────────────────────────────────
  Future<bool> createOrder(int productId, double quantity) async {
    final body = {
      'product': productId,
      'quantity': quantity,
    };
    debugPrint('Generating Order with Body: $body');
    try {
      await _api.post('/market/orders/', body);
      await fetchOrders();
      return true;
    } catch (e) {
      debugPrint('Order Generation FAILED: $e');
      return false;
    }
  }
}
