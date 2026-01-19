import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';

// lib/logic/weather/weather_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';

class WeatherState {
  final WeatherModel? weather;
  final List<ForecastModel>? forecast;
  final bool loading;
  final String? error;
  final bool isOnline;
  final DateTime? lastUpdated;

  WeatherState({
    this.weather,
    this.forecast,
    this.loading = false,
    this.error,
    this.isOnline = true,
    this.lastUpdated,
  });

  WeatherState copyWith({
    WeatherModel? weather,
    List<ForecastModel>? forecast,
    bool? loading,
    String? error,
    bool? isOnline,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      isOnline: isOnline ?? this.isOnline,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherState());

  final repo = WeatherRepository();

  Future<void> load(double lat, double lon, bool celsius) async {
    try {
      emit(state.copyWith(loading: true, error: null));

      final weather = await repo.getCurrent(lat, lon, celsius);
      final forecast = await repo.getForecast(lat, lon, celsius);

      emit(WeatherState(
        weather: weather,
        forecast: forecast,
        loading: false,
        isOnline: true,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString(),
        isOnline: false,
      ));
    }
  }

  void updateOnlineStatus(bool isOnline) {
    emit(state.copyWith(isOnline: isOnline));
  }
}


