import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildProfilePicture(),
            const SizedBox(height: 12),
            _buildUserInfo(),
            const SizedBox(height: 12),
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: kPrimaryColor,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: kAccentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const Text(
          'Marie Dupont',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@marie_dupont',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Membre depuis Janvier 2024',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Membre Actif',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
