import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';
import 'spa_detail_page.dart';

class SpaServicesArgs {
  final String spaId;
  const SpaServicesArgs(this.spaId);
}

class SpaServicesPage extends StatelessWidget {
  final String spaId;
  const SpaServicesPage({super.key, required this.spaId});

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpaByIdUseCase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Pricing'),
        backgroundColor: Colors.deepPurple,
      ),
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
              _SpaCard(spa: spa),
              SizedBox(height: 24.h),
              Text(
                'Services & Pricing',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              if (spa.pricing.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Text(
                      'No pricing information available',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                )
              else
                ...spa.pricing.map((pricing) => _ServicePricingCard(
                      serviceName: pricing.service,
                      price: pricing.price,
                    )),
            ],
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
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/spa-detail',
          arguments: SpaDetailArgs(spa.id),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80.w,
                      height: 80.w,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.spa_rounded,
                        color: Colors.grey[600],
                        size: 32.sp,
                      ),
                    ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spa.businessName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                          spa.fullAddress.isNotEmpty
                              ? spa.fullAddress
                              : spa.city,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        'Tap for full details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14.sp,
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicePricingCard extends StatelessWidget {
  final String serviceName;
  final String price;

  const _ServicePricingCard({
    required this.serviceName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              serviceName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            '₹$price',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }
}
