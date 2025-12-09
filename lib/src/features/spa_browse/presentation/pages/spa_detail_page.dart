import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
// import 'package:intl/intl.dart';

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
              _SectionTitle(title: 'Pricing'),
              SizedBox(height: 8.h),
              _PricingList(pricing: spa.pricing),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Location'),
              SizedBox(height: 8.h),
              _LocationInfo(spa: spa),
              // SizedBox(height: 16.h),
              // _StatusInfo(spa: spa),
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
    if (items.isEmpty) {
      return Text('No services listed', style: TextStyle(fontSize: 14.sp, color: Colors.grey));
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items.map((e) => Chip(label: Text(e, style: TextStyle(fontSize: 13.sp)))).toList(),
    );
  }
}

class _PricingList extends StatelessWidget {
  final List<ServicePricing> pricing;
  const _PricingList({required this.pricing});
  @override
  Widget build(BuildContext context) {
    if (pricing.isEmpty) {
      return Text('No pricing information available', style: TextStyle(fontSize: 14.sp, color: Colors.grey));
    }
    return Column(
      children: pricing.map((p) => Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(p.service, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500))),
            Text('₹${p.price}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      )).toList(),
    );
  }
}

class _LocationInfo extends StatelessWidget {
  final SpaEntity spa;
  const _LocationInfo({required this.spa});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (spa.fullAddress.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(child: Text(spa.fullAddress, style: TextStyle(fontSize: 14.sp))),
            ],
          ),
          SizedBox(height: 8.h),
        ],
        Row(
          children: [
            Icon(Icons.location_city, size: 18.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(spa.city, style: TextStyle(fontSize: 14.sp)),
          ],
        ),
      ],
    );
  }
}

class _StatusInfo extends StatelessWidget {
  final SpaEntity spa;
  const _StatusInfo({required this.spa});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16.sp, color: Colors.black54),
              SizedBox(width: 8.w),
              // Text('Status:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                // decoration: BoxDecoration(
                //   color: spa.status == 'published' ? Colors.green : Colors.orange,
                //   borderRadius: BorderRadius.circular(4.r),
                // ),
                child: Text(
                  spa.status.toUpperCase(),
                  style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (spa.publishedAt != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16.sp, color: Colors.black54),
                SizedBox(width: 8.w),
                Text('Published:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 8.w),
                // Text(
                //   DateFormat('MMM dd, yyyy').format(spa.publishedAt!),
                //   style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                // ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
