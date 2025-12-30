import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import 'category_spa_list_page.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          subcategory,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<List<SpaEntity>>(
        stream: useCase(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: Colors.white70),
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
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Try a related subcategory or explore other services',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
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
                  color: Colors.deepPurple,
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
                    return SpaCard(
                      spa: spa,
                      index: index,
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
