# Location Feature

This feature provides automatic location detection functionality for the BookMySpa app.

## Architecture

The location feature follows clean architecture principles:

### Domain Layer
- **Entities**: `LocationEntity` - represents location data
- **Repositories**: `LocationRepository` - abstract interface for location operations
- **Use Cases**: `GetCurrentLocationUseCase` - business logic for getting current location

### Data Layer
- **Repository Implementation**: `LocationRepositoryImpl` - concrete implementation using geolocator and geocoding packages

### Presentation Layer
- **Bloc**: `LocationBloc` - state management for location operations
- **Widgets**: `LocationWidget` - reusable UI component for displaying location
- **Pages**: Example page showing usage

## Usage

### 1. Automatic Location Detection
The app automatically detects location when it opens (implemented in `HomePage`).

### 2. Manual Location Refresh
Users can manually refresh their location using the refresh button.

### 3. Using LocationWidget
```dart
LocationWidget(
  locationBloc: locationBloc,
  onLocationFound: (address) => Text(address),
  onLocationError: (error) => Text('Error: $error'),
  loadingWidget: CircularProgressIndicator(),
)
```

### 4. Using LocationBloc Directly
```dart
final locationBloc = sl.get<LocationBloc>();
locationBloc.getCurrentLocation();

// Listen to state changes
locationBloc.addListener(() {
  final state = locationBloc.state;
  switch (state.status) {
    case LocationStatus.success:
      print('Location: ${state.location?.address}');
      break;
    case LocationStatus.error:
      print('Error: ${state.errorMessage}');
      break;
    // ... handle other states
  }
});
```

## Permissions

### Android
Added to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
Added to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to show nearby spas and services.</string>
```

## Dependencies

- `geolocator: ^12.0.0` - For getting device location
- `geocoding: ^3.0.0` - For converting coordinates to addresses
- `permission_handler: ^11.3.1` - For handling location permissions

## Error Handling

The feature handles various error scenarios:
- Location services disabled
- Permission denied
- Location unavailable
- Network issues for geocoding

All errors are properly propagated through the bloc state and can be displayed to users.