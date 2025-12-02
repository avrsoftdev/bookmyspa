import 'package:flutter/material.dart';
import '../bloc/location_bloc.dart';

class LocationWidget extends StatelessWidget {
  final LocationBloc locationBloc;
  final Widget Function(String address)? onLocationFound;
  final Widget Function(String error)? onLocationError;
  final Widget? loadingWidget;

  const LocationWidget({
    super.key,
    required this.locationBloc,
    this.onLocationFound,
    this.onLocationError,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: locationBloc,
      builder: (context, child) {
        final state = locationBloc.state;
        
        switch (state.status) {
          case LocationStatus.loading:
            return loadingWidget ?? 
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Getting location...'),
                ],
              );
              
          case LocationStatus.success:
            if (state.location != null) {
              return onLocationFound?.call(state.location!.address) ??
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.location!.address,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
            }
            return const SizedBox.shrink();
            
          case LocationStatus.error:
            return onLocationError?.call(state.errorMessage ?? 'Location error') ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_off, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  const Text(
                    'Location unavailable',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              );
              
          case LocationStatus.initial:
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}