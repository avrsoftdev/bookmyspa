import 'package:bookmyspa/src/features/location/presentation/widgets/floating_nav_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/location_app_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/spa_search_field.dart';
import 'package:bookmyspa/src/features/spa_browse/presentation/pages/category_subcategories_page.dart';
import 'package:bookmyspa/utils/constants/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookmyspa/l10n/app_localizations.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../bookings/presentation/pages/my_bookings_page.dart';
import '../../../spa_browse/presentation/pages/favorites_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../../core/di/di.dart';
// TODO: change this import to the actual path of your Images class
import '../../../../core/widgets/admob_banner_widget.dart';
import '../../../../core/theme/locale_cubit.dart';

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

  final List<String> _icons = [
    Images.massage,
    Images.pedicure,
    Images.manicure,
    Images.skincare,
    Images.makeup,
    Images.therapy,
    Images.wax,
    Images.bodytreatments,
    Images.bride,
    Images.groom,
    Images.haircut,
    Images.menu,
  ];
  final List<String> _canonicalLabels = [
    'Massage',
    'Pedicure',
    'Manicure',
    'Skin Care',
    'Makeup',
    'Therapy',
    'Waxing',
    'Bodycare',
    'Bridal',
    'Grooming',
    'Haircare',
    'See More..',
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (code) => context.read<LocaleCubit>().setLanguage(code),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'hi', child: Text('हिंदी')),
            ],
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
                SpaSearchField(controller: _searchController),
                const SizedBox(height: 20),
                _buildCategoryGrid(),
                const SizedBox(height: 20),
                AdMobBannerWidget(
                  adUnitId: kDebugMode
                      ? 'ca-app-pub-3940256099942544/6300978111'
                      : 'ca-app-pub-7682628416837305/4512781378',
                ),
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
      itemCount: _icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 icons per row like Justdial
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8, // tweak if you want icons/text taller/shorter
      ),
      itemBuilder: (context, index) {
        final l10n = AppLocalizations.of(context)!;
        final label = switch (index) {
          0 => l10n.categoryMassage,
          1 => l10n.categoryPedicure,
          2 => l10n.categoryManicure,
          3 => l10n.categorySkinCare,
          4 => l10n.categoryMakeup,
          5 => l10n.categoryTherapy,
          6 => l10n.categoryWaxing,
          7 => l10n.categoryBodycare,
          8 => l10n.categoryBridal,
          9 => l10n.categoryGrooming,
          10 => l10n.categoryHaircare,
          11 => l10n.seeMore,
          _ => '',
        };
        return InkWell(
          onTap: index == 11
              ? null
              : () {
                  Navigator.of(context).pushNamed(
                    '/category-subcategories',
                    arguments: CategorySubcategoriesArgs(
                      _canonicalLabels[index],
                    ),
                  );
                },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: Image.asset(_icons[index], fit: BoxFit.contain),
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
