import 'package:bookmyspa/src/features/auth/presentation/widgets/location_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationBloc.getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // HOME TAB - Only the beautiful reusable location bar
      Column(
        children: [
          LocationSearchBar(
            locationBloc: _locationBloc,
            overriddenAddress: _overriddenAddress,
            onRefresh: () => _locationBloc.getCurrentLocation(),
            onEdit: _showEditAddressDialog,
          ),
          // Nothing else below — clean & minimal
        ],
      ),

      const Center(
        child: Text('My Bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),

      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('BookMySpa'), backgroundColor: Colors.transparent, elevation: 0),
      body: IndexedStack(index: _currentIndex, children: pages),
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
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), selectedIcon: Icon(Icons.home_rounded, color: Colors.deepPurple), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_rounded), selectedIcon: Icon(Icons.event_rounded, color: Colors.deepPurple), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_rounded), selectedIcon: Icon(Icons.person_rounded, color: Colors.deepPurple), label: 'Profile'),
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
      builder: (_) => AlertDialog(
        title: const Text('Set Location'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(hintText: 'Enter area, city or pincode', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final text = controller.text.trim();
                _overriddenAddress = text.isEmpty ? null : text;
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