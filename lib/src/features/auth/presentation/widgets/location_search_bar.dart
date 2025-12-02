import 'package:bookmyspa/src/features/location/presentation/bloc/location_bloc.dart';
import 'package:bookmyspa/src/features/location/presentation/widgets/location_widget.dart';
import 'package:flutter/material.dart';

class LocationSearchBar extends StatelessWidget {
  final LocationBloc locationBloc;
  final String? overriddenAddress;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;

  const LocationSearchBar({
    super.key,
    required this.locationBloc,
    this.overriddenAddress,
    required this.onRefresh,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: LocationWidget(
              locationBloc: locationBloc,
              onLocationFound: (address) => Text(
                overriddenAddress ?? address,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              onLocationError: (_) => const Text(
                'Tap to detect your location',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              loadingWidget: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: Colors.deepPurple,
            onPressed: onRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.edit_location_alt_rounded),
            color: Colors.deepPurple,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}