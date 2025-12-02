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
  String? _overriddenAddress;

  @override
  void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
    // Get location as soon as app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationBloc.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // HOME TAB - Only Location Bar
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Clean top padding
        child: Column(
          children: [
            // Location Row (only thing visible on Home)
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: LocationWidget(
                    locationBloc: _locationBloc,
                    onLocationFound: (address) => Text(
                      _overriddenAddress ?? address,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onLocationError: (error) => const Text(
                      'Tap to set location',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    loadingWidget: const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _locationBloc.getCurrentLocation(),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_location_alt_outlined),
                  onPressed: _showEditAddressDialog,
                ),
              ],
            ),

            // Everything below this line is REMOVED
            // No welcome text, no quick actions, no extra content
          ],
        ),
      ),

      // Bookings Tab
      const Center(
        child: Text(
          'My Bookings',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      // Profile Tab
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('BookMySpa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
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
        indicatorColor: Colors.deepPurple.withOpacity(0.1),
      ),
    );
  }

  void _showEditAddressDialog() {
    final controller = TextEditingController(
      text: _overriddenAddress ?? _locationBloc.state.location?.address ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Location'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Enter area, city or pincode',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _overriddenAddress = controller.text.trim().isEmpty ? null : controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}