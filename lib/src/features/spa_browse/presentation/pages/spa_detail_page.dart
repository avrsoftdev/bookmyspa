import 'package:flutter/material.dart';
import 'dart:async';
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text('Spa Details'),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),

      body: StreamBuilder<SpaEntity?>(
        stream: useCase(spaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final spa = snapshot.data;
          if (spa == null) {
            return Center(
              child: Text(
                "Spa not found",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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

class _HeaderImageSection extends StatefulWidget {
  final SpaEntity spa;
  const _HeaderImageSection({required this.spa});
  @override
  State<_HeaderImageSection> createState() => _HeaderImageSectionState();
}

class _HeaderImageSectionState extends State<_HeaderImageSection> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final len = widget.spa.photos.length;
    if (len > 1) {
      _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final n = widget.spa.photos.length;
        if (n <= 1) return;
        _currentPage = (_currentPage + 1) % n;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spa = widget.spa;
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (spa.photos.isEmpty)
            Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: spa.photos.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => Image.network(
                spa.photos[i],
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 16.h,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    spa.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (spa.photos.length > 1)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(spa.photos.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: active ? 16.w : 8.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  );
                }),
              ),
            ),
        ],
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              spa.city,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.sp,
              ),
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
        color: Theme.of(context).colorScheme.onSurface,
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
          color: Theme.of(context).colorScheme.surfaceVariant,
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
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontSize: 14.sp,
        height: 1.4,
      ),
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
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.2,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Text(
                s,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      p.service,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  Text(
                    "₹${p.price}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$serviceName — $subcategory",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "₹$price",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
