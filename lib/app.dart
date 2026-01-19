import 'package:brews_wheather/presentation/LandingView/view/LandingView.dart';
import 'package:brews_wheather/presentation/auth/controller/auth_cubit.dart';
import 'package:brews_wheather/presentation/auth/view/login_screen.dart';
import 'package:brews_wheather/presentation/home/controller/home_screen_cubit.dart';
import 'package:brews_wheather/presentation/home/view/home_screen.dart';
import 'package:brews_wheather/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'logic/settings/settings_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();

    // Listen to Supabase auth state changes (including from deep links)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // Update AuthCubit when authentication state changes via deep link
      if (event == AuthChangeEvent.signedIn && session != null) {
        _authCubit.updateAuthState(true);
      } else if (event == AuthChangeEvent.signedOut) {
        _authCubit.updateAuthState(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => HomeScreenCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return state.isAuthenticated
                ? const LandingView()
                : const LoginScreen();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }
}
