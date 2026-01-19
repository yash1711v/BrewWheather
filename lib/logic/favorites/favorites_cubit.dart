import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/favorites_repository.dart';

class FavoritesCubit extends Cubit<Stream> {
  FavoritesCubit() : super(const Stream.empty());

  final repo = FavoritesRepository();

  void load() {
    emit(repo.getFavoritesStream());
  }
}
