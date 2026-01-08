// register_your_spa_page.dart - FULLY RESTORED + DARK THEME PERFECT MATCH
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/di/di.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../controllers/register_spa_controller.dart';

class RegisterYourSpaPage extends StatefulWidget {
  const RegisterYourSpaPage({super.key});

  @override
  State<RegisterYourSpaPage> createState() => _RegisterYourSpaPageState();
}

class _RegisterYourSpaPageState extends State<RegisterYourSpaPage> {
  final _formKey = GlobalKey<FormState>();
  late LocationBloc _locationBloc;
  late RegisterSpaController _controller;

  // === All your original controllers & variables (FULLY RESTORED) ===
  final _spaName = TextEditingController();
  final _ownerName = TextEditingController();
  String? _businessType;
  final _yearOfEst = TextEditingController();
  final _gstNumber = TextEditingController();
  final _description = TextEditingController();

  final _primaryMobile = TextEditingController();
  final _secondaryMobile = TextEditingController();
  final _businessEmail = TextEditingController();
  final _whatsappNumber = TextEditingController();

  final _fullAddress = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _landmark = TextEditingController();
  double? _latitude;
  double? _longitude;

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  final _weeklyOff = TextEditingController();
  final _numStaff = TextEditingController();

  final Set<String> _selectedServices = {};
  final List<String> _serviceOptions = const [
    'Massage',
    'Pedicure',
    'Manicure',
    'Skin Care',
    'Makeup',
    'Therapy',
    'Waxing',
    'Body Care',
    'Bridal',
    'Grooming',
    'Hair Care',
  ];

  // Dynamic service metadata
  final Map<String, List<String>> _serviceSubcategories = const {
    'Massage': [
      'Swedish Massage',
      'Deep Tissue Massage',
      'Aromatherapy Massage',
      'Hot Stone Massage',
      'Thai Massage',
      'Reflexology',
      'Sports Massage',
      'Head–Neck–Shoulder Massage',
      'Full Body Massage',
      'Couple Massage',
    ],
    'Pedicure': [
      'Classic Pedicure',
      'Spa Pedicure',
      'Gel Pedicure',
      'French Pedicure',
      'Paraffin Pedicure',
      'Anti-Tan Pedicure',
      'Foot Spa',
      'Medical Pedicure',
    ],
    'Manicure': [
      'Classic Manicure',
      'Gel Manicure',
      'French Manicure',
      'Spa Manicure',
      'Nail Extensions',
      'Acrylic Nails',
      'Cuticle Care',
    ],
    'Skin Care': [
      'Clean-Up',
      'Facial',
      'Anti-Aging Treatment',
      'Acne Treatment',
      'Skin Brightening',
      'Hydrafacial',
      'Chemical Peel',
      'De-Tan Treatment',
    ],
    'Makeup': [
      'Party Makeup',
      'Bridal Makeup',
      'Engagement Makeup',
      'HD Makeup',
      'Airbrush Makeup',
      'Reception Makeup',
      'Natural Makeup',
    ],
    'Therapy': [
      'Body Therapy',
      'Aroma Therapy',
      'Relaxation Therapy',
      'Stress Relief Therapy',
      'Pain Relief Therapy',
      'Ayurvedic Therapy',
      'Hot Oil Therapy',
    ],
    'Waxing': [
      'Full Body Wax',
      'Half Body Wax',
      'Bikini Wax',
      'Brazilian Wax',
      'Underarm Wax',
      'Facial Wax',
      'Chocolate Wax',
      'Rica Wax',
    ],
    'Body Care': [
      'Body Polishing',
      'Body Scrub',
      'Body Wrap',
      'Body Detox',
      'Body Bleach',
      'Tan Removal',
      'Moisturizing Treatment',
    ],
    'Bridal': [
      'Bridal Makeup',
      'Bridal Hairstyle',
      'Bridal Skin Care',
      'Bridal Body Polishing',
      'Bridal Mehendi',
      'Pre-Bridal Packages',
      'Bridal Trial Sessions',
    ],
    'Grooming': [
      'Haircut',
      'Beard Styling',
      'Shaving',
      'Hair Spa',
      'Trimming',
      'Styling & Blow Dry',
      'Grooming Packages',
    ],
    'Hair Care': [
      'Hair Spa',
      'Hair Cut',
      'Hair Coloring',
      'Hair Smoothening',
      'Hair Straightening',
      'Keratin Treatment',
      'Hair Fall Treatment',
      'Dandruff Treatment',
    ],
  };

