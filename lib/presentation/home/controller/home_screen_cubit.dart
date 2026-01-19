import 'package:bloc/bloc.dart';

import 'home_screen_state.dart';



class HomeScreenCubit extends Cubit<HomeScreenState> {
  HomeScreenCubit() : super(HomeScreenState(0));


  void updateIndex(int index) {
    emit(HomeScreenState(index));
  }
}
