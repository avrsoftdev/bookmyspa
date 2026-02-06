import 'package:flutter/material.dart';
import '../../../../core/di/di.dart';
import '../controllers/bookings_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../domain/entities/booking.dart';

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

    // Group by transactionId
    final Map<String, List<Booking>> groups = {};
    for (final b in controller.bookings) {
      final key = (b.transactionId).toString().isNotEmpty
          ? b.transactionId
          : b.id;
      groups.putIfAbsent(key, () => []).add(b);
    }
    final grouped = groups.values.toList()
      ..sort((a, b) => b.first.scheduledAt.compareTo(a.first.scheduledAt));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = grouped[index];
        return _CustomerTransactionCard(bookings: tx);
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

class _CustomerTransactionCard extends StatelessWidget {
  final List<Booking> bookings;
  const _CustomerTransactionCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    final first = bookings.first;
    final total = bookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final dateText =
        '${first.scheduledAt.day.toString().padLeft(2, '0')}/${first.scheduledAt.month.toString().padLeft(2, '0')}/${first.scheduledAt.year}';
    final timeText =
        '${first.scheduledAt.hour.toString().padLeft(2, '0')}:${first.scheduledAt.minute.toString().padLeft(2, '0')}';

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
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpaName(spaId: first.spaId),
                  const SizedBox(height: 4),
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
              '₹${total.toStringAsFixed(0)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...bookings.map((b) {
            final parsed = _parseServiceName(b.serviceName);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parsed.subcategory,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ' Duration: ${parsed.durationLabel} • No. of service: ${b.quantity}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${b.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  _ParsedService _parseServiceName(String name) {
    final parts = name.split(' • ');
    final service = parts.isNotEmpty ? parts.first : name;
    final rest = parts.length > 1 ? parts[1] : '';
    final subParts = rest.split(' — ');
    final sub = subParts.isNotEmpty ? subParts.first : '';
    final label = subParts.length > 1 ? subParts[1] : '';
    return _ParsedService(
      service: service,
      subcategory: sub,
      durationLabel: label,
    );
  }
}

class _ParsedService {
  final String service;
  final String subcategory;
  final String durationLabel;
  _ParsedService({
    required this.service,
    required this.subcategory,
    required this.durationLabel,
  });
}
