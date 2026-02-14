import 'package:Spaxify/utils/constants/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../utils/constants/image.dart';
import '../../../home/data/category_preferences.dart';
import 'category_subcategories_page.dart';
import '../../../../core/theme/tokens.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  // Category data - users can add more categories here
  static final List<Map<String, String>> _allCategories = [
    {'icon': Images.massage, 'label': 'Massage'},
    {'icon': Images.pedicure, 'label': 'Pedicure'},
    {'icon': Images.manicure, 'label': 'Manicure'},
    {'icon': Images.skincare, 'label': 'Skin Care'},
    {'icon': Images.makeup, 'label': 'Makeup'},
    {'icon': Images.therapy, 'label': 'Therapy'},
    {'icon': Images.wax, 'label': 'Waxing'},
    {'icon': Images.bodytreatments, 'label': 'Bodycare'},
    {'icon': Images.bride, 'label': 'Bridal'},
    {'icon': Images.groom, 'label': 'Grooming'},
    {'icon': Images.haircut, 'label': 'Haircare'},
    // User can add more categories below
    // {'icon': Images.newCategoryIcon, 'label': 'New Category'},
     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'All Categories',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          itemCount: _allCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 20.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final item = _allCategories[index];
            final label = item['label']!;
            final iconPath = item['icon']!;

            return InkWell(
              onTap: () {
                CategoryPreferences().incrementCategory(label);
                Navigator.of(context).pushNamed(
                  '/category-subcategories',
                  arguments: CategorySubcategoriesArgs(label),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 56.h,
                    width: 56.h,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: iconPath.isNotEmpty 
                      ? Image.asset(iconPath, fit: BoxFit.contain)
                      : Icon(Icons.category_outlined, size: 30.sp, color: AppColors.primary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
