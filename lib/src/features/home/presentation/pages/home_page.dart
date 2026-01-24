import 'package:bookmyspa/src/features/location/presentation/widgets/floating_nav_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/location_app_bar.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/spa_search_field.dart';
import 'package:bookmyspa/src/features/spa_browse/presentation/pages/category_subcategories_page.dart';
import 'package:bookmyspa/utils/constants/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../bookings/presentation/pages/my_bookings_page.dart';
import '../../../spa_browse/presentation/pages/favorites_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../../core/di/di.dart';
// TODO: change this import to the actual path of your Images class
import '../../../../core/widgets/admob_banner_widget.dart';
import '../../../spa_browse/presentation/pages/spa_detail_page.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_all_approved_spas_usecase.dart';
import 'dart:math' as math;
import '../../../../core/services/deep_link_service.dart';

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
  StreamSubscription<String>? _linkSub;
  final FocusNode _searchFocus = FocusNode();
  List<SpaEntity> _allSpas = const [];
  StreamSubscription<List<SpaEntity>>? _spasSub;
  List<_SearchSuggestion> _suggestions = const [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _locationBloc.getCurrentLocation();
      _handleInitialDeepLink();
      _subscribeDeepLinks();
      final useCase = sl.get<StreamAllApprovedSpasUseCase>();
      _spasSub = useCase().listen((spas) {
        _allSpas = spas;
        _recomputeSuggestions(_searchController.text);
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _linkSub?.cancel();
    _spasSub?.cancel();
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SpaSearchField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: _recomputeSuggestions,
                    ),
                    if (_suggestions.isNotEmpty &&
                        _searchController.text.trim().isNotEmpty &&
                        _searchFocus.hasFocus)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                          constraints: BoxConstraints(maxHeight: 240.h),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final s = _suggestions[index];
                              return ListTile(
                                leading: Icon(
                                  s.type == _SuggestionType.spa
                                      ? Icons.store_rounded
                                      : (s.type == _SuggestionType.subcategory
                                          ? Icons
                                              .subdirectory_arrow_right_rounded
                                          : Icons.category_rounded),
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(
                                  s.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle:
                                    s.subtitle != null ? Text(s.subtitle!) : null,
                                onTap: () {
                                  if (s.type == _SuggestionType.spa &&
                                      s.spaId != null) {
                                    Navigator.of(context).pushNamed(
                                      '/spa-detail',
                                      arguments: SpaDetailArgs(s.spaId!),
                                    );
                                  } else if (s.type ==
                                      _SuggestionType.service) {
                                    Navigator.of(context).pushNamed(
                                      '/category-subcategories',
                                      arguments:
                                          CategorySubcategoriesArgs(s.title),
                                    );
                                  } else if (s.type ==
                                          _SuggestionType.subcategory &&
                                      s.parentCategory != null) {
                                    Navigator.of(context).pushNamed(
                                      '/subcategory-spas',
                                      arguments: {
                                        'category': s.parentCategory,
                                        'subcategory': s.title,
                                      },
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 120,
                  ),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildCategoryGrid(),
                      const SizedBox(height: 20),
                      AdMobBannerWidget(
                        adUnitId: kDebugMode
                            ? 'ca-app-pub-3940256099942544/6300978111'
                            : 'ca-app-pub-7682628416837305/4512781378',
                      ),
                      const SizedBox(height: 16),
                      _SuggestedNearbySpas(locationBloc: _locationBloc),
                      const SizedBox(height: 8),
                      const _TopListedSpas(),
                      const SizedBox(height: 16),
                      const _BrandingFooter(),
                    ],
                  ),
                ),
              ),
            ],
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
                    '/category-subcategories',
                    arguments: CategorySubcategoriesArgs(label),
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

  // =========================
  // Suggested Nearby Spas
  // =========================
  Future<void> _handleInitialDeepLink() async {
    final deepLinkService = sl.get<DeepLinkService>();
    final spaId = await deepLinkService.getInitialSpaId();
    if (!mounted) return;
    if (spaId != null && spaId.isNotEmpty) {
      Navigator.of(
        context,
      ).pushNamed('/spa-detail', arguments: SpaDetailArgs(spaId));
    }
  }

  void _subscribeDeepLinks() {
    final deepLinkService = sl.get<DeepLinkService>();
    _linkSub = deepLinkService.onLinkSpaId().listen((spaId) {
      if (!mounted) return;
      if (spaId.isNotEmpty) {
        Navigator.of(
          context,
        ).pushNamed('/spa-detail', arguments: SpaDetailArgs(spaId));
      }
    });
  }
}

class _SearchSuggestion {
  final _SuggestionType type;
  final String title;
  final String? subtitle;
  final String? spaId;
  final String? parentCategory;
  const _SearchSuggestion({
    required this.type,
    required this.title,
    this.subtitle,
    this.spaId,
    this.parentCategory,
  });
}

enum _SuggestionType { spa, service, subcategory }

extension on _HomePageState {
  void _recomputeSuggestions(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _suggestions = const [];
      if (mounted) setState(() {});
      return;
    }
    final spaMatches = _allSpas
        .where((s) {
          final name = s.businessName.trim().toLowerCase();
          final city = s.city.trim().toLowerCase();
          final services = s.services
              .map((e) => e.trim().toLowerCase())
              .toList();
          return name.contains(q) ||
              city.contains(q) ||
              services.any((e) => e.contains(q));
        })
        .map((s) {
          final subtitle = s.city.isNotEmpty ? s.city : null;
          return _SearchSuggestion(
            type: _SuggestionType.spa,
            title: s.businessName,
            subtitle: subtitle,
            spaId: s.id,
          );
        })
        .take(6)
        .toList();

    final serviceLabels = _categories.map((e) => e['label']!).toList();
    final serviceMatches = serviceLabels
        .where((label) => label.trim().toLowerCase().contains(q))
        .map((label) {
          return _SearchSuggestion(type: _SuggestionType.service, title: label);
        })
        .take(6)
        .toList();

    final subcategoryMatches = <_SearchSuggestion>[];
    CategorySubcategoriesPage.subDescriptions.forEach((category, subMap) {
      for (final sub in subMap.keys) {
        if (sub.trim().toLowerCase().contains(q)) {
          subcategoryMatches.add(
            _SearchSuggestion(
              type: _SuggestionType.subcategory,
              title: sub,
              parentCategory: category,
              subtitle: 'in $category',
            ),
          );
        }
      }
    });

    final result = <_SearchSuggestion>[];
    result.addAll(spaMatches.take(4));
    result.addAll(serviceMatches.take(2));
    result.addAll(subcategoryMatches.take(4));

    _suggestions = result.take(10).toList();
    if (mounted) setState(() {});
  }
}

