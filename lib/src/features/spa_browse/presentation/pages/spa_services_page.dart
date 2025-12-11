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

class SpaServicesArgs {
  final String spaId;
  const SpaServicesArgs(this.spaId);
}

class SpaServicesPage extends StatelessWidget {
  final String spaId;
  const SpaServicesPage({super.key, required this.spaId});

  @override
  Widget build(BuildContext context) {
    final useCase = sl.get<StreamSpaByIdUseCase>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Services & Pricing',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<SpaEntity?>(
        stream: useCase(spaId),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final spa = snapshot.data;
          if (spa == null) {
            return const Center(
              child: Text("Spa not found", style: TextStyle(color: Colors.white)),
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
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 16.h),

              if (spa.pricing.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Text(
                      "No pricing information available",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                    ),
                  ),
                )
              else
                ...spa.pricing.map(
                  (pricing) => _ServicePricingCard(
                    serviceName: pricing.service,
                    price: pricing.price,
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CartSummaryBar(
        onBuyNow: null, // TODO: Implement checkout functionality
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// SPA HEADER CARD (Dark Premium UI)
//////////////////////////////////////////////////////////////////

class _SpaHeaderCard extends StatelessWidget {
  final SpaEntity spa;
  const _SpaHeaderCard({required this.spa});

  @override
  Widget build(BuildContext context) {
    final imageUrl = spa.photos.isNotEmpty ? spa.photos.first : null;

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
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.primary, width: 1.4),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // SPA IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 90.w,
                      height: 90.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90.w,
                      height: 90.w,
                      color: AppColors.primary.withOpacity(0.15),
                      child: Icon(Icons.spa_rounded,
                          size: 40.sp, color: AppColors.primary),
                    ),
            ),

            SizedBox(width: 16.w),

            // SPA INFO
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
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 16.sp, color: AppColors.primary),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          spa.fullAddress.isNotEmpty
                              ? spa.fullAddress
                              : spa.city,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[300],
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
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_rounded,
                          size: 14.sp, color: AppColors.primary),
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
}

//////////////////////////////////////////////////////////////////
// SERVICE PRICING CARD (Dark Theme)
//////////////////////////////////////////////////////////////////

class _ServicePricingCard extends StatelessWidget {
  final String serviceName;
  final String price;

  const _ServicePricingCard({
    required this.serviceName,
    required this.price,
  });

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
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.primary, width: 1.2),
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
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    "₹$price",
                    style: TextStyle(
                      color: AppColors.primary,
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
                          AddToCart(CartItem(
                            serviceId: serviceId,
                            serviceName: serviceName,
                            price: priceValue,
                            quantity: 1,
                          )),
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
            color: Colors.black,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
