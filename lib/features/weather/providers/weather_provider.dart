import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/weather_model.dart';

/// Coordinates:
/// - GET /api/farms/                   → list of farmer's farms
/// - GET /api/weather/?lat=X&lon=Y     → weather dashboard (no auth needed by backend,
///                                        but we send the token anyway)
/// - GET /api/weather/device-control/?farm_id=X  → device/pump status
///
/// The backend WeatherDashboardView accepts lat/lon query params.
/// If no coordinates are provided it defaults to Algiers (36.7525, 3.0420).
/// Since Farm has no lat/lon in the model, we look up a known wilaya-to-coordinates
/// mapping for display; if a farm has no mapping we fall back to Algiers defaults.
class WeatherProvider extends ChangeNotifier {
  String? _token;

  // ── State ──────────────────────────────────────────────────────
  List<FarmModel> _farms = [];
  FarmModel? _selectedFarm;
  WeatherDashboardModel? _weatherData;
  DeviceStatus? _deviceStatus;

  bool _loadingFarms = false;
  bool _loadingWeather = false;
  bool _loadingDevice = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────
  List<FarmModel> get farms => _farms;
  FarmModel? get selectedFarm => _selectedFarm;
  WeatherDashboardModel? get weatherData => _weatherData;
  DeviceStatus? get deviceStatus => _deviceStatus;
  bool get loadingFarms => _loadingFarms;
  bool get loadingWeather => _loadingWeather;
  bool get loadingDevice => _loadingDevice;
  String? get error => _error;
  bool get hasData => _weatherData != null;

  // ── Token management ───────────────────────────────────────────
  void setToken(String? token) {
    if (_token != token) {
      _token = token;
      if (token != null) {
        fetchFarms();
      }
    }
  }

  ApiService get _api => ApiService(token: _token);

  // ── Fetch Farms ────────────────────────────────────────────────
  Future<void> fetchFarms() async {
    _loadingFarms = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.get('/farms/');
      final list = data is List
          ? data
          : (data['results'] ?? data['data'] ?? data);
      _farms = (list as List)
          .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Auto-select first farm and load weather
      if (_farms.isNotEmpty) {
        _selectedFarm ??= _farms.first;
        await fetchWeather();
        await fetchDeviceStatus();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingFarms = false;
      notifyListeners();
    }
  }

  // ── Select Farm ────────────────────────────────────────────────
  Future<void> selectFarm(FarmModel farm) async {
    _selectedFarm = farm;
    _weatherData = null;
    _deviceStatus = null;
    notifyListeners();
    await fetchWeather();
    await fetchDeviceStatus();
  }

  // ── Fetch Weather ──────────────────────────────────────────────
  Future<void> fetchWeather() async {
    _loadingWeather = true;
    _error = null;
    notifyListeners();
    try {
      final coords = _getCoords(_selectedFarm?.wilaya);
      final lat = coords['lat'];
      final lon = coords['lon'];
      final data = await _api.get('/weather/?lat=$lat&lon=$lon');
      _weatherData =
          WeatherDashboardModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingWeather = false;
      notifyListeners();
    }
  }

  // ── Fetch Device Status ────────────────────────────────────────
  Future<void> fetchDeviceStatus() async {
    final farmId = _selectedFarm?.id;
    if (farmId == null) return;

    _loadingDevice = true;
    notifyListeners();
    try {
      final coords = _getCoords(_selectedFarm?.wilaya);
      final lat = coords['lat'];
      final lon = coords['lon'];
      final data = await _api
          .get('/weather/device-control/?farm_id=$farmId&lat=$lat&lon=$lon&check_only=true');
      _deviceStatus =
          DeviceStatus.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Device status error: $e');
      // Non-critical — do not surface to user
    } finally {
      _loadingDevice = false;
      notifyListeners();
    }
  }

  // ── Refresh ────────────────────────────────────────────────────
  Future<void> refresh() async {
    await fetchWeather();
    await fetchDeviceStatus();
  }

