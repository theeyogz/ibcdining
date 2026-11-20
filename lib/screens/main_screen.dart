import 'package:flutter/material.dart';

import '../common.dart';
import 'home_screen.dart';
import 'pickup_screens.dart';
import 'profile_screens.dart';
import 'reservasi_screen.dart';

// ==========================================
// KERANGKA NAVIGASI UTAMA (BOTTOM NAV)
// ==========================================

class MainScreen extends StatefulWidget {
  final DemoUser user;
  final VoidCallback onLogout;

  const MainScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    const HomeView(),
    const PickupView(),
    const ReservasiView(),
    ProfileView(user: widget.user, onLogout: widget.onLogout),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.grey.shade200,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Pickup',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Reservasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
