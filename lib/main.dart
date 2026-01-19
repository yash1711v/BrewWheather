import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/env/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      // detectSessionInUri is true by default - will automatically detect auth tokens in deep links
      detectSessionInUri: true,
    ),
  );

  // Listen for deep links from email verification
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    final Session? session = data.session;

      debugPrint('Auth state changed: $event');


    if (event == AuthChangeEvent.signedIn && session != null) {
      debugPrint('User signed in via deep link: ${session.user.email}');
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      debugPrint('Token refreshed');
    }



  });

  final dir = HydratedStorageDirectory((await getTemporaryDirectory()).path);
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: dir,
  );

  runApp(const App());
}
