import 'package:bookmyspa/src/features/home/data/subcategory_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MostBookedServices extends StatefulWidget {
  const MostBookedServices({super.key});

  @override
  State<MostBookedServices> createState() => _MostBookedServicesState();
}

class _MostBookedServicesState extends State<MostBookedServices> {
  List<String> _mostBookedSubcategories = [];

  @override
  void initState() {
    super.initState();
    _loadMostBookedSubcategories();
  }

  Future<void> _loadMostBookedSubcategories() async {
    final subcategories = await SubcategoryPreferences().getMostBookedSubcategories();
    setState(() {
      _mostBookedSubcategories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_mostBookedSubcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Most Booked Services',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mostBookedSubcategories.length,
            itemBuilder: (context, index) {
              final subcategory = _mostBookedSubcategories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/subcategory-spas',
                    arguments: {
                      'category': '',
                      'subcategory': subcategory,
                    },
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
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getColorForIndex(index),
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          subcategory,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFFFF6B6B), // Red
      Color(0xFF4ECDC4), // Teal
      Color(0xFFFFE66D), // Yellow
      Color(0xFF95E1D3), // Mint
      Color(0xFFA29BFE), // Purple
    ];
    return colors[index % colors.length];
  }
}
