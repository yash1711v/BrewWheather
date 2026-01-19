// lib/data/models/forecast_model.dart
class ForecastModel {
  final String date;
  final int temp;
  final int min;
  final int max;
  final String condition;
  final String icon;
  final int humidity;
  final int windSpeed;

  ForecastModel({
    required this.date,
    required this.temp,
    required this.min,
    required this.max,
    this.condition = 'Unknown',
    this.icon = '',
    this.humidity = 0,
    this.windSpeed = 0,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: _formatDate(json['dt']),
      temp: (json['main']['temp'] as num).round(),
      min: (json['main']['temp_min'] as num).round(),
      max: (json['main']['temp_max'] as num).round(),
      condition: json['weather'][0]['main'] ?? 'Unknown',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: ((json['wind']['speed'] as num) * 2.237).round(),
    );
  }

  static String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();

    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'TODAY';
    }

    final weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return weekdays[date.weekday % 7];
  }
}