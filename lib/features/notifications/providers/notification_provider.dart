import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  String? _token;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void setToken(String? token) {
    if (_token != token) {
      _token = token;
      if (token != null) {
        fetchNotifications();
        _startPolling();
      } else {
        _stopPolling();
        _notifications = [];
        notifyListeners();
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: kPollingIntervalSeconds),
      (_) => fetchNotifications(silent: true),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    if (_token == null) return;

    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final api = ApiService(token: _token);
      final data = await api.getNotifications();
      _notifications = data
          .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();

      // Sort: unread first, then by date desc
      _notifications.sort((a, b) {
        if (!a.isRead && b.isRead) return -1;
        if (a.isRead && !b.isRead) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    if (_token == null) return;

    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();

      try {
        final api = ApiService(token: _token);
        await api.markNotificationRead(id);
      } catch (_) {}
    }
  }

  Future<void> markAllRead() async {
    if (_token == null) return;

    // Optimistically update UI
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    try {
      final api = ApiService(token: _token);
      await api.markAllNotificationsRead();
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
