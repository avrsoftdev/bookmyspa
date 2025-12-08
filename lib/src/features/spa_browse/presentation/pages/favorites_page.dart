import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/spa_entity.dart';
import '../../domain/usecases/stream_spa_by_id_usecase.dart';
import '../controllers/favorites_controller.dart';
import '../../../../core/di/di.dart';
import 'spa_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favController = sl.get<FavoritesController>();
    final spaById = sl.get<StreamSpaByIdUseCase>();
    return StreamBuilder<List<String>>(
      stream: favController.favoriteSpaIdsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ids = snapshot.data ?? const [];
        if (ids.isEmpty) {
          return const Center(child: Text('No favourites yet'));
        }
        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: ids.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
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
                return InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/spa-detail', arguments: SpaDetailArgs(spa.id));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10.r, offset: const Offset(0, 6))],
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: imageUrl != null
                              ? Image.network(imageUrl, width: 72.w, height: 72.w, fit: BoxFit.cover)
                              : Container(width: 72.w, height: 72.w, color: Colors.grey[300], child: Icon(Icons.spa_rounded, color: Colors.grey[600])),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(spa.businessName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                              SizedBox(height: 6.h),
                              Row(children: [
                                Icon(Icons.location_on_rounded, size: 16.sp, color: Colors.deepPurple),
                                SizedBox(width: 4.w),
                                Expanded(child: Text(spa.city, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.sp, color: Colors.black87))),
                              ]),
                              SizedBox(height: 4.h),
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Icon(Icons.place_rounded, size: 16.sp, color: Colors.deepPurple),
                                SizedBox(width: 4.w),
                                Expanded(child: Text(spa.fullAddress.isNotEmpty ? spa.fullAddress : 'Address not available', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.sp, color: Colors.black54))),
                              ]),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors.black45),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96.h,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: const Center(child: Text('Spa unavailable')),
    );
  }
}
