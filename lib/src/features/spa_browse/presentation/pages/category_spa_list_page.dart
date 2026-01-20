import 'package:bookmyspa/src/core/theme/tokens.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import 'spa_services_page.dart';
import 'spa_detail_page.dart';
import '../controllers/favorites_controller.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

class CategorySpasArgs {
  final String category;
  const CategorySpasArgs(this.category);
}

class CategorySpaListPage extends StatefulWidget {
  final String category;

  const CategorySpaListPage({super.key, required this.category});

  @override
  State<CategorySpaListPage> createState() => _CategorySpaListPageState();
}

class _CategorySpaListPageState extends State<CategorySpaListPage> {
  double? _minRating;
  double? _maxDistanceKm;
  int? _minPrice;
  int? _maxPrice;
  String? _cityFilter;

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpasByCategoryUseCase>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<SpaEntity>>(
        stream: useCase(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading spas...',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64.sp,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          final location = sl.get<LocationBloc>().state.location;
          final userLat = location?.latitude;
          final userLng = location?.longitude;
          double? _distance(double? lat, double? lng) {
            if (userLat == null ||
                userLng == null ||
                lat == null ||
                lng == null)
              return null;
            const r = 6371.0;
            final dLat = (lat - userLat) * 3.141592653589793 / 180.0;
            final dLng = (lng - userLng) * 3.141592653589793 / 180.0;
            final a =
                (math.sin(dLat / 2) * math.sin(dLat / 2)) +
                math.cos(userLat * 3.141592653589793 / 180.0) *
                    math.cos(lat * 3.141592653589793 / 180.0) *
                    (math.sin(dLng / 2) * math.sin(dLng / 2));
            final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
            return r * c;
          }

          int? _computeMinPrice(SpaEntity s) {
            int? best;
            if (s.serviceDetails.isNotEmpty) {
              for (final entry in s.serviceDetails.values) {
                for (final plans in entry.plans.values) {
                  for (final plan in plans) {
                    final p = plan.price;
                    if (p > 0) {
                      if (best == null || p < best) best = p;
                    }
                  }
                }
              }
            }
            if (best == null && s.pricing.isNotEmpty) {
              for (final sp in s.pricing) {
                final p = int.tryParse(sp.price) ?? 0;
                if (p > 0) {
                  if (best == null || p < best) best = p;
                }
              }
            }
            return best;
          }

          final spasWithDist = (snapshot.data ?? const <SpaEntity>[])
              .map((s) => (s, _distance(s.latitude, s.longitude)))
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
          } else {
            spasWithDist.sort((a, b) {
              final ad = a.$1.publishedAt;
              final bd = b.$1.publishedAt;
              if (ad == null && bd == null) return 0;
              if (ad == null) return 1;
              if (bd == null) return -1;
              return bd.compareTo(ad);
            });
          }
          List<(SpaEntity, double?)> filtered = spasWithDist.where((e) {
            final spa = e.$1;
            final dist = e.$2;
            if (_minRating != null) {
              final r = spa.rating ?? 0.0;
              if (r < _minRating!) return false;
            }
            if (_maxDistanceKm != null) {
              if (dist == null) return false;
              if (dist > _maxDistanceKm!) return false;
            }
            if (_cityFilter != null && _cityFilter!.trim().isNotEmpty) {
              final cf = _cityFilter!.trim().toLowerCase();
              if (spa.city.trim().toLowerCase() != cf) return false;
            }
            if (_minPrice != null || _maxPrice != null) {
              final mp = _computeMinPrice(spa);
              if (mp == null) return false;
              if (_minPrice != null && mp < _minPrice!) return false;
              if (_maxPrice != null && mp > _maxPrice!) return false;
            }
            return true;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 80.sp,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No spas found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'No spas available in ${widget.category} category',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'Spa' : 'Spas'} Available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: [
                          if (_minRating != null)
                            _ActiveChip(
                              label: 'Rating ${_minRating!.toStringAsFixed(1)}+',
                              onClear: () => setState(() => _minRating = null),
                            ),
                          if (_maxDistanceKm != null)
                            _ActiveChip(
                              label: 'Within ${_maxDistanceKm!.toStringAsFixed(0)} km',
                              onClear: () => setState(() => _maxDistanceKm = null),
                            ),
                          if (_minPrice != null || _maxPrice != null)
                            _ActiveChip(
                              label:
                                  'Price ${_minPrice ?? 0}–${_maxPrice ?? '∞'}',
                              onClear: () => setState(() {
                                _minPrice = null;
                                _maxPrice = null;
                              }),
                            ),
                          if (_cityFilter != null && _cityFilter!.trim().isNotEmpty)
                            _ActiveChip(
                              label: 'City ${_cityFilter}',
                              onClear: () => setState(() => _cityFilter = null),
                            ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openFilters(context, userLat != null && userLng != null),
                      icon: Icon(Icons.filter_list_rounded,
                          color: Theme.of(context).colorScheme.primary, size: 18.sp),
                      label: Text(
                        'Filters',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final spa = filtered[index].$1;
                    final d = filtered[index].$2;
                    return SpaCard(spa: spa, index: index, distanceKm: d);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onClear;
  const _ActiveChip({required this.label, required this.onClear});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: onClear,
            child: Icon(Icons.close_rounded,
                size: 14.sp, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

extension on _CategorySpaListPageState {
  void _openFilters(BuildContext context, bool hasLocation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        double tempMinRating = _minRating ?? 0.0;
        double tempMaxDistance = _maxDistanceKm ?? 0.0;
        int tempMinPrice = _minPrice ?? 0;
        int tempMaxPrice = _maxPrice ?? 0;
        final cityCtrl = TextEditingController(text: _cityFilter ?? '');
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempMinRating = 0.0;
                            tempMaxDistance = 0.0;
                            tempMinPrice = 0;
                            tempMaxPrice = 0;
                            cityCtrl.text = '';
                          });
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text('Minimum Rating', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Slider(
                    value: tempMinRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: '${tempMinRating.toStringAsFixed(1)}',
                    onChanged: (v) => setSheetState(() => tempMinRating = v),
                  ),
                  SizedBox(height: 8.h),
                  Text('Max Distance (km)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  if (hasLocation)
                    Slider(
                      value: tempMaxDistance,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      label: tempMaxDistance == 0 ? 'Any' : '${tempMaxDistance.toStringAsFixed(0)} km',
                      onChanged: (v) => setSheetState(() => tempMaxDistance = v),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2),
                      ),
                      child: Text(
                        'Turn on location to filter by distance',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),
                  Text('Price Range (₹)', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Min'),
                          onChanged: (v) => setSheetState(() {
                            tempMinPrice = int.tryParse(v) ?? 0;
                          }),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'Max'),
                          onChanged: (v) => setSheetState(() {
                            tempMaxPrice = int.tryParse(v) ?? 0;
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text('City', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  TextField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(hintText: 'Enter city'),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minRating = tempMinRating > 0 ? tempMinRating : null;
                          _maxDistanceKm = hasLocation && tempMaxDistance > 0 ? tempMaxDistance : null;
                          _minPrice = tempMinPrice > 0 ? tempMinPrice : null;
                          _maxPrice = tempMaxPrice > 0 ? tempMaxPrice : null;
                          _cityFilter = cityCtrl.text.trim().isNotEmpty ? cityCtrl.text.trim() : null;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class SpaCard extends StatefulWidget {
  final SpaEntity spa;
  final int index;
  final double? distanceKm;

  const SpaCard({
    super.key,
    required this.spa,
    required this.index,
    this.distanceKm,
    this.selectedSubcategory,
  });
  final String? selectedSubcategory;

  @override
  State<SpaCard> createState() => _SpaCardState();
}

class _SpaCardState extends State<SpaCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  Widget build(BuildContext context) {
    final spa = widget.spa;
    final favController = sl.get<FavoritesController>();

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),

            // PRIMARY OUTLINE
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1.8,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/spa-services',
                arguments: SpaServicesArgs(
                  spa.id,
                  selectedSubcategory: widget.selectedSubcategory,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      child: _buildImageCarousel(spa),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: StreamBuilder<bool>(
                        stream: favController.isFavoriteStream(spa.id),
                        builder: (context, snap) {
                          final isFav = snap.data ?? false;
                          return Material(
                            color: Colors.black.withOpacity(0.35),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () async {
                                try {
                                  await favController.toggleFavorite(
                                    spa.id,
                                    spa,
                                  );
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (spa.photos.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(spa.photos.length, (i) {
                            final active = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: active ? 16.w : 8.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: active
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),

                // CONTENT SECTION
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spa name row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spa.businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),

                      // CITY TAG (DARK WITH PRIMARY OUTLINE)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              spa.city,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14.sp,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  spa.rating != null
                                      ? spa.rating!.toStringAsFixed(1)
                                      : 'No rating',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/spa-detail',
                                arguments: SpaDetailArgs(spa.id),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  size: 16.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'Quick View',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ADDRESS
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              spa.fullAddress.isNotEmpty
                                  ? spa.fullAddress
                                  : "Address not available",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                height: 1.4,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.distanceKm != null) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk_rounded,
                              size: 16.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${widget.distanceKm!.toStringAsFixed(widget.distanceKm! >= 10 ? 0 : 1)} km away',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(curve: Curves.easeOutBack, parent: _controller));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: _controller));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });

    _pageController = PageController();
    final photosLen = widget.spa.photos.length;
    if (photosLen > 1) {
      _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final len = widget.spa.photos.length;
        if (len <= 1) return;
        _currentPage = (_currentPage + 1) % len;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Widget _buildImageCarousel(SpaEntity spa) {
    if (spa.photos.isEmpty) {
      return Container(
        height: 180.h,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        alignment: Alignment.center,
        child: Icon(
          Icons.spa_rounded,
          size: 60.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return SizedBox(
      height: 180.h,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: spa.photos.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, i) {
          final url = spa.photos[i];
          return Image.network(
            url,
            height: 180.h,
            width: double.infinity,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
