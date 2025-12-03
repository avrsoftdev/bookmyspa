import 'package:bookmyspa/src/features/location/presentation/widgets/floating_nav_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/location_app_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/spa_search_field.dart';
import 'package:flutter/material.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../../core/di/di.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late LocationBloc _locationBloc;
  String? _overriddenAddress;
  final TextEditingController _searchController = TextEditingController();

  @override void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _locationBloc.getCurrentLocation());
  }

  @override void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: LocationAppBarTitle(locationBloc: _locationBloc, overriddenAddress: _overriddenAddress),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [SpaSearchField(controller: _searchController)]),
          ),
          const Center(child: Text('My Bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const Center(child: Text('Favourites', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          const ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingNavBar(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}