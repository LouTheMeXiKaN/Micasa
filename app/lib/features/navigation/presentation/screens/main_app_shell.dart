import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MainAppShell extends StatefulWidget {
  final Widget child;
  
  const MainAppShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/my-events')) return 1;
    if (location.startsWith('/my-community')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    // Navigate to the appropriate route
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/my-events');
        break;
      case 2:
        context.go('/my-community');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, -1),
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.deepPurple,
          unselectedItemColor: AppColors.neutral500,
          selectedLabelStyle: AppTypography.textXs.copyWith(
            fontWeight: AppTypography.medium,
          ),
          unselectedLabelStyle: AppTypography.textXs,
          currentIndex: _calculateSelectedIndex(context),
          onTap: _onItemTapped,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined, size: 24),
              activeIcon: Icon(Icons.event, size: 24),
              label: 'My Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 24),
              activeIcon: Icon(Icons.people, size: 24),
              label: 'My Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}