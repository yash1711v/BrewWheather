import 'package:brews_wheather/presentation/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/weather/weather_cubit.dart';
import '../../../widgets/custom_navbar.dart';
import '../../home/controller/home_screen_cubit.dart';
import '../../home/controller/home_screen_state.dart';
import '../../search/view/search.dart';
import '../../settings/view/settings.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  PageController pageView = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherCubit(),
      child: Scaffold(
        extendBody: true,
        body: PageView(
          onPageChanged:  (int index) {
            context.read<HomeScreenCubit>().updateIndex(index);
          },
          physics: const NeverScrollableScrollPhysics(),
          controller:
          pageView,
          children: [
            // Replace with your actual screens
            const HomeScreen(),
            const SearchScreen(),
            const SettingsScreen()
          ],
        ),
        bottomNavigationBar: BlocBuilder<HomeScreenCubit, HomeScreenState>(
          builder: (context, state) {
            return CustomBottomNavBar(
              currentIndex: state.currentIndex ?? 0,
              onDestinationSelected: (i) {
                pageView.jumpToPage(i);
                context.read<HomeScreenCubit>().updateIndex(i);
              },
            );
          },
        ),
      ),
    );
  }
}