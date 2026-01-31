import 'package:bookmyspa/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../bloc/cart_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/di/di.dart';
import '../../../bookings/presentation/controllers/bookings_controller.dart';
import '../../../bookings/domain/entities/booking.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderSummaryPage extends StatefulWidget {
  final String spaId;
  const OrderSummaryPage({super.key, required this.spaId});
  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  DateTime? selectedDate;
  String? selectedSlot;

  @override
  void initState() {
    super.initState();
    // Subscribe to real-time bookings for this spa
    sl.get<BookingsController>().subscribeToSpa(widget.spaId);
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null; // Reset slot when date changes
      });
    }
  }

  String formatSelectedDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Helper to parse time strings (supports "10:00 AM" and "14:00")
  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      // sanitize spaces (e.g. non-breaking spaces)
      final cleaned = timeStr.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Try standard "10:00 AM" / "10:00 PM"
      if (cleaned.toUpperCase().contains('AM') ||
          cleaned.toUpperCase().contains('PM')) {
        try {
          final dt = DateFormat('h:mm a').parse(cleaned);
          return TimeOfDay.fromDateTime(dt);
        } catch (_) {
          // Fallback to DateFormat.jm() if strict parsing fails
          final dt = DateFormat.jm().parse(cleaned);
          return TimeOfDay.fromDateTime(dt);
        }
      }

      // Try 24-hour format "HH:mm"
      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        final hour = int.parse(parts[0].trim());
        final minutePart = parts[1].trim();
        // Remove any non-digit suffix just in case
        final minute = int.parse(minutePart.replaceAll(RegExp(r'[^\d]'), ''));
        return TimeOfDay(hour: hour, minute: minute);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  List<String> _generateTimeSlots(SpaEntity spa) {
    final start = _parseTime(spa.openingTime);
    final end = _parseTime(spa.closingTime);

    if (start == null || end == null) return [];

    final slots = <String>[];
    // Use an arbitrary date to handle time calculations
    var current = DateTime(2024, 1, 1, start.hour, start.minute);
    var endTime = DateTime(2024, 1, 1, end.hour, end.minute);

    // Handle overnight case (e.g. 10 PM to 2 AM)
    if (endTime.isBefore(current)) {
      endTime = endTime.add(const Duration(days: 1));
    }

    while (current.isBefore(endTime)) {
      final next = current.add(const Duration(hours: 1));
      if (next.isAfter(endTime)) break;

      // Force consistent format "10:00 AM"
      final startStr = DateFormat('h:mm a').format(current);
      final endStr = DateFormat('h:mm a').format(next);
      slots.add("$startStr – $endStr");

      current = next;
    }
    return slots;
  }

  bool _isSlotDisabled(String slot, SpaEntity spa) {
    if (selectedDate == null) return true; // Must select date first
    if (spa.maxBookingsPerHour == null) return false; // No limit

    // Check if slot is in the past for today
    if (selectedDate != null) {
      final now = DateTime.now();
      final isToday =
          selectedDate!.year == now.year &&
          selectedDate!.month == now.month &&
          selectedDate!.day == now.day;
      if (isToday) {
        final slotStartStr = slot.split('–').first.trim();
        final slotTime = _parseTime(slotStartStr);
        if (slotTime != null) {
          final slotDt = DateTime(
            now.year,
            now.month,
            now.day,
            slotTime.hour,
            slotTime.minute,
          );
          if (slotDt.isBefore(now)) return true;
        }
      }
    }

    // Check booking limit
    // We access the controller via get_it or context if provided
    // Here we use sl.get based on previous code usage
    final controller = sl.get<BookingsController>();
    // Note: getBookingCount needs to notify listeners to trigger rebuild if we want real-time updates.
    // Ideally this widget should listen to BookingsController.
    // For now, we assume static check at build time.
    final count = controller.getBookingCount(spa.id, selectedDate!, slot);
    return count >= spa.maxBookingsPerHour!;
  }

  @override
  Widget build(BuildContext context) {
    // spaId is required in widget constructor, so it's guaranteed to be non-null
    final useCase = sl.get<StreamSpaByIdUseCase>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Order Summary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<SpaEntity?>(
        stream: useCase(widget.spaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final spa = snapshot.data;
          if (spa == null) {
            return const Center(
              child: Text(
                "Spa not found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final timeSlots = _generateTimeSlots(spa);

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        _buildSectionHeader('Select Date & Time'),
                        SizedBox(height: 12.h),
                        // We need to listen to BookingsController for updates
                        AnimatedBuilder(
                          animation: sl.get<BookingsController>(),
                          builder: (context, _) {
                            return _BookingScheduleCard(
                              selectedDate: selectedDate,
                              selectedSlot: selectedSlot,
                              timeSlots: timeSlots,
                              onSelectDate: () => pickDate(context),
                              onSelectSlot: (slot) {
                                if (!_isSlotDisabled(slot, spa)) {
                                  setState(() {
                                    selectedSlot = slot;
                                  });
                                }
                              },
                              formatSelectedDate: formatSelectedDate,
                              isSlotDisabled: (slot) =>
                                  _isSlotDisabled(slot, spa),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Order Items'),
                        SizedBox(height: 12.h),
                        ...cartState.items.map(
                          (item) => _OrderItemCard(item: item),
                        ),
                        SizedBox(height: 24.h),
                        _buildSectionHeader('Order Summary'),
                        SizedBox(height: 12.h),
                        _OrderSummaryCard(cartState: cartState),
                      ],
                    ),
                  ),
                  _ProceedToPayButton(
                    totalAmount: cartState.totalAmount,
                    selectedDate: selectedDate,
                    selectedSlot: selectedSlot,
                    formatSelectedDate: formatSelectedDate,
                    spaId: widget.spaId,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  final CartItem item;

  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.serviceName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹${item.price.toStringAsFixed(0)} each',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartState cartState;

  const _OrderSummaryCard({required this.cartState});

  @override
  Widget build(BuildContext context) {
    final subtotal = cartState.totalAmount;
    final tax = subtotal * 0.18; // 18% GST
    final total = subtotal + tax;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(0)}'),
          SizedBox(height: 8.h),
          _buildSummaryRow('GST (18%)', '₹${tax.toStringAsFixed(0)}'),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey[700], thickness: 1),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            'Total Amount',
            '₹${total.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[300],
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isTotal ? AppColors.primary : Colors.grey[300],
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProceedToPayButton extends StatelessWidget {
  final double totalAmount;
  final DateTime? selectedDate;
  final String? selectedSlot;
  final String Function(DateTime) formatSelectedDate;
  final String spaId;

  const _ProceedToPayButton({
    required this.totalAmount,
    required this.selectedDate,
    required this.selectedSlot,
    required this.formatSelectedDate,
    required this.spaId,
  });

  @override
  Widget build(BuildContext context) {
    final totalWithTax = totalAmount * 1.18;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: AppColors.primary, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (selectedDate == null || selectedSlot == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please select a date and time slot'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              _showPaymentDialog(context, totalWithTax);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Proceed to Pay ₹${totalWithTax.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext outerContext, double amount) {
    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(color: AppColors.primary, width: 1),
          ),
          title: Text(
            'Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.payment_rounded,
                size: 60.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Total Amount: ₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              if (selectedDate != null && selectedSlot != null)
                Text(
                  'Appointment: ${formatSelectedDate(selectedDate!)} at $selectedSlot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              if (selectedDate != null && selectedSlot != null)
                SizedBox(height: 8.h),
              Text(
                'Payment integration will be implemented here',
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final authController = sl.get<AuthController>();
                  final user = authController.currentUser;
                  final userId =
                      user?.id ??
                      'guest_${DateTime.now().millisecondsSinceEpoch}';
                  final userName = user?.name ?? 'Guest';
                  final userEmail = user?.email;

                  final items = outerContext.read<CartBloc>().state.items;
                  final scheduledAt = _buildScheduledDateTime();
                  final transactionId =
                      'tx_${spaId}_${DateTime.now().millisecondsSinceEpoch}_$userId';
                  final bookings = items
                      .map(
                        (i) => Booking(
                          id: '${DateTime.now().millisecondsSinceEpoch}-${i.serviceId}',
                          transactionId: transactionId,
                          spaId: spaId,
                          serviceId: i.serviceId,
                          serviceName: i.serviceName,
                          quantity: i.quantity,
                          unitPrice: i.price,
                          totalPrice: i.totalPrice,
                          scheduledAt: scheduledAt,
                          createdAt: DateTime.now(),
                          userId: userId,
                          userName: userName,
                          userEmail: userEmail,
                        ),
                      )
                      .toList();

                  await sl.get<BookingsController>().addAll(bookings);
                  try {
                    final spa = await sl
                        .get<StreamSpaByIdUseCase>()(spaId)
                        .first;
                    final spaName = spa?.businessName ?? 'Selected Spa';
                    final nServices = items.length;
                    final dateStr = formatSelectedDate(selectedDate!);
                    final slotStr = selectedSlot!;
                    final nowIso = DateTime.now().toUtc().toIso8601String();
                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .doc(transactionId)
                        .set({
                          'userId': userId,
                          'spaId': spaId,
                          'transactionId': transactionId,
                          'type': 'booking',
                          'title': 'Booking Confirmed',
                          'body':
                              'Your booking for $nServices service(s) at $spaName on $dateStr at $slotStr is confirmed.',
                          'ts': nowIso,
                        });
                  } catch (_) {}

                  if (outerContext.mounted) {
                    outerContext.read<CartBloc>().add(ClearCart());
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Payment successful! Booking created.',
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(outerContext).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                      arguments: 1,
                    );
                  }
                } catch (e) {
                  if (outerContext.mounted) {
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      SnackBar(
                        content: Text('Payment failed: $e'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
              ),
              child: Text(
                'Pay Now',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  DateTime _buildScheduledDateTime() {
    final date = selectedDate!;
    final slot = selectedSlot!;
    // slot is "10:00 AM – 11:00 AM"
    // We parse the first part. The separator used is '–' (en-dash).
    final parts = slot.split('–');
    var startStr = parts.first.trim();

    // Sanitize spaces (replace non-breaking space \u00A0 with normal space)
    startStr = startStr.replaceAll(RegExp(r'\s+'), ' ');

    try {
      // Use the same format as used in generation: DateFormat('h:mm a')
      final dateFormat = DateFormat('h:mm a');
      final dt = dateFormat.parse(startStr);
      return DateTime(date.year, date.month, date.day, dt.hour, dt.minute);
    } catch (e) {
      // Fallback: try DateFormat.jm() or just rethrow
      try {
        final dt = DateFormat.jm().parse(startStr);
        return DateTime(date.year, date.month, date.day, dt.hour, dt.minute);
      } catch (_) {
        // Last resort: simple manual parse if format is "HH:mm" or similar
        if (startStr.contains(':')) {
          final p = startStr.split(':');
          final h = int.tryParse(p[0].trim()) ?? 0;
          final mStr = p[1].trim().split(' ').first;
          final m = int.tryParse(mStr) ?? 0;
          // naive AM/PM handling if parse failed
          var hour = h;
          if (startStr.toUpperCase().contains('PM') && hour < 12) hour += 12;
          if (startStr.toUpperCase().contains('AM') && hour == 12) hour = 0;
          return DateTime(date.year, date.month, date.day, hour, m);
        }
        throw FormatException("Invalid time format: $startStr");
      }
    }
  }
}

class _BookingScheduleCard extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedSlot;
  final List<String> timeSlots;
  final VoidCallback onSelectDate;
  final void Function(String) onSelectSlot;
  final String Function(DateTime) formatSelectedDate;
  final bool Function(String) isSlotDisabled;

  const _BookingScheduleCard({
    required this.selectedDate,
    required this.selectedSlot,
    required this.timeSlots,
    required this.onSelectDate,
    required this.onSelectSlot,
    required this.formatSelectedDate,
    required this.isSlotDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onSelectDate,
                child: Text(
                  selectedDate != null
                      ? formatSelectedDate(selectedDate!)
                      : 'Select Date',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Time Slot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          if (timeSlots.isEmpty)
            Text(
              "No slots available",
              style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: timeSlots.map((slot) {
                final isSelected = slot == selectedSlot;
                final isDisabled = isSlotDisabled(slot);

                return ChoiceChip(
                  label: Text(
                    slot,
                    style: TextStyle(
                      color: isDisabled
                          ? Colors.grey[600]
                          : (isSelected ? Colors.black : Colors.white),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isDisabled ? null : (_) => onSelectSlot(slot),
                  selectedColor: AppColors.primary,
                  disabledColor: const Color(0xFF111111),
                  backgroundColor: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: isDisabled
                          ? Colors.transparent
                          : (isSelected
                                ? AppColors.primary
                                : Colors.grey[700]!),
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
