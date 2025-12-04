import 'package:flutter/material.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

enum RegisterSpaStatus { initial, loading, success, error }

class RegisterSpaController extends ChangeNotifier {
  final LocationBloc _locationBloc;

  // Form controllers
  final TextEditingController spaName = TextEditingController();
  final TextEditingController ownerName = TextEditingController();
  final TextEditingController yearOfEst = TextEditingController();
  final TextEditingController gstNumber = TextEditingController();

  final TextEditingController primaryMobile = TextEditingController();
  final TextEditingController secondaryMobile = TextEditingController();
  final TextEditingController businessEmail = TextEditingController();
  final TextEditingController whatsappNumber = TextEditingController();

  final TextEditingController fullAddress = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController pincode = TextEditingController();
  final TextEditingController landmark = TextEditingController();

  final TextEditingController weeklyOff = TextEditingController();
  final TextEditingController numStaff = TextEditingController();

  // State variables
  String? businessType;
  double? latitude;
  double? longitude;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  final Set<String> selectedServices = {};
  final List<String> serviceOptions = const [
    'Massage', 'Hair Styling', 'Pedicure', 'Manicure', 'Waxing', 'Makeup', 'Grooming', 'Facial', 'Spa Therapy'
  ];

  final List<Map<String, TextEditingController>> pricingRows = [];
  String? pricingPdfName;

  final List<ImageProvider?> photos = [];
  final Set<String> selectedFacilities = {};
  final List<String> facilityOptions = const [
    'AC', 'Wi-Fi', 'Parking', 'Steam/Sauna', 'Home Service', 'UPI/Card Payment', 'Separate Rooms', 'Certified Staff'
  ];

  String? aadharFile;
  String? panFile;
  String? licenseFile;

  bool acceptedTerms = false;

  // Status tracking
  RegisterSpaStatus status = RegisterSpaStatus.initial;
  String? errorMessage;

  RegisterSpaController({required LocationBloc locationBloc}) : _locationBloc = locationBloc {
    _init();
  }

  void _init() {
    _locationBloc.addListener(_onLocationChanged);
    _addPricingRow();
  }

  /// Listen to location bloc changes
  void _onLocationChanged() {
    final state = _locationBloc.state;
    if (state.status == LocationStatus.success && state.location != null) {
      final location = state.location!;
      latitude = location.latitude;
      longitude = location.longitude;
      fullAddress.text = location.address;
      city.text = location.city;
      notifyListeners();
    } else if (state.status == LocationStatus.error) {
      errorMessage = state.errorMessage;
      notifyListeners();
    }
  }

  /// Get current location from device
  Future<void> pickCurrentLocation() async {
    await _locationBloc.getCurrentLocation();
  }

  /// Check if location is being fetched
  bool get isLoadingLocation => _locationBloc.state.status == LocationStatus.loading;

  /// Get location status display text
  String get locationStatusText {
    if (isLoadingLocation) {
      return "Getting Location...";
    } else if (latitude != null && longitude != null) {
      return "Location Picked (${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)})";
    } else {
      return "Pick Current Location";
    }
  }

  /// Add a new pricing row
  void addPricingRow() {
    _addPricingRow();
    notifyListeners();
  }

  void _addPricingRow() {
    pricingRows.add({
      'service': TextEditingController(),
      'price': TextEditingController(),
    });
  }

  /// Remove a pricing row
  void removePricingRow(int index) {
    pricingRows[index]['service']!.dispose();
    pricingRows[index]['price']!.dispose();
    pricingRows.removeAt(index);
    notifyListeners();
  }

  /// Toggle service selection
  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
    notifyListeners();
  }

  /// Toggle facility selection
  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
    notifyListeners();
  }

  /// Toggle terms acceptance
  void toggleTermsAcceptance(bool value) {
    acceptedTerms = value;
    notifyListeners();
  }

  /// Validate form
  bool isFormValid() {
    return spaName.text.isNotEmpty &&
        ownerName.text.isNotEmpty &&
        businessType != null &&
        yearOfEst.text.isNotEmpty &&
        primaryMobile.text.isNotEmpty &&
        businessEmail.text.isNotEmpty &&
        fullAddress.text.isNotEmpty &&
        city.text.isNotEmpty &&
        pincode.text.isNotEmpty &&
        openingTime != null &&
        closingTime != null &&
        numStaff.text.isNotEmpty &&
        acceptedTerms;
  }

  /// Clean up resources
  @override
  void dispose() {
    spaName.dispose();
    ownerName.dispose();
    yearOfEst.dispose();
    gstNumber.dispose();
    primaryMobile.dispose();
    secondaryMobile.dispose();
    businessEmail.dispose();
    whatsappNumber.dispose();
    fullAddress.dispose();
    city.dispose();
    pincode.dispose();
    landmark.dispose();
    weeklyOff.dispose();
    numStaff.dispose();

    for (var row in pricingRows) {
      row['service']!.dispose();
      row['price']!.dispose();
    }

    _locationBloc.removeListener(_onLocationChanged);
    super.dispose();
  }
}
