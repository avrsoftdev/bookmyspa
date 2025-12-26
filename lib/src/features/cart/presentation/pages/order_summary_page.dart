import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/cart_bloc.dart';
import '../../domain/entities/cart_item.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/di/di.dart';
import '../../../bookings/presentation/controllers/bookings_controller.dart';
import '../../../bookings/domain/entities/booking.dart';

class OrderSummaryPage extends StatefulWidget {
  const OrderSummaryPage({super.key});

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  DateTime? selectedDate;
  String? selectedSlot;

  List<String> get timeSlots => [
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '1:00 PM',
        '2:00 PM',
        '3:00 PM',
        '4:00 PM',
        '5:00 PM',
        '6:00 PM',
        '7:00 PM',
        '8:00 PM',
      ];

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
      });
    }
  }

  String formatSelectedDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocBuilder<CartBloc, CartState>(
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
                  SizedBox(height: 8.h),
                  Text(
                    'Add some services to see your order summary',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
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
                    _BookingScheduleCard(
                      selectedDate: selectedDate,
                      selectedSlot: selectedSlot,
                      timeSlots: timeSlots,
                      onSelectDate: () => pickDate(context),
                      onSelectSlot: (slot) {
                        setState(() {
                          selectedSlot = slot;
                        });
                      },
                      formatSelectedDate: formatSelectedDate,
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
              ),
            ],
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
          // Service Icon
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

          // Service Details
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

          // Total Price
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

  const _ProceedToPayButton({
    required this.totalAmount,
    required this.selectedDate,
    required this.selectedSlot,
    required this.formatSelectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final totalWithTax = totalAmount * 1.18; // Add 18% GST

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

  void _showPaymentDialog(BuildContext context, double amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              if (selectedDate != null && selectedSlot != null) SizedBox(height: 8.h),
              Text(
                'Payment integration will be implemented here',
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final items = context.read<CartBloc>().state.items;
                final scheduledAt = _buildScheduledDateTime();
                final bookings = items
                    .map(
                      (i) => Booking(
                        id: '${DateTime.now().millisecondsSinceEpoch}-${i.serviceId}',
                        serviceId: i.serviceId,
                        serviceName: i.serviceName,
                        quantity: i.quantity,
                        unitPrice: i.price,
                        totalPrice: i.totalPrice,
                        scheduledAt: scheduledAt,
                        createdAt: DateTime.now(),
                      ),
                    )
                    .toList();
                sl.get<BookingsController>().addAll(bookings);
                context.read<CartBloc>().add(ClearCart());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment successful! Booking created.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                  arguments: 1,
                );
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
    final parts = slot.split(' ');
    final timePart = parts.first;
    final periodPart = parts.length > 1 ? parts[1].toUpperCase() : 'AM';
    final timePieces = timePart.split(':');
    final hour12 = int.tryParse(timePieces[0]) ?? 0;
    final minute = timePieces.length > 1 ? int.tryParse(timePieces[1]) ?? 0 : 0;
    int hour = hour12 % 12;
    if (periodPart == 'PM') {
      hour += 12;
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

class _BookingScheduleCard extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedSlot;
  final List<String> timeSlots;
  final VoidCallback onSelectDate;
  final void Function(String) onSelectSlot;
  final String Function(DateTime) formatSelectedDate;

  const _BookingScheduleCard({
    required this.selectedDate,
    required this.selectedSlot,
    required this.timeSlots,
    required this.onSelectDate,
    required this.onSelectSlot,
    required this.formatSelectedDate,
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
                  selectedDate != null ? formatSelectedDate(selectedDate!) : 'Select Date',
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
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: timeSlots.map((slot) {
              final isSelected = slot == selectedSlot;
              return ChoiceChip(
                label: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onSelectSlot(slot),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFF2A2A2A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[700]!,
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
