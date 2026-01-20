import 'package:bookmyspa/src/features/spa_browse/domain/entities/spa_entity.dart';
import 'package:bookmyspa/src/features/spa_browse/domain/usecases/stream_spas_by_owner_usecase.dart';
import 'package:bookmyspa/src/features/spa_browse/presentation/pages/spa_services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../spa_registration/presentation/pages/edit_spa_page.dart';

class MyBusinessPage extends StatelessWidget {
  const MyBusinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = sl.get<AuthController>();
    final uid = auth.currentUser?.id;
    final useCase = sl.get<StreamSpasByOwnerUseCase>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('My Business', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'Please login to view your business',
                style: TextStyle(color: Colors.white),
              ),
            )
          : StreamBuilder<List<SpaEntity>>(
              stream: useCase(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                final spas = snapshot.data ?? const [];
                if (spas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 64.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 12.h),
                        const Text(
                          'No businesses found',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 6.h),
                        const Text(
                          'Register your spa from Profile > List Your Spa',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: spas.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final spa = spas[index];
                    return _OwnedSpaCard(spa: spa, index: index);
                  },
                );
              },
            ),
    );
  }
}

class _OwnedSpaCard extends StatefulWidget {
  final SpaEntity spa;
  final int index;

  const _OwnedSpaCard({required this.spa, required this.index});

  @override
  State<_OwnedSpaCard> createState() => _OwnedSpaCardState();
}

class _OwnedSpaCardState extends State<_OwnedSpaCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(curve: Curves.easeOutBack, parent: _controller));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(curve: Curves.easeOut, parent: _controller));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spa = widget.spa;
    final imageUrl = spa.photos.isNotEmpty ? spa.photos.first : null;
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/spa-services',
                arguments: SpaServicesArgs(spa.id),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          height: 160.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 160.h,
                          color: AppColors.primary.withOpacity(0.15),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.spa_rounded,
                            size: 52.sp,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              spa.businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          _StatusChip(status: spa.status),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            spa.city,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 16.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              spa.fullAddress.isNotEmpty
                                  ? spa.fullAddress
                                  : 'Address not available',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditSpaPage(spaId: spa.id),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Details'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/spa-services',
                              arguments: SpaServicesArgs(spa.id),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Services'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  Color _bg() {
    switch (status) {
      case 'approved':
        return Colors.green.withOpacity(0.15);
      case 'pending_review':
        return Colors.orange.withOpacity(0.15);
      case 'rejected':
        return Colors.red.withOpacity(0.15);
      default:
        return Colors.blueGrey.withOpacity(0.15);
    }
  }

  Color _fg() {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending_review':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _fg(), width: 1),
      ),
      child: Text(
        status.isNotEmpty ? status.replaceAll('_', ' ') : 'unknown',
        style: TextStyle(
          fontSize: 12.sp,
          color: _fg(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
