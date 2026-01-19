import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/settings/settings_cubit.dart';
import '../../auth/controller/auth_cubit.dart';
import '../../auth/view/login_screen.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final celsius = context.watch<SettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text("Temperature in Celsius"),
            value: celsius,
            onChanged: (_) => context.read<SettingsCubit>().toggleUnit(),
          ),
          ListTile(
            title: const Text("Sign Out"),
            onTap: () async {
              await context.read<AuthCubit>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
          )
        ],
      ),
    );
  }
}
