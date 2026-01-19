// lib/features/forecast/view/forecast_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/weather/weather_cubit.dart';
import '../../home/widgets/forecast_card.dart';

class ForecastDetailsScreen extends StatelessWidget {
  const ForecastDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "5-Day Forecast Details",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: AppTheme.backgroundGradientDecoration,
        child: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            if (state.loading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              );
            }

            if (state.forecast == null || state.forecast!.isEmpty) {
              return Center(
                child: Text(
                  'No forecast data available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.forecast!.length,
                itemBuilder: (context, index) {
                  final forecast = state.forecast![index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppTheme.primaryBlueWithOpacity(0.15)
                            : AppTheme.textPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: index == 0
                              ? AppTheme.primaryBlueWithOpacity(0.3)
                              : AppTheme.textPrimary.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    forecast.date,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    forecast.condition,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _getWeatherIcon(forecast.condition),
                                color: index == 0
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textPrimary,
                                size: 48,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                'Temperature',
                                '${forecast.temp}°',
                                Icons.thermostat,
                              ),
                              _buildDetailItem(
                                'High',
                                '${forecast.max}°',
                                Icons.arrow_upward,
                              ),
                              _buildDetailItem(
                                'Low',
                                '${forecast.min}°',
                                Icons.arrow_downward,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Divider(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildDetailItem(
                                'Humidity',
                                '${forecast.humidity}%',
                                Icons.water_drop,
                              ),
                              _buildDetailItem(
                                'Wind',
                                '${forecast.windSpeed} mph',
                                Icons.air,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 24,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
    if (conditionLower.contains('storm') || conditionLower.contains('thunder')) {
      return Icons.thunderstorm;
    }
    return Icons.cloud;
  }
}