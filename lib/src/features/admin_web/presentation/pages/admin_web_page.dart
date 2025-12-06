import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminWebPage extends StatefulWidget {
  const AdminWebPage({Key? key}) : super(key: key);

  @override
  State<AdminWebPage> createState() => _AdminWebPageState();
}

class _AdminWebPageState extends State<AdminWebPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSpaId;
  DocumentSnapshot<Map<String, dynamic>>? _selectedSpaData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel - Spa Review Dashboard'),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
      ),
      body: Row(
        children: [
          // Left panel: list of pending spas
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Pending Spa Reviews',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firestore
                          .collection('spas')
                          .where('status', isEqualTo: 'pending_review')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No pending spas'));
                        }
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final isSelected = _selectedSpaId == doc.id;
                            return Container(
                              color: isSelected ? Colors.blue[50] : null,
                              child: ListTile(
                                title: Text(doc['businessName'] ?? 'Unnamed'),
                                subtitle: Text(doc['city'] ?? 'Unknown City'),
                                trailing: Text(
                                  doc['ownerName'] ?? '-',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                selected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedSpaId = doc.id;
                                    _selectedSpaData = doc;
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right panel: details and review actions
          Expanded(
            flex: 2,
            child: _selectedSpaData == null
                ? const Center(child: Text('Select a spa to review'))
                : _buildSpaDetailsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaDetailsPanel() {
    final data = _selectedSpaData!.data() ?? {};
    final photos = data['photos'] as List? ?? [];
    final aadharUrl = data['aadharUrl'] as String?;
    final panUrl = data['panUrl'] as String?;
    final licenseUrl = data['licenseUrl'] as String?;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business info
          Text('Business Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
          SizedBox(height: 12.h),
          _buildInfoRow('Business Name', data['businessName'] ?? '-'),
          _buildInfoRow('Owner Name', data['ownerName'] ?? '-'),
          _buildInfoRow('Business Type', data['businessType'] ?? '-'),
          _buildInfoRow('Year of Establishment', data['yearOfEst'] ?? '-'),
          _buildInfoRow('GST Number', data['gstNumber'] ?? '-'),
          SizedBox(height: 24.h),

          // Contact info
          Text('Contact Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
          SizedBox(height: 12.h),
          _buildInfoRow('Primary Mobile', data['primaryMobile'] ?? '-'),
          _buildInfoRow('Secondary Mobile', data['secondaryMobile'] ?? '-'),
          _buildInfoRow('Business Email', data['businessEmail'] ?? '-'),
          _buildInfoRow('WhatsApp Number', data['whatsappNumber'] ?? '-'),
          SizedBox(height: 24.h),

          // Address
          Text('Address & Location', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
          SizedBox(height: 12.h),
          _buildInfoRow('Full Address', data['fullAddress'] ?? '-'),
          _buildInfoRow('City', data['city'] ?? '-'),
          _buildInfoRow('Pincode', data['pincode'] ?? '-'),
          _buildInfoRow('Landmark', data['landmark'] ?? '-'),
          if (data['latitude'] != null && data['longitude'] != null)
            _buildInfoRow(
              'Coordinates',
              '${data['latitude']}, ${data['longitude']}',
            ),
          SizedBox(height: 24.h),

          // Operating details
          Text('Operating Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
          SizedBox(height: 12.h),
          _buildInfoRow('Opening Time', data['openingTime'] ?? '-'),
          _buildInfoRow('Closing Time', data['closingTime'] ?? '-'),
          _buildInfoRow('Weekly Off', data['weeklyOff'] ?? '-'),
          _buildInfoRow('Number of Staff', data['numStaff'] ?? '-'),
          SizedBox(height: 24.h),

          // Services & Facilities
          if ((data['services'] as List?)?.isNotEmpty == true) ...[
            Text('Services Offered', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              children: (data['services'] as List).map<Widget>((s) => Chip(label: Text(s, style: TextStyle(fontSize: 14.sp)))).toList(),
            ),
            SizedBox(height: 24.h),
          ],

          if ((data['facilities'] as List?)?.isNotEmpty == true) ...[
            Text('Facilities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              children: (data['facilities'] as List).map<Widget>((f) => Chip(label: Text(f, style: TextStyle(fontSize: 14.sp)))).toList(),
            ),
            SizedBox(height: 24.h),
          ],

          // Pricing
          if ((data['pricing'] as List?)?.isNotEmpty == true) ...[
            Text('Pricing', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 12.h),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
              children: [
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text('Service', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14.sp)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text('Price', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14.sp)),
                  ),
                ]),
                ...(data['pricing'] as List).map<TableRow>((p) {
                  final price = p as Map;
                  return TableRow(children: [
                    Padding(padding: EdgeInsets.all(8.w), child: Text(price['service'] ?? '-', style: TextStyle(fontSize: 14.sp))),
                    Padding(padding: EdgeInsets.all(8.w), child: Text('₹${price['price'] ?? '-'}', style: TextStyle(fontSize: 14.sp))),
                  ]);
                }),
              ],
            ),
            SizedBox(height: 24.h),
          ],

          // Photos
          if (photos.isNotEmpty) ...[
            Text('Photos (${photos.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: photos.map<Widget>((url) {
                return Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(url, fit: BoxFit.cover),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
          ],

          // Documents (Aadhar, PAN, License)
          Text('Documents', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
          SizedBox(height: 12.h),
          if (aadharUrl != null) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aadhar Card', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Container(
                  width: 300.w,
                  height: 200.h,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(aadharUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          if (panUrl != null) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PAN Card', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Container(
                  width: 300.w,
                  height: 200.h,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(panUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          if (licenseUrl != null) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Business License', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                Container(
                  width: 300.w,
                  height: 200.h,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(licenseUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          SizedBox(height: 32.h),

          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _approveSpa(_selectedSpaId!),
                icon: const Icon(Icons.check),
                label: Text('Approve', style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              SizedBox(width: 12.w),
              ElevatedButton.icon(
                onPressed: () => _showRejectDialog(),
                icon: const Icon(Icons.close),
                label: Text('Reject', style: TextStyle(fontSize: 14.sp)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(width: 150.w, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp))),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }

  Future<void> _approveSpa(String docId) async {
    await _firestore.collection('spas').doc(docId).update({
      'status': 'approved',
      'publishedAt': FieldValue.serverTimestamp(),
    });
    setState(() => _selectedSpaId = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spa approved!')));
  }

  Future<void> _showRejectDialog() async {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Spa'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for rejection (optional)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _rejectSpa(_selectedSpaId!, reasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectSpa(String docId, String reason) async {
    final updateData = {'status': 'rejected'};
    if (reason.isNotEmpty) updateData['rejectionReason'] = reason;
    await _firestore.collection('spas').doc(docId).update(updateData);
    setState(() => _selectedSpaId = null);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spa rejected!')));
  }
}
