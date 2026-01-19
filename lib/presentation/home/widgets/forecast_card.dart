// lib/features/home/widgets/forecast_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ForecastCard extends StatelessWidget {
  final String day;
  final IconData icon;
  final int temperature;
  final int lowTemp;
  final bool isToday;

  const ForecastCard({
    super.key,
    required this.day,
    required this.icon,
    required this.temperature,
    required this.lowTemp,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.primaryBlueWithOpacity(0.15)
            : AppTheme.textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isToday
              ? AppTheme.primaryBlueWithOpacity(0.3)
              : AppTheme.textPrimary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            day.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            icon,
            color: isToday ? AppTheme.primaryBlue : AppTheme.textPrimary,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            '$temperature°',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$lowTemp°',
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}