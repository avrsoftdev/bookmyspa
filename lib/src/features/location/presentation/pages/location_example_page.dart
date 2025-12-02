import 'package:flutter/material.dart';
import '../bloc/location_bloc.dart';
import '../widgets/location_widget.dart';
import '../../../../core/di/di.dart';

/// Example page showing how to use location functionality
class LocationExamplePage extends StatefulWidget {
  const LocationExamplePage({super.key});

  @override
  State<LocationExamplePage> createState() => _LocationExamplePageState();
}

class _LocationExamplePageState extends State<LocationExamplePage> {
  late LocationBloc _locationBloc;

  @override
  void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Service Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Location Widget
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  LocationWidget(locationBloc: _locationBloc),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Manual location fetch button
            ElevatedButton(
              onPressed: () => _locationBloc.getCurrentLocation(),
              child: const Text('Get Current Location'),
            ),
            
            const SizedBox(height: 10),
            
            // Reset button
            ElevatedButton(
              onPressed: () => _locationBloc.resetState(),
              child: const Text('Reset Location'),
            ),
            
            const SizedBox(height: 20),
            
            // Location details
            ListenableBuilder(
              listenable: _locationBloc,
              builder: (context, child) {
                final state = _locationBloc.state;
                if (state.status == LocationStatus.success && state.location != null) {
                  final location = state.location!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location Details:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Latitude: ${location.latitude}'),
                          Text('Longitude: ${location.longitude}'),
                          Text('Address: ${location.address}'),
                          Text('City: ${location.city}'),
                          Text('Country: ${location.country}'),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}