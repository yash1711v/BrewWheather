// lib/features/home/view/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/settings/settings_cubit.dart';
import '../../../logic/weather/weather_cubit.dart';

import '../../ForecastDetails/view/forecast_details_screen.dart';

import '../widgets/forecast_card.dart';
import '../widgets/main_wheather.dart';
import '../widgets/section_header.dart';
import '../widgets/weather_stats.dart';
import '../widgets/wheather_header.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  double? _lat;
  double? _lon;
  WeatherCubit? _weatherCubit; // Store reference to cubit

  // #region agent log
  void _log(String location, String message, Map<String, dynamic> data, String hypothesisId) {
    try {
      final logEntry = {
        'location': location,
        'message': message,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId
      };
      final file = File('/Volumes/Yashverma/brews_wheather/.cursor/debug.log');
      // Simple JSON serialization
      final jsonStr = '{"location":"$location","message":"$message","data":${_mapToJson(data)},"timestamp":${logEntry['timestamp']},"sessionId":"${logEntry['sessionId']}","runId":"${logEntry['runId']}","hypothesisId":"$hypothesisId"}\n';
      if (file.existsSync()) {
        file.writeAsStringSync('${file.readAsStringSync()}$jsonStr', mode: FileMode.write);
      } else {
        file.writeAsStringSync(jsonStr, mode: FileMode.write);
      }
    } catch (_) {}
  }
  
  String _mapToJson(Map<String, dynamic> map) {
    final entries = map.entries.map((e) {
      final value = e.value;
      if (value is String) {
        return '"${e.key}":"$value"';
      } else if (value is bool || value is num) {
        return '"${e.key}":$value';
      } else {
        return '"${e.key}":"${value.toString()}"';
      }
    }).join(',');
    return '{$entries}';
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    // #region agent log
    _log('home_screen.dart:initState', 'initState called', {'mounted': mounted}, 'A');
    // #endregion
    
    // Delay location fetch until after widget is built and provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // #region agent log
      _log('home_screen.dart:addPostFrameCallback', 'PostFrameCallback executed', {'mounted': mounted, 'hasCubit': _weatherCubit != null}, 'A');
      // #endregion
      
      if (mounted) {
        _getCurrentLocation();
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    // #region agent log
    _log('home_screen.dart:_getCurrentLocation', 'Starting location fetch', {'mounted': mounted, 'hasCubit': _weatherCubit != null}, 'A');
    // #endregion
    
    try {
      final position = await _locationService.getCurrentPosition();
      // #region agent log
      _log('home_screen.dart:_getCurrentLocation', 'Position received', {'hasPosition': position != null, 'mounted': mounted}, 'A');
      // #endregion
      
      if (position != null) {
        if (mounted) {
          setState(() {
            _lat = position.latitude;
            _lon = position.longitude;
          });
          // #region agent log
          _log('home_screen.dart:_getCurrentLocation', 'Before accessing WeatherCubit', {'hasCubitRef': _weatherCubit != null, 'mounted': mounted}, 'B');
          // #endregion
          
          // Reload weather with current location - only use stored cubit reference
          if (_weatherCubit == null) {
            // #region agent log
            _log('home_screen.dart:_getCurrentLocation', 'WeatherCubit is null, scheduling for after build', {'mounted': mounted}, 'B');
            // #endregion
            // Schedule to run after build completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _weatherCubit != null) {
                _weatherCubit!.load(
                  _lat!,
                  _lon!,
                  context.read<SettingsCubit>().state,
                );
              }
            });
            return;
          }
          
          try {
            // #region agent log
            _log('home_screen.dart:_getCurrentLocation', 'WeatherCubit accessed successfully', {'usedStoredRef': true}, 'B');
            // #endregion
            
            _weatherCubit!.load(
              _lat!,
              _lon!,
              context.read<SettingsCubit>().state,
            );
          } catch (e) {
            // #region agent log
            _log('home_screen.dart:_getCurrentLocation', 'Error accessing WeatherCubit', {'error': e.toString()}, 'B');
            // #endregion
            rethrow;
          }
        }
      } else {
        // #region agent log
        _log('home_screen.dart:_getCurrentLocation', 'Position is null, calling _useDefaultLocation', {'mounted': mounted}, 'C');
        // #endregion
        // Fallback to default location if permission denied
        _useDefaultLocation();
      }
    } catch (e) {
      // #region agent log
      _log('home_screen.dart:_getCurrentLocation', 'Exception in _getCurrentLocation', {'error': e.toString(), 'mounted': mounted}, 'C');
      // #endregion
      
      if (mounted) {
        _useDefaultLocation();
      }
    }
  }

  void _useDefaultLocation() {
    // #region agent log
    _log('home_screen.dart:_useDefaultLocation', 'Using default location', {'mounted': mounted, 'hasCubit': _weatherCubit != null}, 'D');
    // #endregion
    
    if (mounted) {
      setState(() {
        _lat = 28.61; // Default fallback (Ghaziabad)
        _lon = 77.20;
      });
      
      // #region agent log
      _log('home_screen.dart:_useDefaultLocation', 'Before accessing WeatherCubit', {'hasCubitRef': _weatherCubit != null}, 'D');
      // #endregion
      
      // Only use stored cubit reference - if it's null, schedule for after build
      if (_weatherCubit == null) {
        // #region agent log
        _log('home_screen.dart:_useDefaultLocation', 'WeatherCubit is null, scheduling for after build', {'mounted': mounted}, 'D');
        // #endregion
        // Schedule to run after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _weatherCubit != null) {
            _weatherCubit!.load(
              _lat!,
              _lon!,
              context.read<SettingsCubit>().state,
            );
          }
        });
        return;
      }
      
      // Use stored cubit reference
      try {
        // #region agent log
        _log('home_screen.dart:_useDefaultLocation', 'WeatherCubit accessed successfully', {'usedStoredRef': true}, 'D');
        // #endregion
        
        _weatherCubit!.load(
          _lat!,
          _lon!,
          context.read<SettingsCubit>().state,
        );
      } catch (e) {
        // #region agent log
        _log('home_screen.dart:_useDefaultLocation', 'Error accessing WeatherCubit', {'error': e.toString()}, 'D');
        // #endregion
        rethrow;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // #region agent log
    _log('home_screen.dart:build', 'build called', {'hasLat': _lat != null, 'hasLon': _lon != null}, 'E');
    // #endregion
    
    // WeatherCubit is now provided at LandingView level, so we can access it directly
    try {
      _weatherCubit = context.read<WeatherCubit>();
      // #region agent log
      _log('home_screen.dart:build', 'WeatherCubit retrieved from context', {'hasCubit': _weatherCubit != null}, 'E');
      // #endregion
    } catch (e) {
      // #region agent log
      _log('home_screen.dart:build', 'Error retrieving WeatherCubit from context', {'error': e.toString()}, 'E');
      // #endregion
    }
    
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Weather Dashboard",
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

              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppTheme.errorRed,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load weather data',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_lat != null && _lon != null) {
                            context.read<WeatherCubit>().load(
                                _lat!, _lon!, context.read<SettingsCubit>().state);
                          } else {
                            _getCurrentLocation();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state.weather == null) return const SizedBox();

              return RefreshIndicator(
                color: AppTheme.primaryBlue,
                backgroundColor: AppTheme.backgroundSecondary,
                onRefresh: () async {
                  await _getCurrentLocation();
                  if (_lat != null && _lon != null && mounted) {
                    context.read<WeatherCubit>().load(
                        _lat!, _lon!, context.read<SettingsCubit>().state);
                  }
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
                  children: [
                    // Header
                    WeatherHeader(
                      location: state.weather!.location,
                      isOnline: state.isOnline,
                    ),

                    const SizedBox(height: 20),

                    // Main Weather Card
                    MainWeatherCard(
                      temperature: state.weather!.temp,
                      condition: state.weather!.condition,
                      highTemp: state.weather!.max,
                      lowTemp: state.weather!.min,
                    ),

                    const SizedBox(height: 20),

                    // Weather Stats
                    WeatherStatsRow(
                      humidity: state.weather!.humidity,
                      windSpeed: state.weather!.windSpeed,
                      uvIndex: state.weather!.uvIndex,
                    ),

                    const SizedBox(height: 32),

                    // 5-Day Forecast Section
                    // In your home_screen.dart, update the SectionHeader:
                    SectionHeader(
                      title: '5-Day Forecast',
                      onDetailsTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<WeatherCubit>(),
                              child: const ForecastDetailsScreen(),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Forecast Cards
                    if (state.forecast != null && state.forecast!.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: state.forecast!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final forecast = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index < state.forecast!.length - 1 ? 12 : 0,
                              ),
                              child: ForecastCard(
                                day: forecast.date,
                                icon: _getWeatherIcon(forecast.condition),
                                temperature: forecast.temp,
                                lowTemp: forecast.min,
                                isToday: index == 0,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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
    if (conditionLower.contains('storm') || conditionLower.contains('thunder')) {
      return Icons.thunderstorm;
    }
    return Icons.cloud;
  }
}