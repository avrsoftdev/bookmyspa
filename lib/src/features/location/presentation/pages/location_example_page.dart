import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/location_bloc.dart';
import '../widgets/location_widget.dart';
import '../../../../core/di/di.dart';
import '../../../../core/theme/tokens.dart';

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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Location Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Service Example',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            
            // Location Widget
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 8.h),
                  LocationWidget(locationBloc: _locationBloc),
                ],
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Manual location fetch button
            ElevatedButton(
              onPressed: () => _locationBloc.getCurrentLocation(),
              child: Text('Get Current Location', style: TextStyle(fontSize: 14.sp)),
            ),
            
            SizedBox(height: 10.h),
            
            // Reset button
            ElevatedButton(
              onPressed: () => _locationBloc.resetState(),
              child: Text('Reset Location', style: TextStyle(fontSize: 14.sp)),
            ),
            
            SizedBox(height: 20.h),
            
            // Location details
            ListenableBuilder(
              listenable: _locationBloc,
              builder: (context, child) {
                final state = _locationBloc.state;
                if (state.status == LocationStatus.success && state.location != null) {
                  final location = state.location!;
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Details:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                          SizedBox(height: 8.h),
                          Text('Latitude: ${location.latitude}', style: TextStyle(fontSize: 14.sp)),
                          Text('Longitude: ${location.longitude}', style: TextStyle(fontSize: 14.sp)),
                          Text('Address: ${location.address}', style: TextStyle(fontSize: 14.sp)),
                          Text('City: ${location.city}', style: TextStyle(fontSize: 14.sp)),
                          Text('Country: ${location.country}', style: TextStyle(fontSize: 14.sp)),
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