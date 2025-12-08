import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import 'spa_detail_page.dart';
import '../controllers/favorites_controller.dart';
import '../../../../core/di/di.dart';

class CategorySpasArgs {
  final String category;
  const CategorySpasArgs(this.category);
}

class CategorySpaListPage extends StatelessWidget {
  final String category;

  const CategorySpaListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpasByCategoryUseCase>();

    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<List<SpaEntity>>(
        stream: useCase(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final spas = [...(snapshot.data ?? const [])];
          spas.sort((a, b) {
            final ad = a.publishedAt;
            final bd = b.publishedAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
          if (spas.isEmpty) {
            return Center(child: Text('No spas found for $category'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: spas.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final spa = spas[index];
              return _SpaCard(spa: spa);
            },
          );
        },
      ),
    );
  }
}

class _SpaCard extends StatelessWidget {
  final SpaEntity spa;
  const _SpaCard({required this.spa});

  @override
  Widget build(BuildContext context) {
    final imageUrl = spa.photos.isNotEmpty ? spa.photos.first : null;
    final favController = sl.get<FavoritesController>();
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed('/spa-detail', arguments: SpaDetailArgs(spa.id));
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.r,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 72.w,
                          height: 72.w,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.spa_rounded,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spa.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16.sp,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              spa.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.place_rounded,
                            size: 16.sp,
                            color: Colors.deepPurple,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              spa.fullAddress.isNotEmpty
                                  ? spa.fullAddress
                                  : 'Address not available',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.black45),
              ],
            ),
          ),
        ),
        Positioned(
          right: 10.w,
          bottom: 10.h,
          child: StreamBuilder<bool>(
            stream: favController.isFavoriteStream(spa.id),
            initialData: false,
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;
              return InkWell(
                onTap: () async {
                  try {
                    await favController.toggleFavorite(spa.id, spa);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6),
                    ],
                  ),
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.black54,
                    size: 20.sp,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
