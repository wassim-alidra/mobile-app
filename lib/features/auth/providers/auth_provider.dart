import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _token;
  String? _refreshToken;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _token != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(kTokenKey);
      _refreshToken = prefs.getString(kRefreshTokenKey);
      final userJson = prefs.getString(kUserDataKey);

      if (_token != null && userJson != null) {
        _user = UserModel.fromJson(jsonDecode(userJson));
        _status = AuthStatus.authenticated;

        // Verify token is still valid by fetching current user
        await _refreshCurrentUser();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _refreshCurrentUser() async {
    try {
      final api = ApiService(token: _token);
      final data = await api.getCurrentUser();
      _user = UserModel.fromJson(data);
      await _saveUserToStorage();
    } catch (e) {
      // Token might be expired, try refresh
      if (_refreshToken != null) {
        await _tryRefreshToken();
      } else {
        await logout();
      }
    }
  }

  Future<void> _tryRefreshToken() async {
    try {
      final api = ApiService();
      final data = await api.refreshToken(_refreshToken!);
      _token = data['access'];
      await _saveTokenToStorage();
      await _refreshCurrentUser();
    } catch (e) {
      await logout();
    }
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final api = ApiService();
      final data = await api.login(username, password);

      _token = data['access'];
      _refreshToken = data['refresh'];

      // Fetch user profile
      final userApi = ApiService(token: _token);
      final userData = await userApi.getCurrentUser();
      _user = UserModel.fromJson(userData);

      // Verify user is a transporter, farmer or buyer
      if (_user!.role != 'TRANSPORTER' && _user!.role != 'FARMER' && _user!.role != 'BUYER') {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'This app is for transporters, farmers and buyers only.';
        _token = null;
        _refreshToken = null;
        _user = null;
        notifyListeners();
        return false;
      }

      await _saveAllToStorage();
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Connection failed. Make sure the server is running.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _token = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
    await prefs.remove(kRefreshTokenKey);
    await prefs.remove(kUserDataKey);

    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_token == null) return;
    await _refreshCurrentUser();
    notifyListeners();
  }

  Future<void> _saveAllToStorage() async {
    await _saveTokenToStorage();
    await _saveUserToStorage();
  }

  Future<void> _saveTokenToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) await prefs.setString(kTokenKey, _token!);
    if (_refreshToken != null) {
      await prefs.setString(kRefreshTokenKey, _refreshToken!);
    }
  }

  Future<void> _saveUserToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString(kUserDataKey, jsonEncode(_user!.toJson()));
    }
  }
}
