import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/spa_entity.dart';
import '../../domain/usecases/stream_spa_by_id_usecase.dart';
import '../controllers/favorites_controller.dart';
import '../../../../core/di/di.dart';
import 'spa_detail_page.dart';
import '../../../../core/theme/tokens.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favController = sl.get<FavoritesController>();
    final spaById = sl.get<StreamSpaByIdUseCase>();
    return StreamBuilder<List<String>>(
      stream: favController.favoriteSpaIdsStream(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final ids = snapshot.data ?? const [];

        if (isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 12.h),
                Text('Loading favourites...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        if (ids.isEmpty) {
          return _EmptyFavourites();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
              ),
              child: Text(
                '${ids.length} ${ids.length == 1 ? 'Favourite' : 'Favourites'}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: ids.length,
                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final id = ids[index];
                  return StreamBuilder<SpaEntity?>(
                    stream: spaById(id),
                    builder: (context, snap) {
                      final spa = snap.data;
                      if (snap.connectionState == ConnectionState.waiting) {
                        return _LoadingCard();
                      }
                      if (spa == null) {
                        return _UnavailableCard();
                      }
                      final imageUrl = spa.photos.isNotEmpty ? spa.photos.first : null;
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.primary, width: 1.6),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () {
                            Navigator.of(context).pushNamed('/spa-detail', arguments: SpaDetailArgs(spa.id));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  bottomLeft: Radius.circular(20.r),
                                ),
                                child: Stack(
                                  children: [
                                    imageUrl != null
                                        ? Image.network(imageUrl, width: 110.w, height: 110.w, fit: BoxFit.cover)
                                        : Container(
                                            width: 110.w,
                                            height: 110.w,
                                            color: AppColors.primary.withOpacity(0.15),
                                            alignment: Alignment.center,
                                            child: Icon(Icons.spa_rounded, size: 40.sp, color: AppColors.primary),
                                          ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: StreamBuilder<bool>(
                                        stream: favController.isFavoriteStream(spa.id),
                                        builder: (context, s) {
                                          final isFav = s.data ?? true;
                                          return Material(
                                            color: Colors.black.withOpacity(0.35),
                                            shape: const CircleBorder(),
                                            child: IconButton(
                                              visualDensity: VisualDensity.compact,
                                              icon: Icon(
                                                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                                color: isFav ? AppColors.primary : Colors.white,
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await favController.toggleFavorite(spa.id, spa);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(e.toString())),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(14.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              spa.businessName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: AppColors.primary),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_rounded, size: 14.sp, color: AppColors.primary),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              spa.city,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12.5.sp, color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.place_outlined, size: 14.sp, color: Colors.grey[400]),
                                          SizedBox(width: 6.w),
                                          Expanded(
                                            child: Text(
                                              spa.fullAddress.isNotEmpty ? spa.fullAddress : 'Address not available',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[300], height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 110.w,
            height: 110.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 16.h, width: 160.w, color: Colors.white10),
                SizedBox(height: 10.h),
                Container(height: 12.h, width: 120.w, color: Colors.white10),
                SizedBox(height: 8.h),
                Container(height: 12.h, width: double.infinity, color: Colors.white10),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      alignment: Alignment.center,
      child: const Text('Spa unavailable', style: TextStyle(color: Colors.white70)),
    );
  }
}

class _EmptyFavourites extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 72.sp, color: Colors.grey[300]),
          SizedBox(height: 12.h),
          Text('No favourites yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Browse spas and tap the heart to save', style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 16.h),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Browse Spas'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          )
        ],
      ),
    );
  }
}
