import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isLogin;

  const SocialLoginButtons({
    Key? key,
    required this.isLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              'Google',
              'assets/icons/google.png',
              Colors.red,
              () {
                // TODO: Implement Google login
                _showSocialLoginMessage(context, 'Google');
              },
            ),
            _buildSocialButton(
              'Facebook',
              'assets/icons/facebook.png',
              Colors.blue,
              () {
                // TODO: Implement Facebook login
                _showSocialLoginMessage(context, 'Facebook');
              },
            ),
            _buildSocialButton(
              'Apple',
              'assets/icons/apple.png',
              Colors.black,
              () {
                // TODO: Implement Apple login
                _showSocialLoginMessage(context, 'Apple');
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLogin
                    ? 'Connectez-vous rapidement avec vos comptes sociaux'
                    : 'Créez votre compte en un clic avec vos réseaux sociaux',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, String iconPath, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildIcon(iconPath, color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath, Color color) {
    // Since we don't have the actual icon assets, we'll use colored icons
    switch (iconPath) {
      case 'assets/icons/google.png':
        return Icon(Icons.search, color: color);
      case 'assets/icons/facebook.png':
        return Icon(Icons.facebook, color: color);
      case 'assets/icons/apple.png':
        return Icon(Icons.apple, color: color);
      default:
        return Icon(Icons.help_outline, color: color);
    }
  }

  void _showSocialLoginMessage(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion avec $provider bientôt disponible!'),
        backgroundColor: kPrimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
