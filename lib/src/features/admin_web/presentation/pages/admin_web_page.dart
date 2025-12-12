import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/tokens.dart';

class AdminWebPage extends StatefulWidget {
  const AdminWebPage({super.key});

  @override
  State<AdminWebPage> createState() => _AdminWebPageState();
}

class _AdminWebPageState extends State<AdminWebPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedSpaId;
  DocumentSnapshot<Map<String, dynamic>>? _selectedSpaData;

  // Dark Purple Theme Colors
  static const Color primaryPurple = Color(0xFF6A1B9A);
  static const Color darkPurple = Color(0xFF4A148C);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color dividerColor = Color(0xFF333333);

  final double sectionSpacing = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlack,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: textPrimary,
        title: Row(
          children: const [
            Icon(Icons.dashboard_customize_rounded, color: accentPurple),
            SizedBox(width: 12),
            Text(
              "Admin Review Dashboard",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: textPrimary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: accentPurple.withOpacity(0.3),
              child: const Icon(Icons.admin_panel_settings, color: accentPurple),
            ),
          )
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth < 1000;

          return Row(
            children: [
              _buildSidebar(isTablet),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 16 : 32),
                  child: _selectedSpaData == null
                      ? _emptyState()
                      : _buildSpaDetailPage(constraints),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Sidebar
  Widget _buildSidebar(bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isTablet ? 300 : 360,
      color: surfaceDark,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            decoration: const BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
            ),
            child: Row(
              children: const [
                Icon(Icons.pending_actions, color: Colors.white, size: 26),
                SizedBox(width: 12),
                Text(
                  "Pending Reviews",
                  style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('spas')
                  .where('status', isEqualTo: 'pending_review')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: accentPurple));
                }
                if (snap.data!.docs.isEmpty) return _noPending();

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: snap.data!.docs.length,
                  itemBuilder: (_, i) {
                    final doc = snap.data!.docs[i];
                    final d = doc.data();
                    final name = d['businessName']?.toString() ?? "Spa";
                    final selected = _selectedSpaId == doc.id;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSpaId = doc.id;
                          _selectedSpaData = doc;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected ? primaryPurple.withOpacity(0.3) : cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selected ? accentPurple : Colors.transparent, width: selected ? 2 : 0),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: accentPurple,
                              child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: textPrimary)),
                                  const SizedBox(height: 5),
                                  Text("${d['city'] ?? 'Unknown'} • ${d['ownerName'] ?? 'No Owner'}",
                                      style: TextStyle(fontSize: 13, color: textSecondary)),
                                ],
                              ),
                            ),
                            if (selected) const Icon(Icons.check_circle, color: accentPurple, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Empty State
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined, color: textSecondary.withOpacity(0.6), size: 90),
          const SizedBox(height: 20),
          Text("Select a Spa to Review", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 10),
          Text("Choose a pending spa from the sidebar", style: TextStyle(color: textSecondary, fontSize: 16)),
        ],
      ),
    );
  }

  // Main Detail Page (rest of the code remains the same as before)
  Widget _buildSpaDetailPage(BoxConstraints c) {
    final d = _selectedSpaData!.data()!;
    final name = d['businessName']?.toString() ?? "Spa";
    final initials = (name.length >= 2 ? name.substring(0, 2) : name.padRight(2, 'X')).toUpperCase();
    final photos = (d['photos'] as List?)?.cast<String>() ?? [];

    final bool isTablet = c.maxWidth < 1200;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isTablet ? 32 : 38,
                backgroundColor: accentPurple,
                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(name, style: TextStyle(fontSize: isTablet ? 24 : 28, fontWeight: FontWeight.bold, color: textPrimary)),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: dividerColor, thickness: 1),
          const SizedBox(height: 16),

          _title("Business Information"),
          _infoGrid([
            _tile("Owner Name", d['ownerName']),
            _tile("Business Type", d['businessType']),
            _tile("Established", d['yearOfEst']),
            _tile("GST Number", d['gstNumber']),
          ], c),

          SizedBox(height: sectionSpacing),
          _title("Description"),
          _descriptionCard(d['description']),

          SizedBox(height: sectionSpacing),
          _title("Contact Details"),
          _infoGrid([
            _tile("Mobile", d['primaryMobile']),
            _tile("WhatsApp", d['whatsappNumber']),
            _tile("Email", d['businessEmail']),
          ], c),

          SizedBox(height: sectionSpacing),
          _title("Address"),
          _addressCard(d),

          SizedBox(height: sectionSpacing),
          _title("Gallery"),
          _gallery(photos, c),

          const SizedBox(height: 40),
          _actionButtons(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: accentPurple)),
      );

  Widget _tile(String label, dynamic value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13.5, color: textSecondary)),
          const SizedBox(height: 6),
          Text(value?.toString() ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
        ],
      );

  Widget _infoGrid(List<Widget> tiles, BoxConstraints c) {
    final count = c.maxWidth < 1200 ? 1 : 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: count,
      childAspectRatio: count == 1 ? 5 : 4.5,
      crossAxisSpacing: 24,
      mainAxisSpacing: 16,
      children: tiles,
    );
  }

  Widget _descriptionCard(String? description) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Text(description ?? "No description available", style: TextStyle(fontSize: 15, height: 1.5, color: textPrimary)),
      );

  Widget _addressCard(Map<String, dynamic> d) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: primaryPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryPurple.withOpacity(0.4)),
        ),
        child: Text(
          "${d['fullAddress'] ?? ''}, ${d['city'] ?? ''} - ${d['pincode'] ?? ''}\nLandmark: ${d['landmark'] ?? 'None'}",
          style: const TextStyle(fontSize: 15, color: textPrimary, height: 1.5),
        ),
      );

  Widget _gallery(List<String> photos, BoxConstraints c) {
    if (photos.isEmpty) return Text("No photos uploaded", style: TextStyle(color: textSecondary));

    final count = c.maxWidth < 1200 ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                photos[i],
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(color: accentPurple)),
                errorBuilder: (_, __, ___) => Container(color: surfaceDark, child: const Icon(Icons.broken_image, color: textSecondary)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noPending() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("No pending reviews", style: TextStyle(fontSize: 18, color: textSecondary)),
          ],
        ),
      );

  Widget _actionButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => _approveSpa(_selectedSpaId!),
            icon: const Icon(Icons.check, size: 20),
            label: const Text("APPROVE", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
            ),
          ),
          const SizedBox(width: 20),
          OutlinedButton.icon(
            onPressed: _showRejectDialog,
            icon: const Icon(Icons.close, size: 20),
            label: const Text("REJECT", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 2.5),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );

  Future<void> _approveSpa(String docId) async {
    await _firestore.collection('spas').doc(docId).update({
      'status': 'approved',
      'publishedAt': FieldValue.serverTimestamp(),
    });
    setState(() => _selectedSpaId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Spa Approved Successfully!", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showRejectDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reject Spa Registration", style: TextStyle(color: textPrimary)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: textPrimary),
          decoration: InputDecoration(
            hintText: "Enter reason for rejection...",
            hintStyle: TextStyle(color: textSecondary),
            filled: true,
            fillColor: surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: dividerColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              _rejectSpa(_selectedSpaId!, controller.text.trim().isEmpty ? "No reason provided" : controller.text);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectSpa(String docId, String reason) async {
    await _firestore.collection('spas').doc(docId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
    setState(() => _selectedSpaId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Spa Rejected", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}