import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../location/presentation/bloc/location_bloc.dart';

enum RegisterSpaStatus { initial, loading, success, error }

class RegisterSpaController extends ChangeNotifier {
  final LocationBloc _locationBloc;
  bool _isDisposed = false;

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
    'Massage',
    'Hair Styling',
    'Pedicure',
    'Manicure',
    'Waxing',
    'Makeup',
    'Grooming',
    'Facial',
    'Spa Therapy',
  ];

  final List<Map<String, TextEditingController>> pricingRows = [];
  String? pricingPdfName;
  String? pricingPdfUrl;

  final List<ImageProvider?> photos = [];
  final List<String> uploadedImageUrls = [];

  // Upload state
  bool isUploading = false;
  double uploadProgress = 0.0; // 0.0 - 1.0
  String? uploadError;
  String? currentUploadKind; // 'photo' | 'aadhar' | 'pan' | 'license'

  final Set<String> selectedFacilities = {};
  final List<String> facilityOptions = const [
    'AC',
    'Wi-Fi',
    'Parking',
    'Steam/Sauna',
    'Home Service',
    'UPI/Card Payment',
    'Separate Rooms',
    'Certified Staff',
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

  RegisterSpaController({required LocationBloc locationBloc})
    : _locationBloc = locationBloc {
    _init();
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
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
      _safeNotify();
    } else if (state.status == LocationStatus.error) {
      errorMessage = state.errorMessage;
      _safeNotify();
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
    _safeNotify();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        uploadError = 'Please sign in to upload';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
      final XFile? xfile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (xfile == null) {
        // user cancelled
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }

      final String id = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child(
        'spa_photos/$uid/$id.jpg',
      );

      UploadTask task;
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        task = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        final file = File(xfile.path);
        task = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      }

      task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            _safeNotify();
          }
        },
        onError: (e) {
          uploadError = e.toString();
          isUploading = false;
          currentUploadKind = null;
          _safeNotify();
        },
      );

      final snapshot = await task;
      if (snapshot.state != TaskState.success) {
        uploadError = 'Upload failed';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
      String url;
      try {
        url = await ref.getDownloadURL();
      } catch (e) {
        uploadError = 'Uploaded but URL not available';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
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
      _safeNotify();
    } catch (e) {
      uploadError = e.toString();
      isUploading = false;
      currentUploadKind = null;
      _safeNotify();
    }
  }

  Future<void> pickAndUploadDocument(String kind) async {
    uploadError = null;
    currentUploadKind = kind;
    isUploading = true;
    uploadProgress = 0.0;
    _safeNotify();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        uploadError = 'Please sign in to upload';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
      final typeGroup = XTypeGroup(
        label: 'documents',
        extensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
      final name = file.name;
      final ext = name.toLowerCase().endsWith('.pdf')
          ? '.pdf'
          : (name.contains('.')
                ? name.substring(name.lastIndexOf('.')).toLowerCase()
                : '');
      final isPdf = ext == '.pdf';
      final String id = const Uuid().v4();
      final path = 'spa_documents/$uid/${kind}_$id$ext';
      final ref = FirebaseStorage.instance.ref().child(path);
      final contentType = isPdf
          ? 'application/pdf'
          : (ext == '.png'
                ? 'image/png'
                : (ext == '.webp' ? 'image/webp' : 'image/jpeg'));

      UploadTask task;
      if (kIsWeb || (file.path.isEmpty)) {
        final bytes = await file.readAsBytes();
        task = ref.putData(bytes, SettableMetadata(contentType: contentType));
      } else {
        final f = File(file.path);
        task = ref.putFile(f, SettableMetadata(contentType: contentType));
      }

      task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            _safeNotify();
          }
        },
        onError: (e) {
          uploadError = e.toString();
          isUploading = false;
          currentUploadKind = null;
          _safeNotify();
        },
      );

      final snapshot = await task;
      if (snapshot.state != TaskState.success) {
        uploadError = 'Upload failed';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }
      String url;
      try {
        url = await ref.getDownloadURL();
      } catch (e) {
        uploadError = 'Uploaded but URL not available';
        isUploading = false;
        currentUploadKind = null;
        _safeNotify();
        return;
      }

      if (kind == 'aadhar') {
        aadharFile = name;
        aadharUrl = url;
      } else if (kind == 'pan') {
        panFile = name;
        panUrl = url;
      } else if (kind == 'license') {
        licenseFile = name;
        licenseUrl = url;
      }

      uploadProgress = 1.0;
      isUploading = false;
      currentUploadKind = null;
      _safeNotify();
    } catch (e) {
      uploadError = e.toString();
      isUploading = false;
      currentUploadKind = null;
      _safeNotify();
    }
  }

  Future<void> pickAndUploadPricingPdf() async {
    uploadError = null;
    currentUploadKind = 'pricing';
    isUploading = true;
    uploadProgress = 0.0;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        uploadError = 'Please sign in to upload';
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }
      final typeGroup = XTypeGroup(label: 'pdf', extensions: ['pdf']);
      final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file == null) {
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }
      final String id = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref().child(
        'spa_pricing/$uid/$id.pdf',
      );

      UploadTask task;
      if (kIsWeb || (file.path.isEmpty)) {
        final bytes = await file.readAsBytes();
        task = ref.putData(
          bytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else {
        final f = File(file.path);
        task = ref.putFile(f, SettableMetadata(contentType: 'application/pdf'));
      }

      task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            notifyListeners();
          }
        },
        onError: (e) {
          uploadError = e.toString();
          isUploading = false;
          currentUploadKind = null;
          notifyListeners();
        },
      );

      final snapshot = await task;
      if (snapshot.state != TaskState.success) {
        uploadError = 'Upload failed';
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }
      String url;
      try {
        url = await ref.getDownloadURL();
      } catch (e) {
        uploadError = 'Uploaded but URL not available';
        isUploading = false;
        currentUploadKind = null;
        notifyListeners();
        return;
      }
      pricingPdfName = file.name;
      pricingPdfUrl = url;

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
    _safeNotify();
  }

  /// Check if location is being fetched
  bool get isLoadingLocation =>
      _locationBloc.state.status == LocationStatus.loading;

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
    _safeNotify();
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
    _safeNotify();
  }

  /// Toggle service selection
  void toggleService(String service) {
    if (selectedServices.contains(service)) {
      selectedServices.remove(service);
    } else {
      selectedServices.add(service);
    }
    _safeNotify();
  }

  /// Toggle facility selection
  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
    _safeNotify();
  }

  /// Toggle terms acceptance
  void toggleTermsAcceptance(bool value) {
    acceptedTerms = value;
    _safeNotify();
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
    _isDisposed = true;
    _locationBloc.removeListener(_onLocationChanged);
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

    super.dispose();
  }

  /// Submit spa data to Firestore. This method appends the uploaded
  /// asset URLs that exist in the controller (photos, aadharUrl, panUrl, licenseUrl)
  /// and writes a document under `spas` with a server timestamp and pending status.
  Future<DocumentReference> submitSpa(Map<String, dynamic> spaData) async {
    status = RegisterSpaStatus.loading;
    _safeNotify();

    try {
      final data = Map<String, dynamic>.from(spaData);

      // Include uploaded assets if present
      if (uploadedImageUrls.isNotEmpty) data['photos'] = uploadedImageUrls;
      if (aadharUrl != null) data['aadharUrl'] = aadharUrl;
      if (panUrl != null) data['panUrl'] = panUrl;
      if (licenseUrl != null) data['licenseUrl'] = licenseUrl;
      if (pricingPdfUrl != null) data['pricingPdfUrl'] = pricingPdfUrl;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) data['ownerUid'] = uid;

      data['createdAt'] = FieldValue.serverTimestamp();
      data['status'] = 'pending_review';

      final docRef = await FirebaseFirestore.instance
          .collection('spas')
          .add(data);

      status = RegisterSpaStatus.success;
      _safeNotify();
      return docRef;
    } catch (e) {
      errorMessage = e.toString();
      status = RegisterSpaStatus.error;
      _safeNotify();
      rethrow;
    }
  }
}
