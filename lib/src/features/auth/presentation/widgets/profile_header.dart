// lib/common/widgets/profile_header.dart
import 'package:Spaxify/src/core/theme/tokens.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String phone;
  final String? photoUrl;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.phone,
    this.photoUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onEditTap,
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
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
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
    );
  }
}