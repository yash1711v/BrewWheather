import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  final supabase = Supabase.instance.client;

  Future<void> addCity(String name, double lat, double lon) async {
    await supabase.from('favorite_cities').insert({
      'city_name': name,
      'lat': lat,
      'lon': lon,
      'user_id': supabase.auth.currentUser!.id,
    });
  }

  Future<void> removeCity(String cityName) async {
    await supabase
        .from('favorite_cities')
        .delete()
        .eq('city_name', cityName)
        .eq('user_id', supabase.auth.currentUser!.id);
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await supabase
        .from('favorite_cities')
        .select()
        .eq('user_id', supabase.auth.currentUser!.id);
    debugPrint("Favorites response: ${response}");
    return List<Map<String, dynamic>>.from(response);
  }

  Stream getFavoritesStream() {
    return supabase
        .from('favorite_cities')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentUser!.id);
  }
}
