import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import '../controllers/bookings_controller.dart';
import '../../domain/entities/booking.dart';

class SpaBookingsPage extends StatefulWidget {
  final String spaId;

  const SpaBookingsPage({super.key, required this.spaId});

  @override
  State<SpaBookingsPage> createState() => _SpaBookingsPageState();
}

class _SpaBookingsPageState extends State<SpaBookingsPage> {
  late BookingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = sl.get<BookingsController>();
    _controller.subscribeToSpa(widget.spaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Customer Bookings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final bookings = _controller.bookings;

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group by transactionId
          final Map<String, List<Booking>> groups = {};
          for (final b in bookings) {
            final key = (b.transactionId).toString().isNotEmpty ? b.transactionId : b.id;
            groups.putIfAbsent(key, () => []).add(b);
          }
          final grouped = groups.values.toList()
            ..sort((a, b) {
              final ad = a.first.scheduledAt;
              final bd = b.first.scheduledAt;
              return bd.compareTo(ad);
            });

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: grouped.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final tx = grouped[index];
              return _TransactionCard(bookings: tx);
            },
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final List<Booking> bookings;

  const _TransactionCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final first = bookings.first;
    final total = bookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    first.userName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16.sp,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${dateFormat.format(first.scheduledAt)} • ${timeFormat.format(first.scheduledAt)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '₹${total.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        children: [
          Divider(height: 1, color: Colors.grey[200]),
          SizedBox(height: 8.h),
          ...bookings.map((b) {
            final parsed = _parseServiceName(b.serviceName);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 16.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parsed.service,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Subcategory: ${parsed.subcategory} • Duration: ${parsed.durationLabel} • No. of service: ${b.quantity}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${b.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  _ParsedService _parseServiceName(String name) {
    // Expected: "Service • Subcategory — Label"
    final parts = name.split(' • ');
    final service = parts.isNotEmpty ? parts.first : name;
    final rest = parts.length > 1 ? parts[1] : '';
    final subParts = rest.split(' — ');
    final sub = subParts.isNotEmpty ? subParts.first : '';
    final label = subParts.length > 1 ? subParts[1] : '';
    return _ParsedService(service: service, subcategory: sub, durationLabel: label);
  }
}

class _ParsedService {
  final String service;
  final String subcategory;
  final String durationLabel;
  _ParsedService({required this.service, required this.subcategory, required this.durationLabel});
}
