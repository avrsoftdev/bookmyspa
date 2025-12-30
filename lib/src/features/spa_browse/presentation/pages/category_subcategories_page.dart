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

  static const Map<String, Map<String, String>> _subDescriptions = {
    'Massage': {
      'Swedish Massage': 'Gentle full‑body massage to relax muscles and improve circulation.',
      'Deep Tissue Massage': 'Firm pressure targeting deep muscle layers to relieve chronic tension.',
      'Aromatherapy Massage': 'Massage with essential oils to calm, energize, or uplift.',
      'Hot Stone Massage': 'Warm stones and gliding strokes to melt muscle stiffness.',
      'Thai Massage': 'Stretch‑based, floor massage to improve flexibility and energy flow.',
      'Reflexology': 'Pressure on feet/hands to stimulate reflex points and promote balance.',
      'Sports Massage': 'Performance‑focused massage aiding recovery and mobility.',
      'Head–Neck–Shoulder Massage': 'Targets upper body tension and stress headaches.',
      'Full Body Massage': 'From head to toe relaxation and muscle easing.',
      'Couple Massage': 'Side‑by‑side massages tailored for two.',
    },
    'Pedicure': {
      'Classic Pedicure': 'Basic grooming with soak, trim, buff, and polish.',
      'Spa Pedicure': 'Enhanced pedicure with scrub, mask, and extended massage.',
      'Gel Pedicure': 'Long‑lasting gel polish cured for chip‑free shine.',
      'French Pedicure': 'Natural look with white tips and sheer base.',
      'Paraffin Pedicure': 'Warm wax softens skin and deeply moisturizes feet.',
      'Anti-Tan Pedicure': 'Targets tanning and dullness for brighter feet.',
      'Foot Spa': 'Soak, exfoliation, and massage to refresh tired feet.',
      'Medical Pedicure': 'Hygienic care focusing on foot health and comfort.',
    },
    'Manicure': {
      'Classic Manicure': 'Nail shaping, cuticle care, buffing, and polish.',
      'Gel Manicure': 'Durable gel color with glossy, chip‑resistant finish.',
      'French Manicure': 'Elegant white tips on a natural base.',
      'Spa Manicure': 'Treatment manicure with scrub, mask, and massage.',
      'Nail Extensions': 'Length and shape enhancement using tips or forms.',
      'Acrylic Nails': 'Strong sculpted nails with acrylic powder and liquid.',
      'Cuticle Care': 'Gentle treatment to clean and condition cuticles.',
    },
    'Skin Care': {
      'Clean-Up': 'Quick cleanse, exfoliation, and mask for refreshed skin.',
      'Facial': 'Customized deep treatment for glow and hydration.',
      'Anti-Aging Treatment': 'Targets fine lines and firmness with active ingredients.',
      'Acne Treatment': 'Clarifying care to calm breakouts and congestion.',
      'Skin Brightening': 'Evens tone and reduces dullness for radiance.',
      'Hydrafacial': 'Vortex cleansing and infusion for plump, clean skin.',
      'Chemical Peel': 'Controlled exfoliation to smooth texture and tone.',
      'De-Tan Treatment': 'Reduces sun tan and restores natural complexion.',
    },
    'Makeup': {
      'Party Makeup': 'Camera‑ready glam suited for events and evenings.',
      'Bridal Makeup': 'Long‑wear, flawless look curated for the wedding day.',
      'Engagement Makeup': 'Soft glam enhancing features for ceremonies.',
      'HD Makeup': 'High‑definition finish that looks perfect on camera.',
      'Airbrush Makeup': 'Feather‑light, even coverage sprayed onto skin.',
      'Reception Makeup': 'Statement look tailored for receptions and parties.',
      'Natural Makeup': 'Minimal, fresh finish emphasizing skin and eyes.',
    },
    'Therapy': {
      'Body Therapy': 'Whole‑body restorative treatments to balance and relax.',
      'Aroma Therapy': 'Scent‑driven treatments to influence mood and well‑being.',
      'Relaxation Therapy': 'Calming methods to reduce stress and anxiety.',
      'Stress Relief Therapy': 'Focus on tension release and mental ease.',
      'Pain Relief Therapy': 'Targeted techniques to alleviate discomfort.',
      'Ayurvedic Therapy': 'Traditional remedies aligned with dosha balance.',
      'Hot Oil Therapy': 'Warm oils to nourish skin and soothe muscles.',
    },
    'Waxing': {
      'Full Body Wax': 'Comprehensive hair removal for smooth skin.',
      'Half Body Wax': 'Upper or lower body waxing tailored to need.',
      'Underarm Wax': 'Quick hair removal for clean underarms.',
      'Bikini Wax': 'Intimate area grooming with desired shape.',
      'Face Wax': 'Removes facial hair for a polished look.',
      'Leg Wax': 'Smooth legs with long‑lasting results.',
      'Arm Wax': 'Hair‑free arms with a sleek finish.',
    },
    'Bodycare': {
      'Body Scrub': 'Exfoliation to remove dead skin and boost glow.',
      'Body Polish': 'Fine buffing for silky, luminous skin.',
      'Body Wrap': 'Nourishing wraps to hydrate and contour.',
      'Detox Therapy': 'Cleansing body rituals to refresh and renew.',
    },
    'Bridal': {
      'Bridal Package': 'Curated beauty and wellness plan for brides.',
      'Pre-Wedding Care': 'Skin and hair prep leading up to the big day.',
      'Sangeet Makeup': 'Festive glam tailored for sangeet functions.',
      'Reception Makeup': 'Bold or classic reception looks that last.',
    },
    'Grooming': {
      'Beard Trim': 'Shape and tidy beards to suit face structure.',
      'Beard Styling': 'Define lines and style for a sharp look.',
      'Shave': 'Clean, smooth shave with skin comfort.',
      'Threading': 'Precise hair removal for brows and face.',
      'Waxing': 'Grooming wax for desired areas.',
    },
    'Haircare': {
      'Haircut': 'Customized cut matching face shape and lifestyle.',
      'Blow Dry': 'Smooth, voluminous finish to style hair.',
      'Hair Spa': 'Deep conditioning to repair and hydrate.',
      'Keratin Treatment': 'Smoothing treatment to reduce frizz.',
      'Smoothening': 'Straightening for sleek, manageable hair.',
      'Coloring': 'Global color to refresh or transform shade.',
      'Highlights': 'Dimension with lighter streaks and accents.',
    },
  };

  static String _getDescription(String category, String sub) {
    final cat = _subDescriptions[category];
    final d = cat?[sub];
    return d ?? 'Brief description coming soon.';
  }

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
                          IconButton(
                            icon: Icon(
                              Icons.info_outline_rounded,
                              size: 18.sp,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              final desc = _getDescription(category, name);
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    desc,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13.sp,
                                      height: 1.4,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
