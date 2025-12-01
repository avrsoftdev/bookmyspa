import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Your pages (expand with real content later)
  final List<Widget> _pages = const [
    Center(child: Text('Home Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(child: Text('Bookings Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
    Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Lets content flow behind the floating bar for immersion
      appBar: AppBar(title: const Text('BookMySpa')),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Centers the "floating" bar
      floatingActionButton: _buildFloatingNavBar(), // Our custom floating bar
    );
  }

  // Builds the floating, curved bottom nav bar
  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Side margins for floating feel
      decoration: BoxDecoration(
        color: Colors.white, // Or your brand color: Colors.deepPurple
        borderRadius: BorderRadius.circular(30), // Rounded for floating look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10), // Soft shadow below for elevation
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent, // No extra background
        elevation: 0, // No default shadow (we have custom)
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded, color: Colors.deepPurple),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_rounded),
            selectedIcon: Icon(Icons.event_rounded, color: Colors.deepPurple),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: Colors.deepPurple),
            label: 'Profile',
          ),
        ],
        indicatorColor: Colors.deepPurple.withOpacity(0.1), // Subtle active indicator
      ),
    );
  }
}