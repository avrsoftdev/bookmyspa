import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/tokens.dart';
import 'subcategory_spa_list_page.dart';

class CategorySubcategoriesArgs {
  final String category;
  const CategorySubcategoriesArgs(this.category);
}

class CategorySubcategoriesPage extends StatelessWidget {
  final String category;
  const CategorySubcategoriesPage({super.key, required this.category});

  static const Map<String, List<String>> _subcategories = {
    'Massage': [
      'Swedish Massage',
      'Deep Tissue Massage',
      'Aromatherapy Massage',
      'Hot Stone Massage',
      'Thai Massage',
      'Reflexology',
      'Sports Massage',
      'Head–Neck–Shoulder Massage',
      'Full Body Massage',
      'Couple Massage',
    ],
    'Pedicure': [
      'Classic Pedicure',
      'Spa Pedicure',
      'Gel Pedicure',
      'French Pedicure',
      'Paraffin Pedicure',
      'Anti-Tan Pedicure',
      'Foot Spa',
      'Medical Pedicure',
    ],
    'Manicure': [
      'Classic Manicure',
      'Gel Manicure',
      'French Manicure',
      'Spa Manicure',
      'Nail Extensions',
      'Acrylic Nails',
      'Cuticle Care',
    ],
    'Skin Care': [
      'Clean-Up',
      'Facial',
      'Anti-Aging Treatment',
      'Acne Treatment',
      'Skin Brightening',
      'Hydrafacial',
      'Chemical Peel',
      'De-Tan Treatment',
    ],
    'Makeup': [
      'Party Makeup',
      'Bridal Makeup',
      'Engagement Makeup',
      'HD Makeup',
      'Airbrush Makeup',
      'Reception Makeup',
      'Natural Makeup',
    ],
    'Therapy': [
      'Body Therapy',
      'Aroma Therapy',
      'Relaxation Therapy',
      'Stress Relief Therapy',
      'Pain Relief Therapy',
      'Ayurvedic Therapy',
      'Hot Oil Therapy',
    ],
    'Waxing': [
      'Full Body Wax',
      'Half Body Wax',
      'Underarm Wax',
      'Bikini Wax',
      'Face Wax',
      'Leg Wax',
      'Arm Wax',
    ],
    'Bodycare': ['Body Scrub', 'Body Polish', 'Body Wrap', 'Detox Therapy'],
    'Bridal': [
      'Bridal Package',
      'Pre-Wedding Care',
      'Sangeet Makeup',
      'Reception Makeup',
    ],
    'Grooming': ['Beard Trim', 'Beard Styling', 'Shave', 'Threading', 'Waxing'],
    'Haircare': [
      'Haircut',
      'Blow Dry',
      'Hair Spa',
      'Keratin Treatment',
      'Smoothening',
      'Coloring',
      'Highlights',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final subs = _subcategories[category] ?? const <String>[];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          '$category Subcategories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: subs.isEmpty
            ? Center(
                child: Text(
                  'No subcategories for $category',
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: subs.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, i) {
                  final name = subs[i];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubcategorySpaListPage(
                            category: category,
                            subcategory: name,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 34.h,
                            width: 34.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.category_rounded,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14.sp,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
