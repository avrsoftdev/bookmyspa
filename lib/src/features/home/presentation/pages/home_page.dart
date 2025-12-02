import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/widgets/location_widget.dart';
import '../../../../core/di/di.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
    // Automatically get location when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationBloc.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = fb.FirebaseAuth.instance.currentUser?.email ?? '';
    final pages = <Widget>[
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _locationBloc.getCurrentLocation(),
                        icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                        tooltip: 'Refresh location',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LocationWidget(
                    locationBloc: _locationBloc,
                    onLocationFound: (address) => Text(
                      address,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onLocationError: (error) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to get location',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                    loadingWidget: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Detecting your location...'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Welcome Section
            const Text(
              'Welcome to BookMySpa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (email.isNotEmpty)
              Text(
                'Signed in as $email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            
            const SizedBox(height: 30),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.spa,
                    title: 'Book Spa',
                    onTap: () {
                      // Navigate to spa booking
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.history,
                    title: 'My Bookings',
                    onTap: () {
                      setState(() => _currentIndex = 1);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const Center(child: Text('Bookings Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      const ProfileScreen(),
    ];
    return Scaffold(
      extendBody: true, // Lets content flow behind the floating bar for immersion
      appBar: AppBar(title: const Text('BookMySpa')),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Centers the "floating" bar
      floatingActionButton: _buildFloatingNavBar(), // Our custom floating bar
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
            color: Colors.black.withValues(alpha: 0.1),
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
        indicatorColor: Colors.deepPurple.withValues(alpha: 0.1), // Subtle active indicator
      ),
    );
  }
}