  final Map<String, List<String>> _serviceAddons = const {
    'Massage': [
      'Extra Duration',
      'Essential Oils',
      'Hot Towel Therapy',
      'Foot Reflexology',
    ],
    'Pedicure': ['Callus Removal', 'Foot Massage', 'Nail Art', 'Gel Polish'],
    'Manicure': [
      'Nail Art',
      'Hand Massage',
      'Gel Polish',
      'Nail Strengthening',
    ],
    'Skin Care': [
      'Face Masks',
      'Serum Boost',
      'Under-Eye Treatment',
      'LED Therapy',
    ],
    'Makeup': [
      'False Lashes',
      'Touch-up Kits',
      'Hairstyling',
      'Saree Draping',
      'Makeup Trials',
    ],
    'Therapy': [
      'Steam Therapy',
      'Herbal Compress',
      'Oil Upgrades',
      'Extended Sessions',
    ],
    'Waxing': [
      'Post-wax Soothing Gel',
      'Sensitive-skin Wax',
      'Premium Wax Upgrades',
    ],
    'Body Care': ['Aroma Oils', 'Whitening Packs', 'Extended Massage Time'],
    'Bridal': ['Jewelry Setting', 'Touch-up Assistance', 'Hair Extensions'],
    'Grooming': ['Beard Coloring', 'Hair Wash', 'Scalp Massage'],
    'Hair Care': ['Hair Masks', 'Scalp Treatments', 'Olaplex Treatments'],
  };

  final Map<String, Set<String>> _selectedSubcategoriesByService = {};
  final Map<String, Set<String>> _selectedAddonsByService = {};

  final Map<String, Map<String, List<Map<String, TextEditingController>>>>
  _subcategoryPlansControllers = {};

  final List<Map<String, TextEditingController>> _pricingRows = [];
  String? _pricingPdfName;

