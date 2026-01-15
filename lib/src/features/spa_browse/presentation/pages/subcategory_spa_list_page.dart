import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import 'category_spa_list_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

class SubcategorySpaListPage extends StatelessWidget {
  final String category;
  final String subcategory;
  const SubcategorySpaListPage({
    super.key,
    required this.category,
    required this.subcategory,
  });

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpasByCategoryUseCase>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          subcategory,
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
        stream: useCase(category),
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

          final catKey = normalizeCategory(category);
          final target = subcategory.trim().toLowerCase();
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

          if (spas.isEmpty) {
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
                    'No spas found for $subcategory',
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
                  '${spas.length} ${spas.length == 1 ? 'Spa' : 'Spas'} offering $subcategory',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: spasWithDist.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final spa = spasWithDist[index].$1;
                    final d = spasWithDist[index].$2;
                    return SpaCard(
                      spa: spa,
                      index: index,
                      distanceKm: d,
                      selectedSubcategory: subcategory,
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
