// lib/common/widgets/location_appbar_title.dart
import 'package:flutter/material.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

class LocationAppBarTitle extends StatelessWidget {
  final LocationBloc locationBloc;
  final String? overriddenAddress;
  final VoidCallback? onEditLocationTap;

  const LocationAppBarTitle({
    super.key,
    required this.locationBloc,
    this.overriddenAddress,
    this.onEditLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spaxify',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListenableBuilder(
          listenable: locationBloc,
          builder: (context, _) {
            final address =
                overriddenAddress ??
                locationBloc.state.location?.address ??
                'Select Location';
            return Row(
              children: [
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: onEditLocationTap,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.edit_location_alt_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
