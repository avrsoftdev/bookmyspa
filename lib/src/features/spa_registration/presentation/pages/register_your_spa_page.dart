// register_your_spa_page.dart - FULLY RESTORED + DARK THEME PERFECT MATCH
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/tokens.dart';

class RegisterYourSpaPage extends StatefulWidget {
  const RegisterYourSpaPage({super.key});

  @override
  State<RegisterYourSpaPage> createState() => _RegisterYourSpaPageState();
}

class _RegisterYourSpaPageState extends State<RegisterYourSpaPage> {
  final _formKey = GlobalKey<FormState>();

  // === All your original controllers & variables (FULLY RESTORED) ===
  final _spaName = TextEditingController();
  final _ownerName = TextEditingController();
  String? _businessType;
  final _yearOfEst = TextEditingController();
  final _gstNumber = TextEditingController();

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
    'Massage', 'Hair Styling', 'Pedicure', 'Manicure', 'Waxing', 'Makeup', 'Grooming', 'Facial', 'Spa Therapy'
  ];

  final List<Map<String, TextEditingController>> _pricingRows = [];
  String? _pricingPdfName;

  final List<ImageProvider?> _photos = [];
  final Set<String> _selectedFacilities = {};
  final List<String> _facilityOptions = const [
    'AC', 'Wi-Fi', 'Parking', 'Steam/Sauna', 'Home Service', 'UPI/Card Payment', 'Separate Rooms', 'Certified Staff'
  ];

  String? _aadharFile;
  String? _panFile;
  String? _licenseFile;

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _addPricingRow();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var c in [
      _spaName, _ownerName, _yearOfEst, _gstNumber,
      _primaryMobile, _secondaryMobile, _businessEmail, _whatsappNumber,
      _fullAddress, _city, _pincode, _landmark,
      _weeklyOff, _numStaff,
    ]) c.dispose();
    for (var row in _pricingRows) {
      row['service']!.dispose();
      row['price']!.dispose();
    }
    super.dispose();
  }

  void _addPricingRow() => setState(() => _pricingRows.add({'service': TextEditingController(), 'price': TextEditingController()}));
  void _removePricingRow(int i) => setState(() {
        _pricingRows[i]['service']!.dispose();
        _pricingRows[i]['price']!.dispose();
        _pricingRows.removeAt(i);
      });

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please accept Terms & Conditions')));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Submitted!', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        content: const Text('Your spa registration has been submitted successfully.\nWe will review and notify you soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Register Your Spa'),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.titleLarge?.color,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // ALL SECTIONS - FULLY RESTORED & THEMED
              _buildSection(context, icon: Icons.store_rounded, title: "Spa/Salon Details", children: [
                _inputField(_spaName, "Business Name *", hint: "e.g., Serenity Spa & Salon"),
                _inputField(_ownerName, "Owner Name *"),
                _dropdownField("Business Type *", _businessType, ['Spa', 'Salon', 'Both'], (v) => setState(() => _businessType = v)),
                _inputField(_yearOfEst, "Year of Establishment *", keyboard: TextInputType.number),
                _inputField(_gstNumber, "GST Number (Optional)"),
              ]),

              _buildSection(context, icon: Icons.phone_rounded, title: "Contact Information", children: [
                _inputField(_primaryMobile, "Primary Mobile *", keyboard: TextInputType.phone),
                _inputField(_secondaryMobile, "Secondary Mobile"),
                _inputField(_businessEmail, "Business Email *", keyboard: TextInputType.emailAddress),
                _inputField(_whatsappNumber, "WhatsApp Number"),
              ]),

              _buildSection(context, icon: Icons.location_on_rounded, title: "Address & Location", children: [
                _inputField(_fullAddress, "Full Address *", maxLines: 3),
                Row(children: [
                  Expanded(child: _inputField(_city, "City *")),
                  SizedBox(width: 12.w),
                  Expanded(child: _inputField(_pincode, "Pincode *", keyboard: TextInputType.number)),
                ]),
                _inputField(_landmark, "Landmark (Optional)"),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _pickCurrentLocation(),
                    icon: Icon(Icons.my_location_rounded, color: AppColors.primary),
                    label: Text(_latitude != null ? "Location Picked" : "Pick Current Location"),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ]),

              _buildSection(context, icon: Icons.access_time_rounded, title: "Operating Details", children: [
                Row(children: [
                  Expanded(child: _timePicker("Opening Time *", _openingTime, (t) => setState(() => _openingTime = t))),
                  SizedBox(width: 12.w),
                  Expanded(child: _timePicker("Closing Time *", _closingTime, (t) => setState(() => _closingTime = t))),
                ]),
                Row(children: [
                  Expanded(child: _inputField(_weeklyOff, "Weekly Off (e.g., Monday)")),
                  SizedBox(width: 12.w),
                  Expanded(child: _inputField(_numStaff, "Number of Staff *", keyboard: TextInputType.number)),
                ]),
              ]),

              _buildSection(context, icon: Icons.spa_rounded, title: "Services Offered", children: [
                Wrap(spacing: 10.w, runSpacing: 10.h, children: _serviceOptions.map((s) => FilterChip(
                  label: Text(s),
                  selected: _selectedServices.contains(s),
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  onSelected: (v) => setState(() => v ? _selectedServices.add(s) : _selectedServices.remove(s)),
                )).toList()),
              ]),

              _buildSection(context, icon: Icons.price_check_rounded, title: "Pricing", children: [
                _fileUploadTile("Upload Pricing PDF (Optional)", _pricingPdfName, () {}),
                SizedBox(height: 12.h),
                ..._pricingRows.asMap().entries.map((e) => _pricingRow(e.key, e.value)),
                TextButton.icon(onPressed: _addPricingRow, icon: const Icon(Icons.add_rounded), label: const Text("Add Service"), style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
              ]),

              _buildSection(context, icon: Icons.photo_library_rounded, title: "Photos Upload (Max 10)", children: [
                _photos.isEmpty
                    ? _uploadPlaceholder("Tap to add photos", () {})
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: _photos.length + 1,
                        itemBuilder: (context, i) => i < _photos.length
                            ? Stack(children: [Image(image: _photos[i]!), const Positioned(top: 4, right: 4, child: Icon(Icons.cancel_rounded, color: Colors.red))])
                            : _uploadPlaceholder("+ Add", () {}),
                      ),
              ]),

              _buildSection(context, icon: Icons.check_circle_rounded, title: "Facilities", children: [
                Wrap(spacing: 12.w, runSpacing: 10.h, children: _facilityOptions.map((f) => FilterChip(
                  avatar: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(Icons.done, size: 16, color: AppColors.primary)),
                  label: Text(f),
                  selected: _selectedFacilities.contains(f),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  onSelected: (v) => setState(() => v ? _selectedFacilities.add(f) : _selectedFacilities.remove(f)),
                )).toList()),
              ]),

              _buildSection(context, icon: Icons.verified_rounded, title: "Business Verification", children: [
                _fileUploadTile("Aadhar Card *", _aadharFile, () {}),
                _fileUploadTile("PAN Card *", _panFile, () {}),
                _fileUploadTile("Business License", _licenseFile, () {}),
              ]),

              const SizedBox(height: 24),

              Row(children: [
                Checkbox(value: _acceptedTerms, activeColor: AppColors.primary, onChanged: (v) => setState(() => _acceptedTerms = v ?? false)),
                Expanded(child: Text("I accept the Terms & Conditions", style: theme.textTheme.bodyMedium)),
              ]),

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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text("Submit for Review", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
  Widget _buildSection(BuildContext context, {required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 28)),
          SizedBox(width: 16.w),
          Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ]),
        SizedBox(height: 20.h),
        ...children,
      ]),
    );
  }

  Widget _inputField(TextEditingController c, String label, {TextInputType? keyboard, int maxLines = 1, String? hint}) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[600]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2)),
          ),
          validator: (v) => label.contains('*') && (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      );

  Widget _dropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[600]!)),
          ),
          dropdownColor: Theme.of(context).cardColor,
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
          validator: (v) => label.contains('*') && v == null ? 'Required' : null,
        ),
      );

  Widget _timePicker(String label, TimeOfDay? time, ValueChanged<TimeOfDay> onChanged) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: InkWell(
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
            if (t != null) onChanged(t);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[600]!)),
            ),
            child: Text(time?.format(context) ?? 'Select time'),
          ),
        ),
      );

  Widget _fileUploadTile(String label, String? fileName, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.upload_file_rounded, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: fileName != null ? Text(fileName, style: TextStyle(color: AppColors.primary)) : null,
        trailing: ElevatedButton(onPressed: onTap, child: const Text("Upload")),
      );

  Widget _pricingRow(int index, Map<String, TextEditingController> row) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Row(children: [
          Expanded(child: _inputField(row['service']!, "Service Name *")),
          SizedBox(width: 12.w),
          Expanded(child: _inputField(row['price']!, "Price (₹) *", keyboard: TextInputType.number)),
          IconButton(onPressed: () => _removePricingRow(index), icon: Icon(Icons.delete_rounded, color: Colors.red[400])),
        ]),
      );

  Widget _uploadPlaceholder(String text, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid, width: 2), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.primary), Text(text, style: TextStyle(color: AppColors.primary))])),
        ),
      );

  void _pickCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location picker coming soon!')));
  }
}