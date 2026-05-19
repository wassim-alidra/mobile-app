// Models matching the backend /api/weather/ response structure.
//
// Backend response shape:
// {
//   "last_updated": "2024-01-01 12:00",
//   "weather": { "temp": 28.5, "humidity": 45, "description": "Clear sky" },
//   "soil": {
//     "moisture": 0.47,
//     "surface_temp": 28.5,
//     "irrigation_recommendation": "Optimal conditions, no irrigation needed",
//     "is_needed": false
//   },
//   "forecast": [ { "day": "Monday", "temp": 30.0, "desc": "Sunny" }, ... ]
// }
//
// Backend /api/weather/device-control/ response:
// { "pump_on": false, "relay": 0, "message": "..." }

class WeatherData {
  final double temp;
  final int humidity;
  final String description;

  const WeatherData({
    required this.temp,
    required this.humidity,
    required this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '--',
    );
  }
}

class SoilData {
  final double moisture;
  final double surfaceTemp;
  final String irrigationRecommendation;
  final bool isNeeded;

  const SoilData({
    required this.moisture,
    required this.surfaceTemp,
    required this.irrigationRecommendation,
    required this.isNeeded,
  });

  factory SoilData.fromJson(Map<String, dynamic> json) {
    final temp = (json['surface_temp'] as num?)?.toDouble() ?? 0.0;
    final recommendation = json['recommendation'] as String? ?? '--';
    final isNeeded = json['is_needed'] as bool? ?? false;
    final urgencyScore = (json['urgency_score'] as num?)?.toDouble() ?? 0.0;

    // Simulate soil moisture based on the multi-factor agronomic urgency score.
    // High urgency_score (0 to 9+) means dry soil, so moisture is low.
    final moisture = 1.0 - (urgencyScore.clamp(0.0, 9.0) / 9.0);

    return SoilData(
      moisture: moisture,
      surfaceTemp: temp,
      irrigationRecommendation: recommendation,
      isNeeded: isNeeded,
    );
  }

  /// Returns moisture as a percentage string e.g. "47%"
  String get moisturePercent => '${(moisture * 100).toStringAsFixed(0)}%';
}

class ForecastItem {
  final String day;
  final String temp;
  final String description;

  const ForecastItem({
    required this.day,
    required this.temp,
    required this.description,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final rawTemp = json['temp'];
    final tempStr =
        rawTemp is num ? '${rawTemp.toStringAsFixed(0)}°C' : (rawTemp ?? '--').toString();
    return ForecastItem(
      day: json['day'] as String? ?? '--',
      temp: tempStr,
      description: json['desc'] as String? ?? '--',
    );
  }
}

class DeviceStatus {
  final bool pumpOn;
  final int relay;
  final String message;

  const DeviceStatus({
    required this.pumpOn,
    required this.relay,
    required this.message,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      pumpOn: json['pump_on'] as bool? ?? false,
      relay: (json['relay'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? '--',
    );
  }
}

class FarmModel {
  final int id;
  final String name;
  final String wilaya;
  final String? location;
  final bool isApproved;

  const FarmModel({
    required this.id,
    required this.name,
    required this.wilaya,
    this.location,
    this.isApproved = false,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown Farm',
      wilaya: json['wilaya'] as String? ?? '--',
      location: json['location'] as String?,
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }
}

/// Top-level model combining all weather dashboard data.
class WeatherDashboardModel {
  final String lastUpdated;
  final WeatherData weather;
  final SoilData soil;
  final List<ForecastItem> forecast;

  const WeatherDashboardModel({
    required this.lastUpdated,
    required this.weather,
    required this.soil,
    required this.forecast,
  });

  factory WeatherDashboardModel.fromJson(Map<String, dynamic> json) {
    final forecastList = (json['forecast'] as List<dynamic>? ?? [])
        .map((e) => ForecastItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return WeatherDashboardModel(
      lastUpdated: json['last_updated'] as String? ?? '--',
      weather: WeatherData.fromJson(
          (json['weather'] as Map<String, dynamic>?) ?? {}),
      soil: SoilData.fromJson((json['irrigation'] as Map<String, dynamic>?) ?? {}),
      forecast: forecastList,
    );
  }
}
