import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';

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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('Spa Details', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<SpaEntity?>(
        stream: useCase(spaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final spa = snapshot.data;
          if (spa == null) {
            return const Center(
              child: Text(
                "Spa not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _HeaderImageSection(spa: spa),
              SizedBox(height: 20.h),

              _TitleSection(spa: spa),
              SizedBox(height: 26.h),

              _SectionTitle("Photos"),
              SizedBox(height: 12.h),
              _Photos(photos: spa.photos),
              SizedBox(height: 26.h),

              _SectionTitle("Description"),
              SizedBox(height: 10.h),
              _Description(spa.description),
              SizedBox(height: 26.h),

              _SectionTitle("Services Offered"),
              SizedBox(height: 14.h),
              _ServicesList(spa.services),
              SizedBox(height: 26.h),

              _SectionTitle("Services & Pricing"),
              SizedBox(height: 12.h),
              _PricingBySubcategoryList(details: spa.serviceDetails),
              SizedBox(height: 26.h),

              _SectionTitle("Location"),
              SizedBox(height: 12.h),
              _LocationInfo(spa: spa),
            ],
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// HEADER IMAGE SECTION
//////////////////////////////////////////////////////////////////

class _HeaderImageSection extends StatelessWidget {
  final SpaEntity spa;
  const _HeaderImageSection({required this.spa});

  @override
  Widget build(BuildContext context) {
    final img = spa.photos.isNotEmpty ? spa.photos.first : null;

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.5),
        image: img != null
            ? DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.black.withOpacity(0.45),
        ),
        padding: EdgeInsets.all(20.w),
        alignment: Alignment.bottomLeft,
        child: Text(
          spa.businessName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// TITLE & CITY SECTION
//////////////////////////////////////////////////////////////////

class _TitleSection extends StatelessWidget {
  final SpaEntity spa;
  const _TitleSection({required this.spa});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spa.businessName,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              spa.city,
              style: TextStyle(color: Colors.grey[300], fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////
// SECTION TITLE
//////////////////////////////////////////////////////////////////

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// PHOTOS
//////////////////////////////////////////////////////////////////

class _Photos extends StatelessWidget {
  final List<String> photos;
  const _Photos({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12.r),
        ),
      );
    }

    return SizedBox(
      height: 160.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.network(
            photos[index],
            width: 240.w,
            height: 160.h,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// DESCRIPTION SECTION
//////////////////////////////////////////////////////////////////

class _Description extends StatelessWidget {
  final String description;
  const _Description(this.description);

  @override
  Widget build(BuildContext context) {
    return Text(
      description.isNotEmpty ? description : "No description available",
      style: TextStyle(color: Colors.grey[300], fontSize: 14.sp, height: 1.4),
    );
  }
}

//////////////////////////////////////////////////////////////////
// SERVICES CHIPS
//////////////////////////////////////////////////////////////////

class _ServicesList extends StatelessWidget {
  final List<String> services;
  const _ServicesList(this.services);

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Text(
        "No services listed",
        style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: services
          .map(
            (s) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary, width: 1.2),
                color: const Color(0xFF1A1A1A),
              ),
              child: Text(
                s,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  height: 1.2,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

//////////////////////////////////////////////////////////////////
// PRICING LIST
//////////////////////////////////////////////////////////////////

class _PricingList extends StatelessWidget {
  final List<ServicePricing> pricing;
  const _PricingList({required this.pricing});

  @override
  Widget build(BuildContext context) {
    if (pricing.isEmpty) {
      return Text(
        "No pricing available",
        style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      );
    }

    return Column(
      children: pricing
          .map(
            (p) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.service,
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ),
                  Text(
                    "₹${p.price}",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PricingBySubcategoryList extends StatelessWidget {
  final Map<String, ServiceDetail> details;
  const _PricingBySubcategoryList({required this.details});

  @override
  Widget build(BuildContext context) {
    final entries = details.entries
        .where((e) => e.value.plans.isNotEmpty)
        .toList();
    if (entries.isEmpty) {
      return Text(
        "No pricing available",
        style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      );
    }

    List<Widget> children = [];
    for (final e in entries) {
      final serviceName = e.key;
      final detail = e.value;
      children.addAll(
        detail.plans.entries.map((subEntry) {
          final subcategory = subEntry.key;
          final plans = subEntry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$serviceName — $subcategory",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ...plans.map((plan) {
                  final mins = plan.durationMinutes;
                  final price = plan.price;
                  final label = mins >= 60
                      ? "${(mins / 60).toStringAsFixed(mins % 60 == 0 ? 0 : 1)} hr"
                      : "$mins min";
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "₹$price",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        }),
      );
    }
    return Column(children: children);
  }
}

//////////////////////////////////////////////////////////////////
// LOCATION SECTION
//////////////////////////////////////////////////////////////////

class _LocationInfo extends StatelessWidget {
  final SpaEntity spa;
  const _LocationInfo({required this.spa});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                spa.fullAddress.isNotEmpty ? spa.fullAddress : "No address",
                style: TextStyle(color: Colors.grey[300], fontSize: 14.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Icon(Icons.location_city, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              spa.city,
              style: TextStyle(color: Colors.grey[300], fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }
}
