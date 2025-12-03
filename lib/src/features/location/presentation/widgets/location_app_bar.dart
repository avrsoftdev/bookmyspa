// lib/common/widgets/location_appbar_title.dart
import 'package:flutter/material.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

class LocationAppBarTitle extends StatelessWidget {
  final LocationBloc locationBloc;
  final String? overriddenAddress;

  const LocationAppBarTitle({
    super.key,
    required this.locationBloc,
    this.overriddenAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('BookMySpa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListenableBuilder(
          listenable: locationBloc,
          builder: (context, _) {
            final address = overriddenAddress ??
                locationBloc.state.location?.address ??
                'Select Location';
            return Text(
              address,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
      ],
    );
  }
}