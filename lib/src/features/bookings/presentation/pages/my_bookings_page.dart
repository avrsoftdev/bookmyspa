import 'package:flutter/material.dart';
import '../../../../core/di/di.dart';
import '../controllers/bookings_controller.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late BookingsController controller;

  @override
  void initState() {
    super.initState();
    controller = sl.get<BookingsController>();
    controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (controller.bookings.isEmpty) {
      return const Center(
        child: Text(
          'No bookings yet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = controller.bookings[index];
        final dateText =
            '${b.scheduledAt.day.toString().padLeft(2, '0')}/${b.scheduledAt.month.toString().padLeft(2, '0')}/${b.scheduledAt.year}';
        final timeText =
            '${b.scheduledAt.hour.toString().padLeft(2, '0')}:${b.scheduledAt.minute.toString().padLeft(2, '0')}';
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.deepPurple, width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.serviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Qty: ${b.quantity}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${b.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Slot: $dateText at $timeText',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${b.createdAt.hour.toString().padLeft(2, '0')}:${b.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
