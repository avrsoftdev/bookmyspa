# Order Summary Feature

## Overview
The Order Summary page provides users with a complete view of their selected services before proceeding to payment.

## Features

### Order Summary Page (`/order-summary`)
- **Complete Order Review**: Shows all selected services with quantities and prices
- **Price Breakdown**: Displays subtotal, GST (18%), and total amount
- **Proceed to Pay Button**: Shows total payable amount and initiates payment flow

### Navigation Flow
1. User adds services to cart on Services page
2. User clicks "Buy Now" button in cart summary bar
3. User is navigated to Order Summary page
4. User reviews order and clicks "Proceed to Pay ₹[amount]"
5. Payment dialog appears (placeholder for payment integration)

### Components

#### OrderSummaryPage
- Main page component that displays the complete order summary
- Shows empty state when cart is empty
- Handles navigation and payment flow

#### _OrderItemCard
- Individual service item display with icon, name, quantity, and total price
- Consistent with app's dark theme design

#### _OrderSummaryCard
- Price breakdown section showing subtotal, GST, and total
- Clear financial summary for transparency

#### _ProceedToPayButton
- Fixed bottom button showing total amount
- Triggers payment dialog when pressed

### Payment Integration
Currently shows a placeholder dialog. Ready for integration with:
- Razorpay
- Stripe
- PayPal
- Other payment gateways

### State Management
- Uses existing CartBloc for cart state management
- Automatically clears cart after successful payment
- Shows success message and navigates back to home

### Styling
- Consistent with app's dark theme
- Uses primary color (AppColors.primary) for accents
- Responsive design with ScreenUtil
- Professional UI with proper spacing and typography