// lib/features/home/widgets/weather_stats_row.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WeatherStatsRow extends StatelessWidget {
  final int humidity;
  final int windSpeed;
  final String uvIndex;

  const WeatherStatsRow({
    super.key,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.water_drop,
            label: 'Humidity',
            value: '$humidity%',
            color: AppTheme.primaryBlue,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textPrimary.withOpacity(0.1),
          ),
          _buildStatItem(
            icon: Icons.air,
            label: 'Wind',
            value: '$windSpeed mph',
            color: AppTheme.primaryBlue,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textPrimary.withOpacity(0.1),
          ),
          _buildStatItem(
            icon: Icons.wb_sunny_outlined,
            label: 'UV Index',
            value: uvIndex,
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}