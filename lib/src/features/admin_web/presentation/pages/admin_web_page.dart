import 'package:flutter/material.dart';
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
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Pending Spa Reviews',
                      style: Theme.of(context).textTheme.titleLarge,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business info
          Text('Business Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildInfoRow('Business Name', data['businessName'] ?? '-'),
          _buildInfoRow('Owner Name', data['ownerName'] ?? '-'),
          _buildInfoRow('Business Type', data['businessType'] ?? '-'),
          _buildInfoRow('Year of Establishment', data['yearOfEst'] ?? '-'),
          _buildInfoRow('GST Number', data['gstNumber'] ?? '-'),
          const SizedBox(height: 24),

          // Contact info
          Text('Contact Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildInfoRow('Primary Mobile', data['primaryMobile'] ?? '-'),
          _buildInfoRow('Secondary Mobile', data['secondaryMobile'] ?? '-'),
          _buildInfoRow('Business Email', data['businessEmail'] ?? '-'),
          _buildInfoRow('WhatsApp Number', data['whatsappNumber'] ?? '-'),
          const SizedBox(height: 24),

          // Address
          Text('Address & Location', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildInfoRow('Full Address', data['fullAddress'] ?? '-'),
          _buildInfoRow('City', data['city'] ?? '-'),
          _buildInfoRow('Pincode', data['pincode'] ?? '-'),
          _buildInfoRow('Landmark', data['landmark'] ?? '-'),
          if (data['latitude'] != null && data['longitude'] != null)
            _buildInfoRow(
              'Coordinates',
              '${data['latitude']}, ${data['longitude']}',
            ),
          const SizedBox(height: 24),

          // Operating details
          Text('Operating Details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _buildInfoRow('Opening Time', data['openingTime'] ?? '-'),
          _buildInfoRow('Closing Time', data['closingTime'] ?? '-'),
          _buildInfoRow('Weekly Off', data['weeklyOff'] ?? '-'),
          _buildInfoRow('Number of Staff', data['numStaff'] ?? '-'),
          const SizedBox(height: 24),

          // Services & Facilities
          if ((data['services'] as List?)?.isNotEmpty == true) ...[
            Text('Services Offered', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (data['services'] as List).map<Widget>((s) => Chip(label: Text(s))).toList(),
            ),
            const SizedBox(height: 24),
          ],

          if ((data['facilities'] as List?)?.isNotEmpty == true) ...[
            Text('Facilities', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (data['facilities'] as List).map<Widget>((f) => Chip(label: Text(f))).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Pricing
          if ((data['pricing'] as List?)?.isNotEmpty == true) ...[
            Text('Pricing', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
              children: [
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Service', style: Theme.of(context).textTheme.labelLarge),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('Price', style: Theme.of(context).textTheme.labelLarge),
                  ),
                ]),
                ...(data['pricing'] as List).map<TableRow>((p) {
                  final price = p as Map;
                  return TableRow(children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(price['service'] ?? '-')),
                    Padding(padding: const EdgeInsets.all(8), child: Text('₹${price['price'] ?? '-'}')),
                  ]);
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Photos
          if (photos.isNotEmpty) ...[
            Text('Photos (${photos.length})', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: photos.map<Widget>((url) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(url, fit: BoxFit.cover),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Documents (Aadhar, PAN, License)
          Text('Documents', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (aadharUrl != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Aadhar Card', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(aadharUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          if (panUrl != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PAN Card', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(panUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          if (licenseUrl != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Business License', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: Image.network(licenseUrl, fit: BoxFit.cover),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _approveSpa(_selectedSpaId!),
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showRejectDialog(),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
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
