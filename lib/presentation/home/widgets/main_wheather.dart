// lib/features/home/widgets/main_weather_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MainWeatherCard extends StatelessWidget {
  final int temperature;
  final String condition;
  final int highTemp;
  final int lowTemp;
  final String weatherIcon;

  const MainWeatherCard({
    super.key,
    required this.temperature,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
    this.weatherIcon = '🌤️',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Weather Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getWeatherIcon(condition),
                size: 64,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$temperature',
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                '°',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.primaryBlue,
                  height: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Condition
          Text(
            condition,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // High/Low
          Text(
            'H: $highTemp°  L: $lowTemp°',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('cloud')) return Icons.cloud;
    if (conditionLower.contains('rain')) return Icons.umbrella;
    if (conditionLower.contains('sun') || conditionLower.contains('clear')) {
      return Icons.wb_sunny;
    }
    if (conditionLower.contains('snow')) return Icons.ac_unit;
    return Icons.cloud;
  }
}