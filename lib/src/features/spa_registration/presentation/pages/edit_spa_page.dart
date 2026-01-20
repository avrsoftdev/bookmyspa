import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/tokens.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/di/di.dart';

class EditSpaPage extends StatefulWidget {
  final String spaId;
  const EditSpaPage({super.key, required this.spaId});

  @override
  State<EditSpaPage> createState() => _EditSpaPageState();
}

class _EditSpaPageState extends State<EditSpaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _whatsappController;
  late TextEditingController _phoneController;
  late TextEditingController _ownerController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _emailController;
  String? _businessType;
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  late TextEditingController _weeklyOffController;
  late TextEditingController _numStaffController;
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

  String? _ownerUid;
  Map<String, dynamic> _originalData = const {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _addressController = TextEditingController();
    _descriptionController = TextEditingController();
    _whatsappController = TextEditingController();
    _phoneController = TextEditingController();
    _ownerController = TextEditingController();
    _secondaryPhoneController = TextEditingController();
    _emailController = TextEditingController();
    _weeklyOffController = TextEditingController();
    _numStaffController = TextEditingController();
    _loadSpa();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    _phoneController.dispose();
    _ownerController.dispose();
    _secondaryPhoneController.dispose();
    _emailController.dispose();
    _weeklyOffController.dispose();
    _numStaffController.dispose();
    for (final svcMap in _subcategoryPlansControllers.values) {
      for (final rows in svcMap.values) {
        for (final r in rows) {
          r['duration']!.dispose();
          r['price']!.dispose();
        }
      }
    }
    super.dispose();
  }

  Future<void> _loadSpa() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance
          .collection('spas')
          .doc(widget.spaId)
          .get();
      if (!doc.exists) {
        setState(() {
          _error = 'Spa not found';
          _loading = false;
        });
        return;
      }
      final data = doc.data()!;
      _originalData = data;
      _ownerUid = data['ownerUid']?.toString();
      _nameController.text = data['businessName']?.toString() ?? '';
      _cityController.text = data['city']?.toString() ?? '';
      _addressController.text = data['fullAddress']?.toString() ?? '';
      _descriptionController.text = data['description']?.toString() ?? '';
      _whatsappController.text = data['whatsappNumber']?.toString() ?? '';
      _phoneController.text = data['primaryMobile']?.toString() ?? '';
      _secondaryPhoneController.text =
          data['secondaryMobile']?.toString() ?? '';
      _emailController.text = data['businessEmail']?.toString() ?? '';
      _ownerController.text = data['ownerName']?.toString() ?? '';
      _businessType = data['businessType']?.toString();
      _weeklyOffController.text = data['weeklyOff']?.toString() ?? '';
      _numStaffController.text = data['numStaff']?.toString() ?? '';
      final opening = data['openingTime']?.toString();
      final closing = data['closingTime']?.toString();
      _openingTime = opening != null && opening.contains(':')
          ? _parseTime(opening)
          : null;
      _closingTime = closing != null && closing.contains(':')
          ? _parseTime(closing)
          : null;
      final facilities =
          (data['facilities'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[];
      _selectedFacilities
        ..clear()
        ..addAll(facilities);
      final services =
          (data['services'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[];
      _selectedServices
        ..clear()
        ..addAll(services);
      final details =
          (data['serviceDetails'] as Map?)?.cast<String, dynamic>() ?? {};
      for (final entry in details.entries) {
        final svc = entry.key;
        final m = (entry.value as Map?)?.cast<String, dynamic>() ?? {};
        final subs = List<String>.from(
          (m['subcategories'] as List?) ?? const [],
        );
        final addons = List<String>.from((m['addons'] as List?) ?? const []);
        _selectedSubcategoriesByService[svc] = subs.toSet();
        _selectedAddonsByService[svc] = addons.toSet();
        final plans = (m['plans'] as Map?)?.cast<String, dynamic>() ?? const {};
        final mapRows = <String, List<Map<String, TextEditingController>>>{};
        for (final p in plans.entries) {
          final list = (p.value as List?) ?? const [];
          final rows = <Map<String, TextEditingController>>[];
          for (final item in list) {
            final mm = (item as Map?)?.cast<String, dynamic>() ?? {};
            final d = TextEditingController(
              text: mm['durationMinutes']?.toString() ?? '',
            );
            final pr = TextEditingController(
              text: mm['price']?.toString() ?? '',
            );
            rows.add({'duration': d, 'price': pr});
          }
          if (rows.isEmpty) {
            final d = TextEditingController();
            final pr = TextEditingController();
            rows.add({'duration': d, 'price': pr});
          }
          mapRows[p.key] = rows;
        }
        _subcategoryPlansControllers[svc] = mapRows;
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  TimeOfDay? _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h, minute: m);
  }

  bool get _isOwner {
    final auth = sl.get<AuthController>();
    final uid = auth.currentUser?.id ?? FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == _ownerUid;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are not authorized to edit this spa'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final services = _selectedServices.toList();
      final details = Map.fromEntries(
        _selectedServices.map((s) {
          final subs = (_selectedSubcategoriesByService[s] ?? const <String>{})
              .toList();
          final addons = (_selectedAddonsByService[s] ?? const <String>{})
              .toList();
          final plansForService = <String, List<Map<String, dynamic>>>{};
          final svcMap = _subcategoryPlansControllers[s] ?? const {};
          for (final sub in subs) {
            final rows = svcMap[sub] ?? const [];
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
      );
      final updates = <String, dynamic>{
        'businessName': _nameController.text.trim(),
        'ownerName': _ownerController.text.trim(),
        'businessType': _businessType,
        'city': _cityController.text.trim(),
        'fullAddress': _addressController.text.trim(),
        'description': _descriptionController.text.trim(),
        'whatsappNumber': _whatsappController.text.trim(),
        'primaryMobile': _phoneController.text.trim(),
        'secondaryMobile': _secondaryPhoneController.text.trim(),
        'businessEmail': _emailController.text.trim(),
        'openingTime': _openingTime?.format(context),
        'closingTime': _closingTime?.format(context),
        'weeklyOff': _weeklyOffController.text.trim(),
        'numStaff': _numStaffController.text.trim(),
        'facilities': _selectedFacilities.toList(),
        'services': services,
        'serviceDetails': details,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      updates.removeWhere((k, v) => v == null);
      await FirebaseFirestore.instance
          .collection('spas')
          .doc(widget.spaId)
          .set(updates, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Spa details updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Edit Spa'),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _sectionTitle('Basic Info'),
                    _textField(
                      _nameController,
                      'Business Name',
                      Icons.store,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      _descriptionController,
                      'Description',
                      Icons.info_outline,
                      maxLines: 3,
                    ),
                    SizedBox(height: 20.h),
                    _sectionTitle('Owner & Business'),
                    _dropdownField(
                      'Business Type',
                      _businessType,
                      ['Spa', 'Salon', 'Both'],
                      (v) => setState(() => _businessType = v),
                    ),
                    SizedBox(height: 12.h),
                    _textField(_ownerController, 'Owner Name', Icons.person),
                    SizedBox(height: 12.h),

                    SizedBox(height: 20.h),
                    _sectionTitle('Location'),
                    _textField(_cityController, 'City', Icons.location_city),
                    SizedBox(height: 12.h),
                    _textField(
                      _addressController,
                      'Full Address',
                      Icons.place,
                      maxLines: 3,
                    ),
                    SizedBox(height: 20.h),
                    _sectionTitle('Contact'),
                    _textField(
                      _phoneController,
                      'Primary Mobile',
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      _whatsappController,
                      'WhatsApp Number',
                      Icons.chat,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      _secondaryPhoneController,
                      'Secondary Mobile',
                      Icons.phone_in_talk,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                    SizedBox(height: 12.h),
                    _textField(
                      _emailController,
                      'Business Email',
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20.h),
                    _sectionTitle('Timings & Staff'),
                    Row(
                      children: [
                        Expanded(
                          child: _timePickerTile(
                            'Opening Time',
                            _openingTime,
                            (t) => setState(() => _openingTime = t),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _timePickerTile(
                            'Closing Time',
                            _closingTime,
                            (t) => setState(() => _closingTime = t),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            _weeklyOffController,
                            'Weekly Off',
                            Icons.event_busy,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _textField(
                            _numStaffController,
                            'Number of Staff',
                            Icons.group,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _sectionTitle('Facilities'),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: _facilityOptions
                          .map(
                            (f) => FilterChip(
                              label: Text(f),
                              selected: _selectedFacilities.contains(f),
                              onSelected: (v) => setState(() {
                                if (v) {
                                  _selectedFacilities.add(f);
                                } else {
                                  _selectedFacilities.remove(f);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 20.h),
                    _sectionTitle('Services Offered'),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: _serviceOptions
                          .map(
                            (s) => FilterChip(
                              label: Text(s),
                              selected: _selectedServices.contains(s),
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
                                          List<
                                            Map<String, TextEditingController>
                                          >
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
                      final addons =
                          _serviceAddons[service] ?? const <String>[];
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
                              'Subcategories',
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
                              'Add-ons',
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
                                    const <
                                      Map<String, TextEditingController>
                                    >[];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$sub — Duration & Price',
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
                                              child: _textField(
                                                row['duration']!,
                                                'Duration (minutes)',
                                                Icons.timer,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: _textField(
                                                row['price']!,
                                                'Price (₹)',
                                                Icons.currency_rupee,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => _removePlanRow(
                                                service,
                                                sub,
                                                i,
                                              ),
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
                                        label: const Text('Add Duration–Price'),
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
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _saving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _timePickerTile(
    String label,
    TimeOfDay? value,
    ValueChanged<TimeOfDay> onPicked,
  ) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(
        value != null ? value.format(context) : 'Not set',
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.access_time, color: AppColors.primary),
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: value ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (t != null) onPicked(t);
      },
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        counterText: '',
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _dropdownField(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value != null && options.contains(value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1F1F1F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      dropdownColor: const Color(0xFF1F1F1F),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _addPlanRow(String service, String sub) {
    final svcMap = _subcategoryPlansControllers.putIfAbsent(
      service,
      () => <String, List<Map<String, TextEditingController>>>{},
    );
    final rows = svcMap.putIfAbsent(
      sub,
      () => <Map<String, TextEditingController>>[],
    );
    rows.add({
      'duration': TextEditingController(),
      'price': TextEditingController(),
    });
    setState(() {});
  }

  void _removePlanRow(String service, String sub, int index) {
    final rows = _subcategoryPlansControllers[service]?[sub];
    if (rows == null || index < 0 || index >= rows.length) return;
    rows[index]['duration']!.dispose();
    rows[index]['price']!.dispose();
    rows.removeAt(index);
    setState(() {});
  }
}
