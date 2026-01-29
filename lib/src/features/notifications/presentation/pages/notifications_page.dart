import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/theme/tokens.dart';
import '../../../spa_browse/presentation/pages/spa_detail_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = sl.get<AuthController>();
    final uid = auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: uid == null
          ? const Center(child: Text('Please login to view notifications'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .orderBy('ts', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 12.h),
                        const Text('No notifications yet'),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final title = (data['title'] as String?) ?? 'Notification';
                    final body = (data['body'] as String?) ?? '';
                    final type = (data['type'] as String?) ?? '';
                    final ts = (data['ts'] as String?) ?? '';
                    final spaId = (data['spaId'] as String?) ?? '';
                    return _NotificationTile(
                      title: title,
                      body: body,
                      type: type,
                      timestamp: ts,
                      spaId: spaId,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String body;
  final String type;
  final String timestamp;
  final String spaId;

  const _NotificationTile({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.spaId,
  });

  IconData _icon() {
    switch (type) {
      case 'submission':
        return Icons.send_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _color(BuildContext context) {
    switch (type) {
      case 'submission':
        return Theme.of(context).colorScheme.primary;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _color(context).withOpacity(0.3), width: 1.0),
      ),
      child: ListTile(
        leading: Icon(_icon(), color: _color(context)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
        ),
        subtitle: Text(body, style: TextStyle(fontSize: 13.sp)),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          if (spaId.isNotEmpty) {
            Navigator.pushNamed(
              context,
              '/spa-detail',
              arguments: SpaDetailArgs(spaId),
            );
          }
        },
      ),
    );
  }
}
