// lib/data/repositories/weather_repository.dart
import 'package:brews_wheather/core/env/env.dart';
import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class WeatherRepository {
  final String apiKey = Env.weatherApiKey; // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  late final Dio _dio;

  WeatherRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors for logging (optional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print(object),
      ),
    );
  }

  Future<WeatherModel> getCurrent(double lat, double lon, bool celsius) async {
    final units = celsius ? 'metric' : 'imperial';

    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': units,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load weather data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Location not found.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<ForecastModel>> getForecast(double lat, double lon, bool celsius) async {
    final units = celsius ? 'metric' : 'imperial';

    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': units,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['list'];

        // Group forecasts by day and get one forecast per day
        final Map<String, ForecastModel> dailyForecasts = {};

        for (var item in list) {
          final forecast = ForecastModel.fromJson(item);
          final date = forecast.date;

          // Keep only the first forecast for each day (or you can average them)
          if (!dailyForecasts.containsKey(date)) {
            dailyForecasts[date] = forecast;
          }

          // Stop after getting 5 days
          if (dailyForecasts.length >= 5) break;
        }

        return dailyForecasts.values.toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load forecast data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key. Please check your configuration.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Location not found.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Optional: Add a method to cancel ongoing requests
  void cancelRequests() {
    _dio.close(force: true);
  }
}