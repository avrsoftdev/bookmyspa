import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/di.dart';
import '../../../../core/services/home_location_places_service.dart';
import '../../domain/entities/location_entity.dart';
import '../bloc/location_bloc.dart';
import '../controllers/home_location_picker_controller.dart';

class HomeLocationPickerPage extends StatefulWidget {
  const HomeLocationPickerPage({super.key});

  @override
  State<HomeLocationPickerPage> createState() => _HomeLocationPickerPageState();
}

class _HomeLocationPickerPageState extends State<HomeLocationPickerPage> {
  late final LocationBloc _locationBloc;
  late final HomeLocationPickerController _controller;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  GoogleMapController? _mapController;

  static const LatLng _fallback = LatLng(28.6139, 77.2090);
  static final LatLngBounds _indiaBounds = LatLngBounds(
    southwest: LatLng(6.4627, 68.1097),
    northeast: LatLng(35.5133, 97.3956),
  );
  LatLng _selectedLatLng = _fallback;
  LocationEntity? _selectedLocation;
  bool _resolvingMapAddress = false;
  bool _mapReady = false;
  bool _isTypingQuery = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
    _controller = HomeLocationPickerController(
      service: sl.get<HomeLocationPlacesService>(),
      biasLatProvider: () => _locationBloc.state.location?.latitude,
      biasLngProvider: () => _locationBloc.state.location?.longitude,
    );
    _searchController.addListener(() {
      final hasFocus = _searchFocusNode.hasFocus;
      final text = _searchController.text.trim();
      final typingNow = hasFocus && text.length >= 3;
      if (_isTypingQuery != typingNow && mounted) {
        setState(() {
          _isTypingQuery = typingNow;
        });
      }
      _controller.onQueryChanged(_searchController.text);
      if (mounted) {
        setState(() {});
      }
    });
    _searchFocusNode.addListener(() {
      if (!mounted) return;
      final text = _searchController.text.trim();
      setState(() {
        _isTypingQuery = _searchFocusNode.hasFocus && text.length >= 3;
      });
    });

    final current = _locationBloc.state.location;
    if (current != null &&
        _isWithinIndia(LatLng(current.latitude, current.longitude))) {
      _selectedLocation = current;
      _selectedLatLng = LatLng(current.latitude, current.longitude);
      _controller.suppressNextQuery = true;
      _searchController.text = current.address;
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _isWithinIndia(LatLng latLng) {
    return latLng.latitude >= _indiaBounds.southwest.latitude &&
        latLng.latitude <= _indiaBounds.northeast.latitude &&
        latLng.longitude >= _indiaBounds.southwest.longitude &&
        latLng.longitude <= _indiaBounds.northeast.longitude;
  }

  Future<void> _onSuggestionTap(HomeLocationSuggestion s) async {
    try {
      final location = await _controller.service.getPlaceAsLocation(s.placeId);
      final picked = LatLng(location.latitude, location.longitude);
      if (!_isWithinIndia(picked)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location in India')),
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _selectedLocation = location;
        _selectedLatLng = picked;
        _controller.suppressNextQuery = true;
        _searchController.text = location.address;
      });
      _controller.clearSuggestions();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLatLng, 16),
      );
      FocusScope.of(context).unfocus();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load selected place')),
      );
    }
  }

  Future<void> _onMapChanged(LatLng latLng) async {
    final previousLatLng = _selectedLatLng;
    if (!_isWithinIndia(latLng)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location in India')),
      );
      _mapController?.animateCamera(CameraUpdate.newLatLng(previousLatLng));
      return;
    }

    setState(() {
      _selectedLatLng = latLng;
      _resolvingMapAddress = true;
    });
    try {
      final marks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final first = marks.isNotEmpty ? marks.first : null;
      final parts = <String>[
        if ((first?.street ?? '').isNotEmpty) first!.street!,
        if ((first?.subLocality ?? '').isNotEmpty) first!.subLocality!,
        if ((first?.locality ?? '').isNotEmpty) first!.locality!,
        if ((first?.administrativeArea ?? '').isNotEmpty)
          first!.administrativeArea!,
        if ((first?.postalCode ?? '').isNotEmpty) first!.postalCode!,
        if ((first?.country ?? '').isNotEmpty) first!.country!,
      ];
      final address = parts.isEmpty
          ? '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}'
          : parts.join(', ');
      final country = first?.country ?? '';
      if (country.isNotEmpty && country.toLowerCase() != 'india') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location in India')),
        );
        setState(() {
          _selectedLatLng = previousLatLng;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(previousLatLng));
        return;
      }
      if (!mounted) return;
      setState(() {
        _selectedLocation = LocationEntity(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          address: address,
          city: first?.locality ?? first?.subAdministrativeArea ?? '',
          country: country,
        );
        _controller.suppressNextQuery = true;
        _searchController.text = address;
      });
      _controller.clearSuggestions();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedLocation = LocationEntity(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          address:
              '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}',
          city: '',
          country: '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _resolvingMapAddress = false;
        });
      }
    }
  }

  Future<void> _syncFieldWithPin() async {
    await _onMapChanged(_selectedLatLng);
  }

  void _clearLocationField() {
    FocusScope.of(context).unfocus();
    _controller.clearSuggestions();
    setState(() {
      _selectedLocation = null;
      _searchController.clear();
      _selectedLatLng = _fallback;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_selectedLatLng, 11),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marker = Marker(
      markerId: const MarkerId('selected-location'),
      position: _selectedLatLng,
      draggable: true,
      onDragEnd: _onMapChanged,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Select location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_controller.isLoading)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            if (_searchController.text.trim().isNotEmpty)
                              IconButton(
                                tooltip: 'Clear location',
                                onPressed: _clearLocationField,
                                icon: const Icon(Icons.close_rounded),
                              ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_isTypingQuery && _controller.suggestions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _controller.suggestions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final suggestion = _controller.suggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                suggestion.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _onSuggestionTap(suggestion),
                            );
                          },
                        ),
                      ),
                    if (_controller.errorMessage != null &&
                        _controller.errorMessage != 'No suggestions')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _controller.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLatLng,
                    zoom: 14,
                  ),
                  minMaxZoomPreference: const MinMaxZoomPreference(4, 19),
                  cameraTargetBounds: CameraTargetBounds(_indiaBounds),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  markers: {marker},
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (mounted) {
                      setState(() {
                        _mapReady = true;
                      });
                    }
                  },
                  onCameraMove: (position) {
                    _selectedLatLng = position.target;
                  },
                  onCameraIdle: _syncFieldWithPin,
                  onTap: _onMapChanged,
                ),
                if (!_mapReady)
                  const Center(child: CircularProgressIndicator()),
                IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 36,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                if (_mapReady)
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Colors.black.withValues(alpha: 0.55),
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                      // child: const Text(
                      //   'If map tiles are blank, enable Maps SDK for Android/iOS and allow this app in API key restrictions.',
                      //   style: TextStyle(color: Colors.white, fontSize: 11),
                      // ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _selectedLocation == null || _resolvingMapAddress
                      ? null
                      : () {
                          Navigator.of(context).pop(_selectedLocation);
                        },
                  icon: _resolvingMapAddress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Use this location'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
