import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/history/history_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/meter/link_meter_screen.dart';
import 'features/refill/refill_screen.dart';

import 'core/notification_service.dart';
import 'features/admin/admin_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: WaterPaidApp()));
}

class WaterPaidApp extends ConsumerWidget {
  const WaterPaidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);

    Widget getHome() {
      if (authState.isInitializing) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (authState.isAuthenticated) {
        return authState.isAdmin ? AdminMainScreen() : MainScreen();
      }
      return const LoginScreen();
    }

    return MaterialApp(
      title: 'WaterPaid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: getHome(),
      routes: {
        '/link-meter': (context) => const LinkMeterScreen(),
        '/refill': (context) => const RefillScreen(),
        '/admin-main': (context) => AdminMainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            selectedIcon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.history),
            selectedIcon: Icon(LucideIcons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.user),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'link',
                  onPressed: () => Navigator.pushNamed(context, '/link-meter'),
                  backgroundColor: colors.surface,
                  child: Icon(LucideIcons.plus, color: colors.accent),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'refill',
                  onPressed: () => Navigator.pushNamed(context, '/refill'),
                  backgroundColor: colors.accent,
                  child: const Icon(LucideIcons.droplets, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }
}
