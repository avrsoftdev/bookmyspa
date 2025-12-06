import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
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
  final List<String> uploadedImageUrls = [];

  // Upload state
  bool isUploading = false;
  double uploadProgress = 0.0; // 0.0 - 1.0
  String? uploadError;
  String? currentUploadKind; // 'photo' | 'aadhar' | 'pan' | 'license'

  final Set<String> selectedFacilities = {};
  final List<String> facilityOptions = const [
    'AC', 'Wi-Fi', 'Parking', 'Steam/Sauna', 'Home Service', 'UPI/Card Payment', 'Separate Rooms', 'Certified Staff'
  ];

  String? aadharFile;
  String? panFile;
  String? licenseFile;
  String? aadharUrl;
  String? panUrl;
  String? licenseUrl;

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

  // Image picker & upload
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadPhoto() async {
    uploadError = null;
    currentUploadKind = 'photo';
    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (xfile == null) {
        // user cancelled
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }

      final String id = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('spa_photos/$id.jpg');

      UploadTask task;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        final file = File(xfile.path);
        task = ref.putFile(file);
      }

      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          notifyListeners();
        }
      }, onError: (e) {
        uploadError = e.toString();
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
      });

      await task;
      final url = await ref.getDownloadURL();
      uploadedImageUrls.add(url);
      if (kIsWeb) {
        photos.add(NetworkImage(url));
      } else {
        photos.add(FileImage(File(xfile.path)));
      }

      // completed
      uploadProgress = 1.0;
      isUploading = false;
      currentUploadKind = null;
      notifyListeners();
    } catch (e) {
      uploadError = e.toString();
      isUploading = false;
      currentUploadKind = null;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadDocument(String kind) async {
    uploadError = null;
    currentUploadKind = kind;
    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final XFile? xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (xfile == null) {
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }

      final String id = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child('spa_documents/${kind}_$id.jpg');

      UploadTask task;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        final file = File(xfile.path);
        task = ref.putFile(file);
      }

      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          notifyListeners();
        }
      }, onError: (e) {
        uploadError = e.toString();
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
      });

      await task;
      final url = await ref.getDownloadURL();

      if (kind == 'aadhar') {
        aadharFile = xfile.name;
        aadharUrl = url;
      } else if (kind == 'pan') {
        panFile = xfile.name;
        panUrl = url;
      } else if (kind == 'license') {
        licenseFile = xfile.name;
        licenseUrl = url;
      }

      uploadProgress = 1.0;
      isUploading = false;
      currentUploadKind = null;
      notifyListeners();
    } catch (e) {
      uploadError = e.toString();
      isUploading = false;
      currentUploadKind = null;
      notifyListeners();
    }
  }

  void clearUploadError() {
    uploadError = null;
    notifyListeners();
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

  /// Submit spa data to Firestore. This method appends the uploaded
  /// asset URLs that exist in the controller (photos, aadharUrl, panUrl, licenseUrl)
  /// and writes a document under `spas` with a server timestamp and pending status.
  Future<DocumentReference> submitSpa(Map<String, dynamic> spaData) async {
    status = RegisterSpaStatus.loading;
    notifyListeners();

    try {
      final data = Map<String, dynamic>.from(spaData);

      // Include uploaded assets if present
      if (uploadedImageUrls.isNotEmpty) data['photos'] = uploadedImageUrls;
      if (aadharUrl != null) data['aadharUrl'] = aadharUrl;
      if (panUrl != null) data['panUrl'] = panUrl;
      if (licenseUrl != null) data['licenseUrl'] = licenseUrl;

      data['createdAt'] = FieldValue.serverTimestamp();
      data['status'] = 'pending_review';

      final docRef = await FirebaseFirestore.instance.collection('spas').add(data);

      status = RegisterSpaStatus.success;
      notifyListeners();
      return docRef;
    } catch (e) {
      errorMessage = e.toString();
      status = RegisterSpaStatus.error;
      notifyListeners();
      rethrow;
    }
  }
}
