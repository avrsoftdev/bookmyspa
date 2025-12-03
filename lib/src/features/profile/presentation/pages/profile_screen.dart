// profile_screen.dart (now super clean!)
import 'package:bookmyspa/src/features/auth/presentation/widgets/profile_header.dart';
import 'package:bookmyspa/src/features/auth/presentation/widgets/profile_menu_tiles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookmyspa/src/core/di/di.dart';
import 'package:bookmyspa/src/features/auth/presentation/controllers/auth_controller.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Not logged in'));

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

        return Column(
          children: [
            ProfileHeader(
              displayName: displayName,
              phone: phone,
              photoUrl: user.photoURL,
              onEditTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    currentName: displayName,
                    currentEmail: user.email ?? '',
                    currentPhone: phone,
                    currentAddress: address,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  ProfileMenuTile(
                    icon: Icons.receipt_long_rounded,
                    title: 'My Bookings',
                    subtitle: 'View and manage your spa appointments',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.local_offer_rounded,
                    title: 'Offers',
                    subtitle: 'Exclusive deals and discounts',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.add_business_rounded,
                    title: 'List Your Spa',
                    subtitle: 'Register your spa on BookMySpa',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.trending_up_rounded,
                    title: 'Promote Your Spa',
                    subtitle: 'Run ads and reach more customers',
                    onTap: () {},
                  ),
                  ProfileMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Centre',
                    subtitle: 'Get support and answers',
                    onTap: () {},
                  ),

                  ProfileMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    subtitle: 'Sign out and return to login',
                    onTap: () async {
                      final controller = sl.get<AuthController>();
                      await controller.signOut();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
