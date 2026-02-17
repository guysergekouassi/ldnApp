import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuSection('Compte', [
          _buildMenuItem(
            'Informations personnelles',
            Icons.person,
            kPrimaryColor,
            () => _showComingSoon(context, 'Informations personnelles'),
          ),
          _buildMenuItem(
            'Sécurité',
            Icons.security,
            kSecondaryColor,
            () => _showComingSoon(context, 'Sécurité'),
          ),
          _buildMenuItem(
            'Notifications',
            Icons.notifications,
            kAccentColor,
            () => _showComingSoon(context, 'Notifications'),
          ),
        ]),
        const SizedBox(height: 24),
        _buildMenuSection('Préférences', [
          _buildMenuItem(
            'Langue',
            Icons.language,
            kPrimaryColor,
            () => _showLanguageDialog(context),
          ),
          _buildMenuItem(
            'Thème',
            Icons.palette,
            kSecondaryColor,
            () => _showThemeDialog(context),
          ),
          _buildMenuItem(
            'Rappels de prière',
            Icons.schedule,
            kAccentColor,
            () => _showComingSoon(context, 'Rappels de prière'),
          ),
        ]),
        const SizedBox(height: 24),
        _buildMenuSection('Communauté', [
          _buildMenuItem(
            'Inviter des amis',
            Icons.share,
            kPrimaryColor,
            () => _showComingSoon(context, 'Inviter des amis'),
          ),
          _buildMenuItem(
            'Aide et support',
            Icons.help,
            kSecondaryColor,
            () => _showComingSoon(context, 'Aide et support'),
          ),
          _buildMenuItem(
            'À propos',
            Icons.info,
            kAccentColor,
            () => _showAboutDialog(context),
          ),
        ]),
        const SizedBox(height: 24),
        _buildMenuSection('Action', [
          _buildMenuItem(
            'Déconnexion',
            Icons.logout,
            Colors.red,
            () => _showLogoutDialog(context),
            isDestructive: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : kTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isDestructive ? Colors.red : kTextSecondaryColor,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Cette fonctionnalité sera bientôt disponible!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('Français', true),
            _buildLanguageOption('English', false),
            _buildLanguageOption('Español', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: isSelected ? language : null,
      onChanged: (value) {},
      activeColor: kPrimaryColor,
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Clair', Icons.light_mode, true),
            _buildThemeOption('Sombre', Icons.dark_mode, false),
            _buildThemeOption('Automatique', Icons.brightness_auto, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon, bool isSelected) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(theme),
        ],
      ),
      value: theme,
      groupValue: isSelected ? theme : null,
      onChanged: (value) {},
      activeColor: kPrimaryColor,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Jeunesse en Prière',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.church, size: 48),
      children: [
        const Text('Une application pour accompagner les jeunes dans leur vie de prière et leur croissance spirituelle.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/auth');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
