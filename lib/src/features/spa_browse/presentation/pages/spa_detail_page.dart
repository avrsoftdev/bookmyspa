import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/usecases/stream_reviews_by_spa_usecase.dart';
import '../../domain/usecases/add_review_usecase.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/usecases/like_review_usecase.dart';
import '../../domain/usecases/dislike_review_usecase.dart';
import 'package:bookmyspa/utils/constants/image.dart';
import '../../../../core/services/share_service.dart';

class SpaDetailArgs {
  final String spaId;
  const SpaDetailArgs(this.spaId);
}

class SpaDetailPage extends StatefulWidget {
  final String spaId;
  const SpaDetailPage({super.key, required this.spaId});

  @override
  State<SpaDetailPage> createState() => _SpaDetailPageState();
}

class _SpaDetailPageState extends State<SpaDetailPage> {
  SpaEntity? _latestSpa;

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpaByIdUseCase>();
    final shareService = sl.get<ShareService>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text('Spa Details'),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final spa = _latestSpa;
              if (spa == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading spa details...')),
                );
                return;
              }
              await shareService.shareSpa(
                spaId: spa.id,
                spaName: spa.businessName,
                context: context,
              );
            },
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.ios_share
                  : Icons.share,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            tooltip: 'Share',
          ),
        ],
      ),

      body: StreamBuilder<SpaEntity?>(
        stream: useCase(widget.spaId),
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
          _latestSpa = spa;

          return Stack(
            children: [
              ListView(
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
                  _SectionTitle("Ratings & Reviews"),
                  SizedBox(height: 12.h),
                  ReviewsSection(spaId: spa.id),
                ],
              ),
              // if ((spa.whatsappNumber ?? '').isNotEmpty)
              //   Positioned(
              //     right: 16.w,
              //     bottom: 80.h,
              //     child: _WhatsAppButton(number: spa.whatsappNumber!),
              //   ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/spa-services',
                  arguments: {'spaId': widget.spaId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(
                'Book a Service',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
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
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.5),
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

class ReviewsSection extends StatefulWidget {
  final String spaId;
  const ReviewsSection({required this.spaId});
  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  int _selectedRating = 0;
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamUseCase = sl.get<StreamReviewsBySpaUseCase>();
    final addUseCase = sl.get<AddReviewUseCase>();
    final auth = sl.get<AuthController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (auth.isLoggedIn)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Write a review',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: List.generate(5, (i) {
                  final idx = i + 1;
                  final active = idx <= _selectedRating;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRating = idx;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Icon(
                        active ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 22.sp,
                        color: Colors.amber,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          if (_selectedRating <= 0) return;
                          final user = auth.currentUser!;
                          setState(() {
                            _submitting = true;
                          });
                          try {
                            await addUseCase(
                              spaId: widget.spaId,
                              userId: user.id,
                              userName: user.name,
                              rating: _selectedRating.toDouble(),
                              text: _controller.text.trim(),
                            );
                            _controller.clear();
                            setState(() {
                              _selectedRating = 0;
                            });
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _submitting = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text('Submit'),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Icon(
                Icons.lock_rounded,
                size: 16.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Sign in to write a review',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        SizedBox(height: 16.h),
        StreamBuilder<List<ReviewEntity>>(
          stream: streamUseCase(widget.spaId),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? const <ReviewEntity>[];
            final textReviews = reviews
                .where((r) => r.text.trim().isNotEmpty)
                .toList();
            double? avg;
            if (reviews.isNotEmpty) {
              avg =
                  reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  reviews.length;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (avg != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        avg.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '(${textReviews.length})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 12.h),
                if (textReviews.isEmpty)
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  )
                else
                  SizedBox(
                    height: 140.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: textReviews.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (_, i) {
                        final r = textReviews[i];
                        final userId = auth.currentUser?.id;
                        final userLiked =
                            userId != null && r.likedBy.contains(userId);
                        final userDisliked =
                            userId != null && r.dislikedBy.contains(userId);
                        final now = DateTime.now();
                        final diff = now.difference(r.createdAt);
                        String timeLabel;
                        if (diff.inDays >= 7) {
                          timeLabel =
                              "${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}";
                        } else if (diff.inDays >= 1) {
                          timeLabel = "${diff.inDays}d ago";
                        } else if (diff.inHours >= 1) {
                          timeLabel = "${diff.inHours}h ago";
                        } else if (diff.inMinutes >= 1) {
                          timeLabel = "${diff.inMinutes}m ago";
                        } else {
                          timeLabel = "Just now";
                        }
                        return Container(
                          width: 280.w,
                          padding: EdgeInsets.all(12.w),
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    size: 16.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(
                                      r.userName.isNotEmpty
                                          ? r.userName
                                          : 'Anonymous',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(5, (idx) {
                                      return Icon(
                                        idx < r.rating.round()
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 14.sp,
                                        color: Colors.amber,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Expanded(
                                child: Text(
                                  r.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    timeLabel,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      if (auth.isLoggedIn) {
                                        try {
                                          await sl
                                              .get<LikeReviewUseCase>()
                                              .call(
                                                spaId: widget.spaId,
                                                reviewId: r.id,
                                                userId: auth.currentUser!.id,
                                              );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sign in to like a review',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          userLiked
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined,
                                          size: 18.sp,
                                          color: userLiked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          r.likes.toString(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  GestureDetector(
                                    onTap: () async {
                                      if (auth.isLoggedIn) {
                                        try {
                                          await sl
                                              .get<DislikeReviewUseCase>()
                                              .call(
                                                spaId: widget.spaId,
                                                reviewId: r.id,
                                                userId: auth.currentUser!.id,
                                              );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Sign in to dislike a review',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          userDisliked
                                              ? Icons.thumb_down
                                              : Icons.thumb_down_alt_outlined,
                                          size: 18.sp,
                                          color: userDisliked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          r.dislikes.toString(),
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ],
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
        InkWell(
          onTap: () async {
            final lat = spa.latitude;
            final lng = spa.longitude;
            Uri url;
            if (lat != null && lng != null) {
              url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
              );
            } else {
              final q = spa.fullAddress.isNotEmpty ? spa.fullAddress : spa.city;
              url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
              );
            }
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 18.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  spa.fullAddress.isNotEmpty ? spa.fullAddress : spa.city,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              spa.rating != null ? spa.rating!.toStringAsFixed(1) : 'No rating',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
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
// WHATSAPP FLOATING BUTTON
//////////////////////////////////////////////////////////////////

class _WhatsAppButton extends StatelessWidget {
  final String number;
  const _WhatsAppButton({required this.number});

  String _toWaMeNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '91$digits';
    }
    return digits;
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final n = _toWaMeNumber(number);
    if (n.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp number not available')),
      );
      return;
    }
    final url = Uri.parse('https://wa.me/$n');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWhatsApp(context),
      child: Container(
        width: 56.h,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        padding: EdgeInsets.all(10.h),
        child: Image.asset(Images.wsap),
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
