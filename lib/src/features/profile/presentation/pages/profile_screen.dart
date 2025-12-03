import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/di/di.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utils/constants/image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      final authController = sl.get<AuthController>();
      await authController.signOut();

      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  // Open website when clicked
  void _launchWebsite() async {
    final Uri url = Uri.parse('https://avrsoftwares.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Not logged in'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        String displayName = user.displayName ?? 'User';
        String phone = '';
        String address = '';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            displayName = data['displayName'] ?? displayName;
            phone = data['phone'] ?? '';
            address = data['address'] ?? '';
          }
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: 140,
              ), // Safe space for bottom nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Profile Header ===
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $displayName!',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phone.isNotEmpty ? phone : 'No phone added',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        currentName: displayName,
                                        currentEmail: user.email ?? '',
                                        currentPhone: phone,
                                        currentAddress: address,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Edit Profile >',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === Menu Items ===
                  _buildMenuItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'My Bookings',
                    subtitle: 'View and manage your spa appointments',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.local_offer_rounded,
                    title: 'Offers',
                    subtitle: 'Exclusive deals and discounts',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.add_business_rounded,
                    title: 'List Your Spa',
                    subtitle: 'Register your spa on BookMySpa',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.trending_up_rounded,
                    title: 'Promote Your Spa',
                    subtitle: 'Run ads and reach more customers',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help Centre',
                    subtitle: 'Get support and answers',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () => _handleLogout(context),
                  ),

                  // === FOOTER: Logo + Branding ===
                  const SizedBox(height: 50),

                  Center(
                    child: Column(
                      children: [
                        // App Logo
                        Image.asset(
                          Images.avr,
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.spa_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'AVR SoftDev',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        GestureDetector(
                          onTap: _launchWebsite,
                          child: Text(
                            'avrsoftwares.com',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          '© 2025 AVR SoftDev. All rights reserved.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13.5, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 28),
          ],
        ),
      ),
    );
  }
}
