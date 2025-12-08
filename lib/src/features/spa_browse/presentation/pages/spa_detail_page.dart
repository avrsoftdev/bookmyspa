import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';

class SpaDetailArgs {
  final String spaId;
  const SpaDetailArgs(this.spaId);
}

class SpaDetailPage extends StatelessWidget {
  final String spaId;
  const SpaDetailPage({super.key, required this.spaId});

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpaByIdUseCase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Spa Details'), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<SpaEntity?>(
        stream: useCase(spaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final spa = snapshot.data;
          if (spa == null) {
            return const Center(child: Text('Spa not found'));
          }
          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _Header(spa: spa),
              SizedBox(height: 16.h),
              _Photos(photos: spa.photos),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Description'),
              Text(spa.description.isNotEmpty ? spa.description : 'No description provided', style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Services'),
              _Chips(items: spa.services),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Location'),
              Text(spa.city, style: TextStyle(fontSize: 14.sp)),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SpaEntity spa;
  const _Header({required this.spa});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(spa.businessName, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              Text(spa.city, style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Photos extends StatelessWidget {
  final List<String> photos;
  const _Photos({required this.photos});
  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(height: 160.h, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12.r)));
    }
    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final url = photos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(url, width: 240.w, height: 160.h, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600));
  }
}

class _Chips extends StatelessWidget {
  final List<String> items;
  const _Chips({required this.items});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((e) => Chip(label: Text(e, style: TextStyle(fontSize: 13.sp)))).toList(),
    );
  }
}