  final Set<String> _selectedFacilities = {};
  final List<String> _facilityOptions = const [
    'AC',
    'Wi-Fi',
    'Parking',
    'Steam/Sauna',
    'Home Service',
    'UPI/Card Payment',
    'Separate Rooms',
    'Certified Staff',
  ];

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _locationBloc = sl.get<LocationBloc>();
    _locationBloc.addListener(_onLocationChanged);
    _controller = RegisterSpaController(locationBloc: _locationBloc);
    _controller.addListener(() => setState(() {}));
    _addPricingRow();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var c in [
      _spaName,
      _ownerName,
      _yearOfEst,
      _gstNumber,
      _primaryMobile,
      _secondaryMobile,
      _businessEmail,
      _whatsappNumber,
      _fullAddress,
      _city,
      _pincode,
      _landmark,
      _weeklyOff,
      _numStaff,
      _description,
    ])
      c.dispose();
    for (var row in _pricingRows) {
      row['service']!.dispose();
      row['price']!.dispose();
    }
    _locationBloc.removeListener(_onLocationChanged);
    _controller.dispose();
    super.dispose();
  }

  void _addPricingRow() => setState(
    () => _pricingRows.add({
      'service': TextEditingController(),
      'price': TextEditingController(),
    }),
  );
  void _removePricingRow(int i) => setState(() {
    _pricingRows[i]['service']!.dispose();
    _pricingRows[i]['price']!.dispose();
    _pricingRows.removeAt(i);
  });

  void _addPlanRow(String service, String subcategory) {
    final svcMap = _subcategoryPlansControllers.putIfAbsent(
      service,
      () => <String, List<Map<String, TextEditingController>>>{},
    );
    final list = svcMap.putIfAbsent(
      subcategory,
      () => <Map<String, TextEditingController>>[],
    );
    list.add({
      'duration': TextEditingController(),
      'price': TextEditingController(),
    });
    setState(() {});
  }

  void _removePlanRow(String service, String subcategory, int index) {
    final svcMap = _subcategoryPlansControllers[service];
    final list = svcMap?[subcategory];
    if (list != null && index >= 0 && index < list.length) {
      list[index]['duration']!.dispose();
      list[index]['price']!.dispose();
      list.removeAt(index);
      setState(() {});
    }
  }

  void _onLocationChanged() {
    final state = _locationBloc.state;
    if (state.status == LocationStatus.success && state.location != null) {
      final location = state.location!;
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _fullAddress.text = location.address;
        _city.text = location.city;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location picked: ${location.latitude}, ${location.longitude}',
          ),
        ),
      );
    } else if (state.status == LocationStatus.error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${state.errorMessage}')));
    }
  }

  Future<void> _pickCurrentLocation() async {
    await _locationBloc.getCurrentLocation();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept Terms & Conditions')),
      );
      return;
    }
    for (final service in _selectedServices) {
      final selectedSubs = _selectedSubcategoriesByService[service] ?? {};
      for (final sub in selectedSubs) {
        final rows = _subcategoryPlansControllers[service]?[sub] ?? [];
        if (rows.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add at least one duration–price for $sub')),
          );
          return;
        }
        for (final r in rows) {
          if (r['duration']!.text.trim().isEmpty ||
              r['price']!.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fill duration and price for $sub')),
            );
            return;
          }
        }
      }
    }

    // Collect form data into a map and delegate persistence to the controller.
    final Map<String, dynamic> data = {
      'businessName': _spaName.text.trim(),
      'ownerName': _ownerName.text.trim(),
      'businessType': _businessType,
      'yearOfEst': _yearOfEst.text.trim(),
      'gstNumber': _gstNumber.text.trim(),
      'description': _description.text.trim(),

      'primaryMobile': _primaryMobile.text.trim(),
      'secondaryMobile': _secondaryMobile.text.trim(),
      'businessEmail': _businessEmail.text.trim(),
      'whatsappNumber': _whatsappNumber.text.trim(),

      'fullAddress': _fullAddress.text.trim(),
      'city': _city.text.trim(),
      'pincode': _pincode.text.trim(),
      'landmark': _landmark.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,

      'openingTime': _openingTime?.format(context),
      'closingTime': _closingTime?.format(context),
      'weeklyOff': _weeklyOff.text.trim(),
      'numStaff': _numStaff.text.trim(),

      'services': _selectedServices.toList(),
      'pricing': const <Map<String, dynamic>>[],
      'facilities': _selectedFacilities.toList(),
      'pricingPdfName': _pricingPdfName,
      'acceptedTerms': _acceptedTerms,
      'serviceDetails': Map.fromEntries(
        _selectedServices.map((s) {
          final subs = (_selectedSubcategoriesByService[s] ?? const <String>{})
              .toList();
          final addons = (_selectedAddonsByService[s] ?? const <String>{})
              .toList();
          final plansForService = <String, List<Map<String, dynamic>>>{};
          for (final sub in subs) {
            final rows = _subcategoryPlansControllers[s]?[sub] ?? const [];
            plansForService[sub] = rows.map((r) {
              final d = int.tryParse(r['duration']!.text.trim()) ?? 0;
              final p = int.tryParse(r['price']!.text.trim()) ?? 0;
              return {'durationMinutes': d, 'price': p};
            }).toList();
          }
          return MapEntry(s, {
            'subcategories': subs,
            'addons': addons,
            'plans': plansForService,
          });
        }),
      ),
    };

    // Show a blocking progress dialog while submission is in progress.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    _controller
        .submitSpa(data)
        .then((docRef) {
          Navigator.of(context).pop(); // remove progress

          // Navigate to success screen and replace this page so user can't go back.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const _SubmissionSuccessPage()),
          );
        })
        .catchError((e) {
          Navigator.of(context).pop(); // remove progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit: ${e.toString()}')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show upload errors as SnackBar (clear after shown)
    if (_controller.uploadError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: ${_controller.uploadError}')),
        );
        _controller.clearUploadError();
      });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Register Your Spa'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // ALL SECTIONS - FULLY RESTORED & THEMED
              _buildSection(
                context,
                icon: Icons.store_rounded,
                title: "Spa/Salon Details",
                children: [
                  _inputField(
                    _spaName,
                    "Business Name *",
                    hint: "e.g., Serenity Spa & Salon",
                  ),
                  _inputField(_ownerName, "Owner Name *"),
                  _dropdownField(
                    "Business Type *",
                    _businessType,
                    ['Spa', 'Salon', 'Both'],
                    (v) => setState(() => _businessType = v),
                  ),
                  _yearField(_yearOfEst, "Year of Establishment *"),
                  _gstField(_gstNumber, "GST Number (Optional)"),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.phone_rounded,
                title: "Contact Information",
                children: [
                  _phoneField(
                    _primaryMobile,
                    "Primary Mobile *",
                    isRequired: true,
                  ),
                  _phoneField(
                    _secondaryMobile,
                    "Secondary Mobile",
                    isRequired: false,
                  ),
                  _inputField(
                    _businessEmail,
                    "Business Email *",
                    keyboard: TextInputType.emailAddress,
                  ),
                  _phoneField(
                    _whatsappNumber,
                    "WhatsApp Number",
                    isRequired: false,
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.location_on_rounded,
                title: "Address & Location",
                children: [
                  _inputField(_fullAddress, "Full Address *", maxLines: 3),
                  Row(
                    children: [
                      Expanded(child: _inputField(_city, "City *")),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _inputField(
                          _pincode,
                          "Pincode *",
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  _inputField(_landmark, "Landmark (Optional)"),
                  SizedBox(height: 16.h),
                  AnimatedBuilder(
                    animation: _locationBloc,
                    builder: (context, child) {
                      final isLoading =
                          _locationBloc.state.status == LocationStatus.loading;
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => _pickCurrentLocation(),
                          icon: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.my_location_rounded,
                                  color: AppColors.primary,
                                ),
                          label: Text(
                            isLoading
                                ? "Getting Location..."
                                : _latitude != null
                                ? "Location Picked (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})"
                                : "Pick Current Location",
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.access_time_rounded,
                title: "Operating Details",
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _timePicker(
                          "Opening Time *",
                          _openingTime,
                          (t) => setState(() => _openingTime = t),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _timePicker(
                          "Closing Time *",
                          _closingTime,
                          (t) => setState(() => _closingTime = t),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          _weeklyOff,
                          "Weekly Off (e.g., Monday)",
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _inputField(
                          _numStaff,
                          "Number of Staff *",
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.spa_rounded,
                title: "Services Offered",
                children: [
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: _serviceOptions
                        .map(
                          (s) => FilterChip(
                            label: Text(s),
                            selected: _selectedServices.contains(s),
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            checkmarkColor: AppColors.primary,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            onSelected: (v) => setState(() {
                              if (v) {
                                _selectedServices.add(s);
                                _selectedSubcategoriesByService.putIfAbsent(
                                  s,
                                  () => <String>{},
                                );
                                _selectedAddonsByService.putIfAbsent(
                                  s,
                                  () => <String>{},
                                );
                                _subcategoryPlansControllers.putIfAbsent(
                                  s,
                                  () =>
                                      <
                                        String,
                                        List<Map<String, TextEditingController>>
                                      >{},
                                );
                              } else {
                                _selectedServices.remove(s);
                                _selectedSubcategoriesByService.remove(s);
                                _selectedAddonsByService.remove(s);
                                final svcMap = _subcategoryPlansControllers
                                    .remove(s);
                                if (svcMap != null) {
                                  for (final rows in svcMap.values) {
                                    for (final r in rows) {
                                      r['duration']!.dispose();
                                      r['price']!.dispose();
                                    }
                                  }
                                }
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 12.h),
                  ..._selectedServices.map((service) {
                    final subs =
                        _serviceSubcategories[service] ?? const <String>[];
                    final addons = _serviceAddons[service] ?? const <String>[];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        if (subs.isNotEmpty) ...[
                          Text(
                            "Subcategories",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: subs
                                .map(
                                  (name) => FilterChip(
                                    label: Text(name),
                                    selected:
                                        _selectedSubcategoriesByService[service]
                                            ?.contains(name) ??
                                        false,
                                    selectedColor: AppColors.primary
                                        .withOpacity(0.2),
                                    checkmarkColor: AppColors.primary,
                                    backgroundColor: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    onSelected: (v) => setState(() {
                                      final set =
                                          _selectedSubcategoriesByService
                                              .putIfAbsent(
                                                service,
                                                () => <String>{},
                                              );
                                      if (v) {
                                        set.add(name);
                                        _addPlanRow(service, name);
                                      } else {
                                        set.remove(name);
                                        final svcMap =
                                            _subcategoryPlansControllers[service];
                                        final rows = svcMap?[name] ?? [];
                                        for (final r in rows) {
                                          r['duration']!.dispose();
                                          r['price']!.dispose();
                                        }
                                        svcMap?.remove(name);
                                      }
                                    }),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        SizedBox(height: 10.h),
                        if (addons.isNotEmpty) ...[
                          Text(
                            "Add-ons",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: addons
                                .map(
                                  (name) => FilterChip(
                                    label: Text(name),
                                    selected:
                                        _selectedAddonsByService[service]
                                            ?.contains(name) ??
                                        false,
                                    selectedColor: AppColors.primary
                                        .withOpacity(0.2),
                                    checkmarkColor: AppColors.primary,
                                    backgroundColor: isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[100],
                                    onSelected: (v) => setState(() {
                                      final set = _selectedAddonsByService
                                          .putIfAbsent(
                                            service,
                                            () => <String>{},
                                          );
                                      if (v) {
                                        set.add(name);
                                      } else {
                                        set.remove(name);
                                      }
                                    }),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        SizedBox(height: 10.h),
                        ...(_selectedSubcategoriesByService[service] ??
                                const <String>{})
                            .map((sub) {
                              final rows =
                                  _subcategoryPlansControllers[service]?[sub] ??
                                  const <Map<String, TextEditingController>>[];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$sub — Duration & Price",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  ...rows.asMap().entries.map((e) {
                                    final i = e.key;
                                    final row = e.value;
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 8.h),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _inputField(
                                              row['duration']!,
                                              "Duration (minutes) *",
                                              keyboard: TextInputType.number,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: _inputField(
                                              row['price']!,
                                              "Price (₹) *",
                                              keyboard: TextInputType.number,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _removePlanRow(service, sub, i),
                                            icon: Icon(
                                              Icons.delete_rounded,
                                              color: Colors.red[400],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          _addPlanRow(service, sub),
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text("Add Duration–Price"),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                              );
                            })
                            .toList(),
                        SizedBox(height: 12.h),
                      ],
                    );
                  }).toList(),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.description_rounded,
                title: "Spa Description",
                children: [
                  _inputField(
                    _description,
                    "Spa Description *",
                    hint:
                        "Describe your services, ambiance, certifications, and specialties",
                    maxLines: 4,
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.price_check_rounded,
                title: "Pricing",
                children: [
                  _fileUploadTile(
                    "Upload Pricing PDF (Optional)",
                    _controller.pricingPdfName,
                    () => _controller.pickAndUploadPricingPdf(),
                    isLoading:
                        _controller.isUploading &&
                        _controller.currentUploadKind == 'pricing',
                    progress: _controller.uploadProgress,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Pricing is captured per subcategory above",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.photo_library_rounded,
                title: "Photos Upload (Max 10)",
                children: [
                  if (_controller.uploadError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _controller.uploadError!,
                              style: TextStyle(color: Colors.red[400]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: _controller.clearUploadError,
                            child: const Text("Dismiss"),
                          ),
                        ],
                      ),
                    ),
                  // Show upload progress for photos when active
                  if (_controller.isUploading &&
                      _controller.currentUploadKind == 'photo') ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uploading photo...',
                            style: theme.textTheme.bodyMedium,
                          ),
                          SizedBox(height: 8.h),
                          LinearProgressIndicator(
                            value: _controller.uploadProgress,
                            color: AppColors.primary,
                            backgroundColor: Colors.grey[300],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${(_controller.uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],

                  _controller.photos.isEmpty
                      ? _uploadPlaceholder(
                          "Tap to add photos",
                          () => _controller.pickAndUploadPhoto(),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _controller.photos.length + 1,
                          itemBuilder: (context, i) =>
                              i < _controller.photos.length
                              ? Stack(
                                  children: [
                                    Image(image: _controller.photos[i]!),
                                    const Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                )
                              : _uploadPlaceholder(
                                  "+ Add",
                                  () => _controller.pickAndUploadPhoto(),
                                ),
                        ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.check_circle_rounded,
                title: "Facilities",
                children: [
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 10.h,
                    children: _facilityOptions
                        .map(
                          (f) => FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: Icon(
                                Icons.done,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            label: Text(f),
                            selected: _selectedFacilities.contains(f),
                            selectedColor: AppColors.primary.withOpacity(0.15),
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            onSelected: (v) => setState(
                              () => v
                                  ? _selectedFacilities.add(f)
                                  : _selectedFacilities.remove(f),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),

              _buildSection(
                context,
                icon: Icons.verified_rounded,
                title: "Business Verification",
                children: [
                  _fileUploadTile(
                    "Aadhar Card",
                    _controller.aadharFile,
                    () => _controller.pickAndUploadDocument('aadhar'),
                    isLoading:
                        _controller.isUploading &&
                        _controller.currentUploadKind == 'aadhar',
                    progress: _controller.uploadProgress,
                  ),
                  _fileUploadTile(
                    "PAN Card",
                    _controller.panFile,
                    () => _controller.pickAndUploadDocument('pan'),
                    isLoading:
                        _controller.isUploading &&
                        _controller.currentUploadKind == 'pan',
                    progress: _controller.uploadProgress,
                  ),
                  _fileUploadTile(
                    "Business License",
                    _controller.licenseFile,
                    () => _controller.pickAndUploadDocument('license'),
                    isLoading:
                        _controller.isUploading &&
                        _controller.currentUploadKind == 'license',
                    progress: _controller.uploadProgress,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    activeColor: AppColors.primary,
                    onChanged: (v) =>
                        setState(() => _acceptedTerms = v ?? false),
                  ),
                  Expanded(
                    child: Text(
                      "I accept the Terms & Conditions",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              SizedBox(
                width: double.infinity,
                height: 58.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 12,
                    shadowColor: AppColors.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Submit for Review",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 60.h),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widgets - same style as ProfileScreen
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              SizedBox(width: 16.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...children,
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? hint,
  }) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: TextFormField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (v) => label.contains('*') && (v == null || v.trim().isEmpty)
          ? 'Required'
          : null,
    ),
  );

  Widget _yearField(TextEditingController c, String label) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: TextFormField(
      controller: c,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Select year",
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: const Icon(Icons.calendar_today_rounded),
      ),
      onTap: () async {
        final now = DateTime.now();
        final selectedYear = int.tryParse(c.text) ?? now.year;
        final firstDate = DateTime(1950);
        final lastDate = DateTime(now.year);
        await showDialog<void>(
          context: context,
          builder: (ctx) {
            return Dialog(
              child: SizedBox(
                height: 300,
                child: YearPicker(
                  firstDate: firstDate,
                  lastDate: lastDate,
                  selectedDate: DateTime(selectedYear),
                  onChanged: (date) {
                    c.text = date.year.toString();
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            );
          },
        );
      },
      validator: (v) {
        if (label.contains('*') && (v == null || v.trim().isEmpty)) {
          return 'Required';
        }
        if (v != null && v.trim().isNotEmpty) {
          final year = int.tryParse(v.trim());
          final nowYear = DateTime.now().year;
          if (year == null || year < 1950 || year > nowYear) {
            return 'Enter a valid year';
          }
        }
        return null;
      },
    ),
  );

  Widget _gstField(TextEditingController c, String label) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: TextFormField(
      controller: c,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        LengthLimitingTextInputFormatter(15),
        UpperCaseTextFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: "15-character GSTIN",
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (v) {
        final value = (v ?? '').trim();
        if (value.isEmpty) {
          return null; // optional
        }
        if (value.length != 15) {
          return 'GSTIN must be 15 characters';
        }
        if (!_isValidGstin(value)) {
          return 'Invalid GSTIN format';
        }
        return null;
      },
    ),
  );

  Widget _phoneField(
    TextEditingController c,
    String label, {
    required bool isRequired,
  }) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: TextFormField(
      controller: c,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: label,
        hintText: "Enter 10-digit phone number",
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        counterText: "", // Hide the character counter
      ),
      validator: (v) {
        if (isRequired && (v == null || v.trim().isEmpty)) {
          return 'Required';
        }
        if (v != null && v.trim().isNotEmpty) {
          // Remove any non-digit characters for validation
          final digitsOnly = v.replaceAll(RegExp(r'[^0-9]'), '');
          if (digitsOnly.length != 10) {
            return 'Phone number must be exactly 10 digits';
          }
        }
        return null;
      },
    ),
  );

  Widget _dropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
      ),
      dropdownColor: Theme.of(context).cardColor,
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => label.contains('*') && v == null ? 'Required' : null,
    ),
  );

  Widget _timePicker(
    String label,
    TimeOfDay? time,
    ValueChanged<TimeOfDay> onChanged,
  ) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (t != null) onChanged(t);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
        ),
        child: Text(time?.format(context) ?? 'Select time'),
      ),
    ),
  );

  Widget _fileUploadTile(
    String label,
    String? fileName,
    VoidCallback onTap, {
    bool isLoading = false,
    double? progress,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(Icons.upload_file_rounded, color: AppColors.primary),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: fileName != null
        ? Text(fileName, style: TextStyle(color: AppColors.primary))
        : null,
    trailing: isLoading
        ? SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${((progress ?? 0) * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          )
        : ElevatedButton(onPressed: onTap, child: const Text("Upload")),
  );

  // Legacy pricing row removed; pricing is now captured per subcategory

  Widget _uploadPlaceholder(String text, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.primary),
            Text(text, style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

bool _isValidGstin(String gstin) {
  final pattern = RegExp(
    r'^(0[1-9]|1[0-9]|2[0-9]|3[0-7])[A-Z]{5}[0-9]{4}[A-Z][A-Z0-9]Z[A-Z0-9]$',
  );
  return pattern.hasMatch(gstin);
}

// Simple full-screen success page shown after submission
class _SubmissionSuccessPage extends StatelessWidget {
  const _SubmissionSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submitted'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 88,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Your spa will be listed shortly once it is reviewed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
