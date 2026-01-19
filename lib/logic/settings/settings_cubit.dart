

import 'package:hydrated_bloc/hydrated_bloc.dart';

class SettingsCubit extends HydratedCubit<bool> {
  SettingsCubit() : super(true);

  void toggleUnit() => emit(!state);

  @override
  bool fromJson(Map<String, dynamic> json) => json['celsius'];

  @override
  Map<String, dynamic> toJson(bool state) => {'celsius': state};
}
