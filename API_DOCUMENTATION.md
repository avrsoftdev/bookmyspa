# Most Booked Services - API Documentation

## Overview
This document describes the implementation of the "Most Booked Services" feature which displays the top 5 most-booked subcategories globally across all users.

## Components

### 1. SubcategoryPreferences
**Location:** `lib/src/features/home/data/subcategory_preferences.dart`

A utility class that manages subcategory booking statistics using SharedPreferences.

#### Methods

```dart
/// Increments the view count for a subcategory
Future<void> incrementSubcategory(String subcategory)
```
- **Parameters:** 
  - `subcategory` - Name of the subcategory (e.g., "Swedish Massage", "Deep Tissue")
- **Returns:** `Future<void>`
- **Usage Example:**
  ```dart
  await SubcategoryPreferences().incrementSubcategory('Swedish Massage');
  ```
- **Called from:** SubcategorySpaListPage.initState()

```dart
/// Retrieves the top 5 most-booked subcategories
Future<List<String>> getMostBookedSubcategories()
```
- **Parameters:** None
- **Returns:** `Future<List<String>>` - Sorted list of subcategories (highest count first), max 5 items
- **Usage Example:**
  ```dart
  final topServices = await SubcategoryPreferences().getMostBookedSubcategories();
  // Returns: ['Swedish Massage', 'Deep Tissue', 'Facial', 'Pedicure', 'Manicure']
  ```
- **Called from:** MostBookedServices._loadMostBookedSubcategories()

### 2. MostBookedServices Widget
**Location:** `lib/src/features/home/presentation/widgets/most_booked_services.dart`

A stateful widget that displays the top 5 most-booked subcategories in a horizontal scrollable list.

#### Features
- Automatically loads data on widget initialization
- Displays numbered ranking (1-5) with distinct colors
- Horizontal scrolling for all 5 items
- Hides automatically if no data available (returns empty SizedBox)
- Tappable cards for navigation to subcategory spa list

#### UI Specifications
- **Height:** 120.h (flutter_screenutil responsive)
- **Card Width:** 100.w per item
- **Ranking Colors:**
  - 1st: Red (#FF6B6B)
  - 2nd: Teal (#4ECDC4)
  - 3rd: Yellow (#FFE66D)
  - 4th: Mint (#95E1D3)
  - 5th: Purple (#A29BFE)

#### Navigation
When a subcategory card is tapped:
```dart
Navigator.of(context).pushNamed(
  '/subcategory-spas',
  arguments: {
    'category': '',
    'subcategory': 'Subcategory Name',
  },
);
```

### 3. Modified: SubcategorySpaListPage
**Location:** `lib/src/features/spa_browse/presentation/pages/subcategory_spa_list_page.dart`

#### Changes
- Added import: `import '../../home/data/subcategory_preferences.dart';`
- Added initState method to record subcategory views:
  ```dart
  @override
  void initState() {
    super.initState();
    _recordSubcategoryView();
  }

  Future<void> _recordSubcategoryView() async {
    await SubcategoryPreferences().incrementSubcategory(widget.subcategory);
  }
  ```

This automatically increments the view count whenever a user navigates to view spas for a specific subcategory.

### 4. Integration: HomePage
**Location:** `lib/src/features/home/presentation/pages/home_page.dart`

#### Changes
- Added import: `import 'package:bookmyspa/src/features/home/presentation/widgets/most_booked_services.dart';`
- Added widget to home page column:
  ```dart
  const MostBookedServices(),
  const SizedBox(height: 16),
  ```
- Positioned between PopularCategories and BrandingFooter

## Data Flow

### Recording a Booking View
1. User navigates from home screen to "Most Booked Services" section
2. User taps on a subcategory card
3. App navigates to `/subcategory-spas` route with subcategory name
4. SubcategorySpaListPage.initState() is called
5. `incrementSubcategory()` updates SharedPreferences
6. View count is incremented: `"Massage:15"` → `"Massage:16"`

### Displaying Most Booked Services
1. HomePage is displayed
2. MostBookedServices widget loads
3. `getMostBookedSubcategories()` is called
4. SharedPreferences is read and parsed
5. Data is sorted by count (descending)
6. Top 5 are returned and displayed
7. Each card shows ranking number (1-5) and service name

## Data Storage Format

**SharedPreferences Key:** `most_booked_subcategories`

**Storage Format:** List of strings with format `name:count`

**Example:**
```dart
[
  'Swedish Massage:45',
  'Deep Tissue:38',
  'Facial:32',
  'Pedicure:28',
  'Manicure:25',
]
```

## Testing Notes

### Manual Testing Steps
1. Open the app and navigate to home page
2. No "Most Booked Services" section should appear (will be hidden initially)
3. Navigate to any subcategory through "Suggested for you" or category grid
4. Close and reopen app
5. "Most Booked Services" section should now appear with that subcategory
6. Navigate to more subcategories to build up the rankings
7. Verify top 5 are displayed in correct order

### Edge Cases
- **No bookings yet:** Widget returns empty SizedBox.shrink() (hidden)
- **Less than 5 unique subcategories:** Shows only available ones
- **New subcategory added:** Automatically included in next load cycle
- **Multiple taps on same category:** Count is properly aggregated

## Performance Considerations
- SharedPreferences reads are cached in-device (very fast)
- No network calls required
- Sorting is done in-memory (minimal overhead)
- Widget update only occurs when page is reloaded/navigated back to

## Future Enhancements
- Add time-based decay (recent bookings weighted higher)
- Track bookings per region/city (not global)
- Add analytics integration to track actual bookings vs. views
- Implement Firestore-backed system for multi-device sync
- Add recommendation algorithm based on user history

## Dependencies
- `shared_preferences: ^2.0.0` (already in project)
- `flutter_screenutil: ^5.0.0` (already in project)
- Standard Flutter Material widgets
