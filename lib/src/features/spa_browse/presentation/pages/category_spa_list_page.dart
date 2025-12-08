import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../../../core/di/di.dart';
import 'spa_detail_page.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8.r, spreadRadius: 1.r),
        ],
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 56.w,
                  height: 56.w,
                  fit: BoxFit.cover,
                )
              : Container(width: 56.w, height: 56.w, color: Colors.grey[300]),
        ),
        title: Text(
          spa.businessName,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(spa.city, style: TextStyle(fontSize: 13.sp)),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed('/spa-detail', arguments: SpaDetailArgs(spa.id));
        },
      ),
    );
  }
}
