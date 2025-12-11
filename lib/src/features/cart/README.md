# Cart Feature

This feature implements a shopping cart system for spa services with the following functionality:

## Features

### Service Cards
- Each service card displays service name and price
- "Add Service" button in the bottom-right corner of each card
- When tapped, the button transforms into a quantity selector

### Quantity Selector
- Shows current quantity (starts at 1)
- Plus (+) button to increase quantity
- Minus (-) button to decrease quantity
- When quantity reaches 0, reverts back to "Add Service" button

### Cart Summary Bar
- Appears at the bottom of the screen when items are in cart
- Shows total number of items
- Shows total payable amount
- "Buy Now" button for checkout (placeholder for now)

## Example Usage

1. User sees "Massage - ₹400" service card
2. Taps "Add Service" button
3. Button transforms to quantity selector showing "1"
4. User taps "+" to increase to 3
5. Cart summary shows "3 items - ₹1200"

## Implementation Details

### State Management
- Uses BlocPattern with `CartBloc`
- `CartState` tracks items, total amount, and total items
- Events: `AddToCart`, `RemoveFromCart`, `UpdateQuantity`, `ClearCart`

### Models
- `CartItem`: Represents a service in the cart with quantity and price
- Automatically calculates total price per item (price × quantity)

### Widgets
- `CartSummaryBar`: Bottom bar showing cart totals
- `QuantitySelector`: Interactive quantity control widget
- Updated `_ServicePricingCard`: Service card with cart integration

## Files Structure
```
lib/src/features/cart/
├── domain/
│   └── entities/
│       └── cart_item.dart
├── presentation/
│   ├── bloc/
│   │   └── cart_bloc.dart
│   └── widgets/
│       ├── cart_summary_bar.dart
│       └── quantity_selector.dart
└── README.md
```