import 'package:flutter/material.dart';

import '../../../core/location/location_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/favorites_repository.dart';
import '../../../data/repositories/search_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final search = TextEditingController();
  List<Map<String, dynamic>> results = [];
  final _favoritesRepo = FavoritesRepository();
  final _searchRepo = SearchRepository();
  final LocationService _locationService = LocationService();
  bool isLoading = false;
  String selectedTab = 'current'; // current, recent, trending
  Set<String> favoriteCities = {}; // Track favorited cities
  List<Map<String, dynamic>> favoritesList = []; // Full favorites list
  List<Map<String, dynamic>> nearbyCities = []; // Nearby cities based on location
  String? currentCity;
  double? currentLat;
  double? currentLon;

  @override
  void initState() {
    super.initState();
    loadFavorites();
    _loadNearbyCities();
  }

  Future<void> loadFavorites() async {
    final favorites = await _favoritesRepo.getFavorites();
    if (mounted) {
      setState(() {
        favoritesList = favorites;
        favoriteCities = favorites.map((f) => f['city_name'] as String).toSet();
      });
    }
  }

  Future<void> _loadNearbyCities() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentPosition() ??
          await _locationService.getLastKnownPosition();

      if (position == null) {
        // Fallback to default location (Ghaziabad)
        if (mounted) {
          setState(() {
            currentLat = 28.6711;
            currentLon = 77.4120;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            currentLat = position.latitude;
            currentLon = position.longitude;
          });
        }
      }

      // Get current city using reverse geocoding
      if (currentLat != null && currentLon != null) {
        currentCity = await _searchRepo.getCityNameFromCoordinates(
          currentLat!,
          currentLon!,
        );

        // Get nearby cities - search for known nearby cities based on region
        await _fetchNearbyCities(currentLat!, currentLon!);
      }
    } catch (e) {
      debugPrint('Error loading nearby cities: $e');
      // Use default nearby cities if location fails
      if (mounted) {
        _loadDefaultNearbyCities();
      }
    }
  }

  Future<void> _fetchNearbyCities(double lat, double lon) async {
    // Define nearby cities to search for based on location region
    // For Ghaziabad area: Delhi, Modinagar, Muradnagar, Meerut, Noida, etc.
    final nearbyCityNames = [
      'Delhi',
      'Noida',
      'Meerut',
      'Modinagar',
      'Muradnagar',
      'Hapur',
      'Bulandshahr',
    ];

    try {
      final cities = await _searchRepo.getNearbyCities(
        lat,
        lon,
        nearbyCityNames,
        100, // max distance in km
      );

      if (mounted) {
        setState(() {
          nearbyCities = cities.take(6).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching nearby cities: $e');
      if (mounted) {
        _loadDefaultNearbyCities();
      }
    }
  }

  void _loadDefaultNearbyCities() {
    // Default nearby cities if location fails
    if (mounted) {
      setState(() {
        nearbyCities = [
          {'name': 'Delhi', 'country': 'IN', 'lat': 28.6139, 'lon': 77.2090, 'distance': 30.0},
          {'name': 'Noida', 'country': 'IN', 'lat': 28.5355, 'lon': 77.3910, 'distance': 40.0},
        ];
      });
    }
  }

  Future searchCity() async {
    if (search.text.isEmpty) return;

    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      final searchResults = await _searchRepo.searchCity(search.text, limit: 5);
      if (mounted) {
        setState(() => results = searchResults);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> toggleFavorite(String cityName, double lat, double lon) async {
    try {
      if (favoriteCities.contains(cityName)) {
        await _favoritesRepo.removeCity(cityName);
        if (mounted) {
          setState(() => favoriteCities.remove(cityName));
        }
      } else {
        await _favoritesRepo.addCity(cityName, lat, lon);
        if (mounted) {
          setState(() => favoriteCities.add(cityName));
        }
      }
      // Reload favorites to ensure UI is in sync with database
      await loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }

  IconData getWeatherIcon(int index) {
    final icons = [
      Icons.cloud,
      Icons.wb_sunny,
      Icons.cloud,
      Icons.nightlight_round,
    ];
    return icons[index % icons.length];
  }

  Color getWeatherIconColor(int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.blue,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        title: const Text(
          'Search City',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: search,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  prefixIcon: Icon(Icons.search, color: AppTheme.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => searchCity(),
              ),
            ),
          ),

          // Tab Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('Current Location', 'current', Icons.location_on),
                  const SizedBox(width: 8),
                  _buildTabButton('Recent', 'recent', Icons.history),
                  // const SizedBox(width: 8),
                  // _buildTabButton('Trending', 'trending', Icons.trending_up),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Favorite Cities Section
          if (favoritesList.isNotEmpty && results.isEmpty && !isLoading 
          && selectedTab == "recent") ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'FAVORITE CITIES',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Search Results Section
          if (results.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'SEARCH RESULTS',
                style: TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Results List
          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
                : results.isNotEmpty
                ? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (_, i) {
                final city = results[i];
                final cityName = city['name'];
                final country = city['country'];
                final isFavorite = favoriteCities.contains(cityName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: getWeatherIconColor(i).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getWeatherIcon(i),
                        color: getWeatherIconColor(i),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      cityName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      country,
                      style: TextStyle(
                        color: AppTheme.textQuaternary,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(i * 5 + 14)}°',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.add_circle_outline,
                            color: isFavorite
                                ? AppTheme.primaryBlue
                                : AppTheme.textTertiary,
                            size: 28,
                          ),
                          onPressed: () {
                            toggleFavorite(
                              cityName,
                              city['lat'] as double,
                              city['lon'] as double,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : selectedTab == "recent" &&
            favoritesList.isNotEmpty
                ? _buildFavoritesList()
                : _buildNearbyLocations(),
          ),
          
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value, IconData icon) {
    final isSelected = selectedTab == value;
    return GestureDetector(
      onTap: () {
        
        if (mounted) {
          
          setState(() { selectedTab = value;
          results.clear();
          });
        }
        if(value == 'current') {
          _loadNearbyCities();
        } else if(value == "recent"){
          loadFavorites();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.backgroundCard : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.textTertiary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: favoritesList.length,
      itemBuilder: (_, i) {
        final favorite = favoritesList[i];
        final cityName = favorite['city_name'] as String;
        final lat = favorite['lat'] as double;
        final lon = favorite['lon'] as double;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlueWithOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: AppTheme.primaryBlue,
                size: 28,
              ),
            ),
            title: Text(
              cityName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppTheme.textQuaternary,
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                  onPressed: () {
                    toggleFavorite(cityName, lat, lon);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearbyLocations() {
    if (nearbyCities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Loading nearby locations...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NEARBY LOCATIONS',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                if (currentCity != null)
                  Text(
                    'Near $currentCity',
                    style: TextStyle(
                      color: AppTheme.textQuaternary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Show nearby cities in a grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: nearbyCities.length,
              itemBuilder: (context, index) {
                final city = nearbyCities[index];
                final cityName = city['name'] as String;
                final distance = city['distance'] as double?;
                final distanceText = distance != null
                    ? '${distance.toStringAsFixed(0)} km'
                    : 'Nearby';

                return _buildNearbyCard(
                  cityName,
                  distanceText,
                  city['lat'] as double,
                  city['lon'] as double,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyCard(String city, String distance, double lat, double lon) {
    final isFavorite = favoriteCities.contains(city);
    
    return GestureDetector(
      onTap: () {
        // Navigate or search for this city
        search.text = city;
        searchCity();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    distance,
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppTheme.primaryBlue : AppTheme.textTertiary,
                    size: 20,
                  ),
                  onPressed: () {
                    toggleFavorite(city, lat, lon);
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                city,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueWithOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud,
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}