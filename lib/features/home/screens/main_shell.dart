// =============================================================================
// main_shell.dart — Shell de navegación con NavigationBar persistente
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../leaderboard/providers/leaderboard_provider.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../statistics/screens/statistics_screen.dart';
import 'home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeScreen(),
    StatisticsScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Registra listeners una sola vez. La sincronización inicial se difiere
    // al siguiente frame para no llamar notifyListeners() durante el build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HabitProvider>().addListener(_updateLeaderboard);
      context.read<ProfileProvider>().addListener(_updateLeaderboard);
      _updateLeaderboard();
    });
  }

  @override
  void dispose() {
    context.read<HabitProvider>().removeListener(_updateLeaderboard);
    context.read<ProfileProvider>().removeListener(_updateLeaderboard);
    super.dispose();
  }

  void _updateLeaderboard() {
    if (!mounted) return;
    final habits  = context.read<HabitProvider>();
    final profile = context.read<ProfileProvider>();
    context.read<LeaderboardProvider>().updateCurrentUser(
      name:        profile.name,
      avatarEmoji: profile.avatarEmoji,
      streak:      habits.globalStreak,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Estadísticas',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard_rounded),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
