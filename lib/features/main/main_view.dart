import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../dashboard/views/dashboard_view.dart';
import '../files/views/explorer_view.dart';
import '../profile/views/profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardView(),
    ExplorerView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          elevation: 0,
          height: 65,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.folder_rounded, color: AppColors.primary),
              label: 'Files',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
