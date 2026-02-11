import 'package:Spaxify/src/features/home/data/category_preferences.dart';
import 'package:Spaxify/src/features/home/presentation/widgets/category_images.dart';
import 'package:Spaxify/src/features/spa_browse/presentation/pages/category_subcategories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularCategories extends StatefulWidget {
  const PopularCategories({super.key});

  @override
  State<PopularCategories> createState() => _PopularCategoriesState();
}

class _PopularCategoriesState extends State<PopularCategories> {
  List<String> _popularCategories = [];

  @override
  void initState() {
    super.initState();
    _loadPopularCategories();
  }

  Future<void> _loadPopularCategories() async {
    final categories = await CategoryPreferences().getPopularCategories();
    setState(() {
      _popularCategories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_popularCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Suggested for you',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _popularCategories.length,
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              final imagePath = categoryImages[category];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/category-subcategories',
                    arguments: CategorySubcategoriesArgs(category),
                  );
                },
                child: Container(
                  width: 100.w,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (imagePath != null)
                        Image.asset(
                          imagePath,
                          height: 60.h,
                          width: 60.w,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(height: 8.h),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
