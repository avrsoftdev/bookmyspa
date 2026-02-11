import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import 'category_spa_list_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../home/data/subcategory_preferences.dart';

class SubcategorySpaListPage extends StatefulWidget {
  final String category;
  final String subcategory;
  const SubcategorySpaListPage({
    super.key,
    required this.category,
    required this.subcategory,
  });

  @override
  State<SubcategorySpaListPage> createState() => _SubcategorySpaListPageState();
}

class _SubcategorySpaListPageState extends State<SubcategorySpaListPage> {
  double? _minRating;
  double? _maxDistanceKm;
  int? _minPrice;
  int? _maxPrice;
  String? _cityFilter;

  @override
  void initState() {
    super.initState();
    _recordSubcategoryView();
  }

  Future<void> _recordSubcategoryView() async {
    await SubcategoryPreferences().incrementSubcategory(widget.subcategory);
  }

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpasByCategoryUseCase>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          widget.subcategory,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SpaEntity>>(
        stream: useCase(widget.category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          String normalizeCategory(String c) {
            final v = c.trim().toLowerCase();
            if (v == 'haircare') return 'Hair Care';
            if (v == 'bodycare') return 'Body Care';
            if (v == 'skin care') return 'Skin Care';
            return c;
          }

          final catKey = normalizeCategory(widget.category);
          final target = widget.subcategory.trim().toLowerCase();
          final spas = (snapshot.data ?? const <SpaEntity>[]).where((s) {
            final details = s.serviceDetails[catKey];
            if (details == null) return false;
            return details.subcategories.any(
              (sc) => sc.trim().toLowerCase() == target,
            );
          }).toList();
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

          final spasWithDist = spas
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
                  SizedBox(height: 12.h),
                  Text(
                    'No spas found for ${widget.subcategory}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Try a related subcategory or explore other services',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 13.sp,
                    ),
                    textAlign: TextAlign.center,
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
                  '${filtered.length} ${filtered.length == 1 ? 'Spa' : 'Spas'} offering ${widget.subcategory}',
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
                    return SpaCard(
                      spa: spa,
                      index: index,
                      distanceKm: d,
                      selectedSubcategory: widget.subcategory,
                    );
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

extension on _SubcategorySpaListPageState {
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
