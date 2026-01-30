import 'package:flutter/material.dart';
import '../../../../core/di/di.dart';
import '../controllers/bookings_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';

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
    controller = BookingsController(sl.get<BookingsRepository>());
    controller.addListener(_onChanged);
    final auth = sl.get<AuthController>();
    final uid = auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      controller.subscribeToUser(uid);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SpaName(spaId: b.spaId),
                    const SizedBox(height: 4),
                    Text(
                      b.serviceName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Qty: ${b.quantity}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${b.totalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Slot: $dateText at $timeText',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${b.createdAt.hour.toString().padLeft(2, '0')}:${b.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpaName extends StatelessWidget {
  final String spaId;
  const _SpaName({required this.spaId});

  @override
  Widget build(BuildContext context) {
    final stream = sl.get<StreamSpaByIdUseCase>().call(spaId);
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final name = snapshot.data?.businessName;
        return Text(
          name ?? 'Loading spa...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    );
  }
}