  // ── Wilaya → Coordinates lookup ────────────────────────────────
  /// Maps Algerian wilaya names (as stored in the Farm model) to
  /// approximate GPS coordinates. Falls back to Algiers if unknown.
  Map<String, double> _getCoords(String? wilaya) {
    if (wilaya == null) return {'lat': 36.7525, 'lon': 3.0420};

    const coords = <String, Map<String, double>>{
      'Adrar': {'lat': 27.8742, 'lon': -0.2839},
      'Chlef': {'lat': 36.1652, 'lon': 1.3317},
      'Laghouat': {'lat': 33.8000, 'lon': 2.8650},
      'Oum El Bouaghi': {'lat': 35.8760, 'lon': 7.1115},
      'Batna': {'lat': 35.5560, 'lon': 6.1742},
      'Béjaïa': {'lat': 36.7509, 'lon': 5.0560},
      'Biskra': {'lat': 34.8500, 'lon': 5.7280},
      'Béchar': {'lat': 31.6238, 'lon': -2.2162},
      'Blida': {'lat': 36.4700, 'lon': 2.8300},
      'Bouira': {'lat': 36.3800, 'lon': 3.9000},
      'Tamanrasset': {'lat': 22.7850, 'lon': 5.5228},
      'Tébessa': {'lat': 35.4000, 'lon': 8.1200},
      'Tlemcen': {'lat': 34.8800, 'lon': -1.3150},
      'Tiaret': {'lat': 35.3700, 'lon': 1.3200},
      'Tizi Ouzou': {'lat': 36.7169, 'lon': 4.0497},
      'Algiers': {'lat': 36.7525, 'lon': 3.0420},
      'Alger': {'lat': 36.7525, 'lon': 3.0420},
      'Djelfa': {'lat': 34.6700, 'lon': 3.2600},
      'Jijel': {'lat': 36.8200, 'lon': 5.7700},
      'Sétif': {'lat': 36.1900, 'lon': 5.4100},
      'Saïda': {'lat': 34.8300, 'lon': 0.1500},
      'Skikda': {'lat': 36.8700, 'lon': 6.9100},
      'Sidi Bel Abbès': {'lat': 35.1900, 'lon': -0.6300},
      'Annaba': {'lat': 36.9000, 'lon': 7.7700},
      'Guelma': {'lat': 36.4600, 'lon': 7.4300},
      'Constantine': {'lat': 36.3650, 'lon': 6.6147},
      'Médéa': {'lat': 36.2640, 'lon': 2.7510},
      'Mostaganem': {'lat': 35.9400, 'lon': 0.0890},
      'M\'Sila': {'lat': 35.7000, 'lon': 4.5400},
      'Mascara': {'lat': 35.4000, 'lon': 0.1400},
      'Ouargla': {'lat': 31.9500, 'lon': 5.3300},
      'Oran': {'lat': 35.6969, 'lon': -0.6331},
      'El Bayadh': {'lat': 33.6800, 'lon': 1.0200},
      'Illizi': {'lat': 26.5000, 'lon': 8.4800},
      'Bordj Bou Arréridj': {'lat': 36.0730, 'lon': 4.7630},
      'Boumerdès': {'lat': 36.7600, 'lon': 3.4800},
      'El Tarf': {'lat': 36.7670, 'lon': 8.3130},
      'Tindouf': {'lat': 27.6740, 'lon': -8.1470},
      'Tissemsilt': {'lat': 35.6070, 'lon': 1.8120},
      'El Oued': {'lat': 33.3670, 'lon': 6.8630},
      'Khenchela': {'lat': 35.4360, 'lon': 7.1430},
      'Souk Ahras': {'lat': 36.2860, 'lon': 7.9510},
      'Tipaza': {'lat': 36.5900, 'lon': 2.4500},
      'Mila': {'lat': 36.4500, 'lon': 6.2600},
      'Aïn Defla': {'lat': 36.2640, 'lon': 1.9680},
      'Naâma': {'lat': 33.2660, 'lon': -0.3120},
      'Aïn Témouchent': {'lat': 35.2980, 'lon': -1.1400},
      'Ghardaïa': {'lat': 32.4900, 'lon': 3.6730},
      'Relizane': {'lat': 35.7380, 'lon': 0.5560},
    };

    // Case-insensitive lookup
    for (final entry in coords.entries) {
      if (entry.key.toLowerCase() == wilaya.toLowerCase()) {
        return entry.value;
      }
    }

    return {'lat': 36.7525, 'lon': 3.0420}; // Default: Algiers
  }
}
