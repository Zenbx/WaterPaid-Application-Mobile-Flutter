import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_meters_screen.dart';
import 'admin_users_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_create_meter_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const AdminMetersScreen(),
    const AdminUsersScreen(),
    const AdminProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
            icon: Icon(LucideIcons.gauge),
            selectedIcon: Icon(LucideIcons.gauge),
            label: 'Meters',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            selectedIcon: Icon(LucideIcons.users),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            selectedIcon: Icon(LucideIcons.user),
            label: 'Account',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex ==
              1 // Only on Meters screen
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminCreateMeterScreen(),
                  ),
                );
              },
              backgroundColor: colors.accent,
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
    );
  }
}
