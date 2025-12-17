import 'package:bookmyspa/src/features/location/presentation/widgets/floating_nav_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/location_app_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/spa_search_field.dart';
import 'package:bookmyspa/src/features/spa_browse/presentation/pages/category_spa_list_page.dart';
import 'package:bookmyspa/utils/constants/image.dart';
import 'package:flutter/material.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../bookings/presentation/pages/my_bookings_page.dart';
import '../../../spa_browse/presentation/pages/favorites_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../../core/di/di.dart';
// TODO: change this import to the actual path of your Images class
import '../../../../core/widgets/admob_banner_widget.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late LocationBloc _locationBloc;
  String? _overriddenAddress;
  final TextEditingController _searchController = TextEditingController();

  // Category data using your Images class
  final List<Map<String, String>> _categories = [
    {'icon': Images.massage, 'label': 'Massage'},
    {'icon': Images.pedicure, 'label': 'Pedicure'},
    {'icon': Images.manicure, 'label': 'Manicure'},
    {'icon': Images.skincare, 'label': 'Skin Care'},
    {'icon': Images.makeup, 'label': 'Makeup'},
    {'icon': Images.therapy, 'label': 'Therapy'},
    {'icon': Images.wax, 'label': 'Waxing'},
    {'icon': Images.bodytreatments, 'label': 'Bodycare'},
    {'icon': Images.bride, 'label': 'Bridal'},
    {'icon': Images.groom, 'label': 'Grooming'},
    {'icon': Images.haircut, 'label': 'Haircare'},
    {'icon': Images.menu, 'label': 'See More..'},
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _locationBloc = sl.get<LocationBloc>();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _locationBloc.getCurrentLocation(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: LocationAppBarTitle(
          locationBloc: _locationBloc,
          overriddenAddress: _overriddenAddress,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdMobBannerWidget(
                  adUnitId: 'ca-app-pub-7682628416837305/4512781378',
                ),
                SpaSearchField(controller: _searchController),
                const SizedBox(height: 20),
                _buildCategoryGrid(), // 👈 icons just below search bar
              ],
            ),
          ),
          const MyBookingsPage(),
          const FavoritesPage(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  // =========================
  // Category Grid Widget
  // =========================
  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 icons per row like Justdial
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8, // tweak if you want icons/text taller/shorter
      ),
      itemBuilder: (context, index) {
        final item = _categories[index];
        final label = item['label']!;
        return InkWell(
          onTap: label == 'See More..'
              ? null
              : () {
                  Navigator.of(context).pushNamed(
                    '/category-spas',
                    arguments: CategorySpasArgs(label),
                  );
                },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset(item['icon']!, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