class _SuggestedNearbySpas extends StatelessWidget {
  final LocationBloc locationBloc;
  const _SuggestedNearbySpas({required this.locationBloc});

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamAllApprovedSpasUseCase>();
    return ListenableBuilder(
      listenable: locationBloc,
      builder: (context, _) {
        final userLat = locationBloc.state.location?.latitude;
        final userLng = locationBloc.state.location?.longitude;
        double? dist(double? lat, double? lng) {
          if (userLat == null || userLng == null || lat == null || lng == null)
            return null;
          const r = 6371.0;
          final dLat = (lat - userLat) * math.pi / 180.0;
          final dLng = (lng - userLng) * math.pi / 180.0;
          final a =
              (math.sin(dLat / 2) * math.sin(dLat / 2)) +
              math.cos(userLat * math.pi / 180.0) *
                  math.cos(lat * math.pi / 180.0) *
                  (math.sin(dLng / 2) * math.sin(dLng / 2));
          final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
          return r * c;
        }

        return StreamBuilder<List<SpaEntity>>(
          stream: useCase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }
            final spas = (snapshot.data ?? const <SpaEntity>[]);
            var spasWithDist = spas
                .map((s) => (s, dist(s.latitude, s.longitude)))
                .toList();
            if (userLat != null && userLng != null) {
              spasWithDist.sort((a, b) {
                final da = a.$2;
                final db = b.$2;
                if (da == null && db == null) return 0;
                if (da == null) return 1;
                if (db == null) return -1;
                return da.compareTo(db);
              });
            }
            spasWithDist = spasWithDist.take(6).toList();
            if (spasWithDist.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Suggested near you',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  height: 160.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: spasWithDist.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      final spa = spasWithDist[index].$1;
                      final d = spasWithDist[index].$2;
                      return _SuggestedCard(spa: spa, distanceKm: d);
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            );
          },
        );
      },
    );
  }
}

class _TopListedSpas extends StatelessWidget {
  const _TopListedSpas();

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamAllApprovedSpasUseCase>();
    return StreamBuilder<List<SpaEntity>>(
      stream: useCase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
          );
        }
        if (snapshot.hasError) return const SizedBox.shrink();
        final spas = (snapshot.data ?? const <SpaEntity>[])
            .where((s) => (s.rating ?? 0) > 0)
            .toList();
        spas.sort((a, b) {
          final ar = a.rating ?? 0;
          final br = b.rating ?? 0;
          if (ar == br) {
            final ad = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bd = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bd.compareTo(ad);
          }
          return br.compareTo(ar);
        });
        final top5 = spas.take(5).toList();
        if (top5.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Top listed spas',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                primary: false,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: top5.length,
                separatorBuilder: (_, __) => SizedBox(width: 12.w),
                itemBuilder: (context, index) {
                  final spa = top5[index];
                  return _TopListedCard(spa: spa);
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }
}

class _TopListedCard extends StatelessWidget {
  final SpaEntity spa;
  const _TopListedCard({required this.spa});

  @override
  Widget build(BuildContext context) {
    final image = spa.photos.isNotEmpty ? spa.photos.first : null;
    final ratingText = (spa.rating ?? 0).toStringAsFixed(1);
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/spa-detail',
          arguments: SpaDetailArgs(spa.id),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 220.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: image != null
                  ? Image.network(
                      image,
                      width: 220.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    )
                  : Container(
                      width: 220.w,
                      height: 90.h,
                      alignment: Alignment.center,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.spa_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.sp,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spa.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: Colors.amber[700],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ratingText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          spa.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandingFooter extends StatelessWidget {
  const _BrandingFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Center(
        child: Text(
          'BookMySpa by AVR Softwares',
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SuggestedCard extends StatelessWidget {
  final SpaEntity spa;
  final double? distanceKm;
  const _SuggestedCard({required this.spa, this.distanceKm});

  @override
  Widget build(BuildContext context) {
    final image = spa.photos.isNotEmpty ? spa.photos.first : null;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/spa-detail',
          arguments: SpaDetailArgs(spa.id),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 220.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: image != null
                  ? Image.network(
                      image,
                      width: 220.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    )
                  : Container(
                      width: 220.w,
                      height: 90.h,
                      alignment: Alignment.center,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.spa_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28.sp,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spa.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          spa.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (distanceKm != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '${distanceKm!.toStringAsFixed(distanceKm! >= 10 ? 0 : 1)} km',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
