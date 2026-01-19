// lib/data/repositories/search_repository.dart
import 'package:brews_wheather/core/env/env.dart';
import 'package:brews_wheather/core/location/location_service.dart';
import 'package:dio/dio.dart';

class SearchRepository {
  final String apiKey = Env.weatherApiKey;
  final String baseUrl = 'https://api.openweathermap.org/geo/1.0';
  final LocationService _locationService = LocationService();

  late final Dio _dio;

  SearchRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );
  }

  /// Search for cities by name
  /// Returns a list of city suggestions
  Future<List<Map<String, dynamic>>> searchCity(String query, {int limit = 5}) async {
    try {
      final response = await _dio.get(
        '/direct',
        queryParameters: {
          'q': query,
          'limit': limit,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data.map((item) => {
          'name': item['name'] as String,
          'country': item['country'] as String,
          'lat': item['lat'] as double,
          'lon': item['lon'] as double,
          'state': item['state'] as String?,
        }).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search cities: ${response.statusCode}',
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
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Reverse geocoding - Get city name from coordinates
  Future<String?> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'limit': 1,
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        if (data.isNotEmpty) {
          return data[0]['name'] as String?;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get nearby cities by searching for specific city names
  /// Returns a list of cities with distance information
  Future<List<Map<String, dynamic>>> getNearbyCities(
    double lat,
    double lon,
    List<String> cityNames,
    double maxDistanceKm,
  ) async {
    List<Map<String, dynamic>> cities = [];

    for (String cityName in cityNames) {
      try {
        final res = await _dio.get(
          '/direct',
          queryParameters: {
            'q': cityName,
            'limit': 1,
            'appid': apiKey,
          },
        );

        if (res.statusCode == 200 && res.data != null && (res.data as List).isNotEmpty) {
          final city = res.data[0];
          final cityLat = city['lat'] as double;
          final cityLon = city['lon'] as double;

          // Calculate distance from current location
          final distance = _locationService.calculateDistance(lat, lon, cityLat, cityLon);

          // Only include cities within max distance
          if (distance <= maxDistanceKm) {
            cities.add({
              'name': city['name'] as String,
              'country': city['country'] as String,
              'lat': cityLat,
              'lon': cityLon,
              'distance': distance,
            });
          }
        }
      } catch (e) {
        // Continue with next city if one fails
        continue;
      }
    }

    // Sort by distance
    cities.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    return cities;
  }
}
