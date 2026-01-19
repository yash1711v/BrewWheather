import 'package:equatable/equatable.dart';

 class HomeScreenState extends Equatable {
   final int? currentIndex;
  const HomeScreenState(this.currentIndex);




  @override
  List<Object> get props => [
        currentIndex ?? 0,
  ];
}


