import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/theme/tokens.dart';
import '../../../spa_browse/presentation/pages/spa_detail_page.dart';
import '../../../bookings/presentation/pages/spa_bookings_page.dart';
import '../controllers/notifications_controller.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

  void _enterSelectionMode() {
    setState(() {
      _selectionMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleSelectAll(List<String> allIds) {
    setState(() {
      if (_selectedIds.length == allIds.length && allIds.isNotEmpty) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(allIds);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    try {
      await sl.get<NotificationsController>().deleteNotifications(
        _selectedIds.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${_selectedIds.length} notification(s)'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    } finally {
      _exitSelectionMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = sl.get<AuthController>();
    final uid = auth.currentUser?.id;
    final controller = sl.get<NotificationsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.notifications.isEmpty) {
                return const SizedBox.shrink();
              }
              if (!_selectionMode) {
                return IconButton(
                  tooltip: 'Select',
                  icon: const Icon(Icons.check_box_outlined),
                  onPressed: _enterSelectionMode,
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Select All',
                    icon: const Icon(Icons.done_all),
                    onPressed: () => _toggleSelectAll(
                      controller.notifications
                          .map((e) => e['id'] as String)
                          .toList(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete Selected',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                  ),
                  IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close),
                    onPressed: _exitSelectionMode,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('Please login to view notifications'))
          : ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                if (controller.isLoading && controller.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = controller.notifications;

                // Sync selection with current list
                _selectedIds.removeWhere(
                  (id) => !docs.any((d) => d['id'] == id),
                );

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
                    final data = docs[index];
                    final id = data['id'] as String;
                    final title = (data['title'] as String?) ?? 'Notification';
                    final body = (data['body'] as String?) ?? '';
                    final type = (data['type'] as String?) ?? '';
                    final ts = (data['ts'] as String?) ?? '';
                    final spaId = (data['spaId'] as String?) ?? '';
                    final isRead = (data['isRead'] as bool?) ?? false;
                    final selected = _selectedIds.contains(id);

                    return _NotificationTile(
                      id: id,
                      title: title,
                      body: body,
                      type: type,
                      timestamp: ts,
                      spaId: spaId,
                      isRead: isRead,
                      selectionMode: _selectionMode,
                      selected: selected,
                      onToggleSelect: () => _toggleSelect(id),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: _selectionMode
          ? ListenableBuilder(
              listenable: controller,
              builder: (context, _) => SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value:
                            controller.notifications.isNotEmpty &&
                            _selectedIds.length ==
                                controller.notifications.length,
                        onChanged: (_) => _toggleSelectAll(
                          controller.notifications
                              .map((e) => e['id'] as String)
                              .toList(),
                        ),
                      ),
                      const Text('Select All'),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : _deleteSelected,
                        icon: const Icon(Icons.delete_outline),
                        label: Text('Delete (${_selectedIds.length})'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String type;
  final String timestamp;
  final String spaId;
  final bool isRead;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onToggleSelect;

  const _NotificationTile({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.spaId,
    required this.isRead,
    required this.selectionMode,
    required this.selected,
    required this.onToggleSelect,
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
    final bgColor = isRead
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _color(context).withOpacity(0.3), width: 1.0),
      ),
      child: ListTile(
        leading: selectionMode
            ? Checkbox(value: selected, onChanged: (_) => onToggleSelect())
            : Stack(
                children: [
                  Icon(_icon(), color: _color(context)),
                  if (!isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Text(body, style: TextStyle(fontSize: 13.sp)),
        trailing: selectionMode ? null : const Icon(Icons.chevron_right),
        onTap: () {
          if (selectionMode) {
            onToggleSelect();
            return;
          }

          // Mark as read
          if (!isRead) {
            sl.get<NotificationsController>().markAsRead(id);
          }

          if (spaId.isEmpty) return;
          if (type == 'booking') {
            // Distinguish between Owner (New Booking) and Customer (Booking Confirmed)
            if (title.toLowerCase().contains('new booking received')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpaBookingsPage(spaId: spaId),
                ),
              );
            } else {
              // Assume Customer notification -> Go to My Bookings tab
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
                arguments: 1, // Index 1 is My Bookings
              );
            }
          } else {
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
