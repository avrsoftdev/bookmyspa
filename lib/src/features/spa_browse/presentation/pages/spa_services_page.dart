import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../spa_browse/domain/entities/spa_entity.dart';
import '../../../spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';
import 'spa_detail_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/widgets/cart_summary_bar.dart';
import '../../../cart/presentation/widgets/quantity_selector.dart';
import '../../../cart/domain/entities/cart_item.dart';
//hd
class SpaServicesArgs {
  final String spaId;
  final String? selectedSubcategory;
  const SpaServicesArgs(this.spaId, {this.selectedSubcategory});
}

class SpaServicesPage extends StatelessWidget {
  final String spaId;
  final String? selectedSubcategory;
  const SpaServicesPage({
    super.key,
    required this.spaId,
    this.selectedSubcategory,
  });

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpaByIdUseCase>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text(
          'Services & Pricing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),

      body: StreamBuilder<SpaEntity?>(
        stream: useCase(spaId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
            );
          }

          final spa = snapshot.data;
          if (spa == null) {
            return Center(
              child: Text(
                "Spa not found",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            );
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _SpaHeaderCard(spa: spa),

              SizedBox(height: 28.h),

              Text(
                "Services & Pricing",
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 16.h),

              if (spa.serviceDetails.isEmpty ||
                  spa.serviceDetails.values.every((d) => d.plans.isEmpty))
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      "No pricing information available",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              else
                ...spa.serviceDetails.entries.expand((serviceEntry) {
                  final serviceName = serviceEntry.key;
                  final detail = serviceEntry.value;
                  final subFilter = selectedSubcategory?.trim().toLowerCase();
                  final subEntries = detail.plans.entries.where((subEntry) {
                    if (subFilter == null || subFilter.isEmpty) return true;
                    return subEntry.key.trim().toLowerCase() == subFilter;
                  });
                  return subEntries.expand((subEntry) {
                    final sub = subEntry.key;
                    final plans = subEntry.value;
                    return plans.map((plan) {
                      final mins = plan.durationMinutes;
                      final price = plan.price;
                      final label = mins >= 60
                          ? "${(mins / 60).toStringAsFixed(mins % 60 == 0 ? 0 : 1)} hr"
                          : "$mins min";
                      final cardName = "$sub — $label";
                      return _ServicePricingCard(
                        serviceName: "$serviceName • $cardName",
                        price: price.toString(),
                      );
                    });
                  });
                }),
            ],
          );
        },
      ),
      bottomNavigationBar: CartSummaryBar(
        onBuyNow: () {
          Navigator.pushNamed(context, '/order-summary');
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// SPA HEADER CARD (Dark Premium UI)
//////////////////////////////////////////////////////////////////

class _SpaHeaderCard extends StatefulWidget {
  final SpaEntity spa;
  const _SpaHeaderCard({required this.spa});
  @override
  State<_SpaHeaderCard> createState() => _SpaHeaderCardState();
}

class _SpaHeaderCardState extends State<_SpaHeaderCard> {
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
          duration: const Duration(milliseconds: 350),
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
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/spa-detail',
          arguments: SpaDetailArgs(spa.id),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.4),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: _buildImageCarousel(spa),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spa.businessName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          spa.fullAddress.isNotEmpty ? spa.fullAddress : spa.city,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Text(
                        "Tap for full details",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(SpaEntity spa) {
    if (spa.photos.isEmpty) {
      return Container(
        width: 90.w,
        height: 90.w,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        alignment: Alignment.center,
        child: Icon(
          Icons.spa_rounded,
          size: 40.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return SizedBox(
      width: 90.w,
      height: 90.w,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: spa.photos.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => Image.network(
              spa.photos[i],
              width: 90.w,
              height: 90.w,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
          ),
          if (spa.photos.length > 1)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(spa.photos.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: active ? 10.w : 6.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3.r),
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

//////////////////////////////////////////////////////////////////
// SERVICE PRICING CARD (Dark Theme)
//////////////////////////////////////////////////////////////////

class _ServicePricingCard extends StatelessWidget {
  final String serviceName;
  final String price;

  const _ServicePricingCard({required this.serviceName, required this.price});

  @override
  Widget build(BuildContext context) {
    final serviceId = '${serviceName}_${price}'; // Create unique ID
    final priceValue = double.tryParse(price) ?? 0.0;

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final cartItem = cartState.items.firstWhere(
          (item) => item.serviceId == serviceId,
          orElse: () => CartItem(
            serviceId: serviceId,
            serviceName: serviceName,
            price: priceValue,
            quantity: 0,
          ),
        );

        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.2),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      serviceName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "₹$price",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (cartItem.quantity == 0)
                    _AddServiceButton(
                      onTap: () {
                        context.read<CartBloc>().add(
                          AddToCart(
                            CartItem(
                              serviceId: serviceId,
                              serviceName: serviceName,
                              price: priceValue,
                              quantity: 1,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    QuantitySelector(
                      quantity: cartItem.quantity,
                      onIncrement: () {
                        context.read<CartBloc>().add(
                          UpdateQuantity(serviceId, cartItem.quantity + 1),
                        );
                      },
                      onDecrement: () {
                        context.read<CartBloc>().add(
                          UpdateQuantity(serviceId, cartItem.quantity - 1),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddServiceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddServiceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'Add Service',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
