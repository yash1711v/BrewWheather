// lib/data/models/weather_model.dart
class WeatherModel {
  final int temp;
  final String condition;
  final int max;
  final int min;
  final int humidity;
  final int windSpeed;
  final String uvIndex;
  final String location;
  final String icon;

  WeatherModel({
    required this.temp,
    required this.condition,
    required this.max,
    required this.min,
    this.humidity = 0,
    this.windSpeed = 0,
    this.uvIndex = '0',
    this.location = 'Unknown',
    this.icon = '',
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: (json['main']['temp'] as num).round(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      max: (json['main']['temp_max'] as num).round(),
      min: (json['main']['temp_min'] as num).round(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: ((json['wind']['speed'] as num) * 2.237).round(), // Convert m/s to mph
      uvIndex: _calculateUVIndex(json['clouds']['all'] ?? 0),
      location: json['name'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }

  static String _calculateUVIndex(int cloudCoverage) {
    // Simple UV index estimation based on cloud coverage
    if (cloudCoverage < 20) return '8 High';
    if (cloudCoverage < 50) return '5 Mid';
    if (cloudCoverage < 80) return '3 Low';
    return '1 Low';
  }
}