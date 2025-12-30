import 'package:bookmyspa/src/core/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import 'spa_services_page.dart';
import 'spa_detail_page.dart';
import '../controllers/favorites_controller.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(
          category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<SpaEntity>>(
        stream: useCase(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.deepPurple,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading spas...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
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
                      color: Colors.black87,
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
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            );
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
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'No spas available in $category category',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(24.r),
                  ),
                ),
                child: Text(
                  '${spas.length} ${spas.length == 1 ? 'Spa' : 'Spas'} Available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: spas.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final spa = spas[index];
                    return SpaCard(spa: spa, index: index);
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

class SpaCard extends StatefulWidget {
  final SpaEntity spa;
  final int index;

  const SpaCard({
    super.key,
    required this.spa,
    required this.index,
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
  }

  @override
  Widget build(BuildContext context) {
    final spa = widget.spa;
    final favController = sl.get<FavoritesController>();
    final imageUrl = spa.photos.isNotEmpty ? spa.photos.first : null;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A), // DARK CARD BACKGROUND
            borderRadius: BorderRadius.circular(20.r),

            // PRIMARY OUTLINE
            border: Border.all(color: AppColors.primary, width: 1.8),
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
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 180.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 180.h,
                              color: AppColors.primary.withOpacity(0.15),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.spa_rounded,
                                size: 60.sp,
                                color: AppColors.primary,
                              ),
                            ),
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
                                color: isFav ? AppColors.primary : Colors.white,
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
                                color: Colors.white, // WHITE TEXT
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16.sp,
                            color: AppColors.primary,
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
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              spa.city,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
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
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: AppColors.primary,
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
                                    color: Colors.white,
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
                              foregroundColor: AppColors.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
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
                            color: Colors.grey[400],
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
                                color: Colors.grey[300], // LIGHT GREY TEXT
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
        ),
      ),
    );
  }
}
