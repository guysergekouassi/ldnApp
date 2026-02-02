import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mon Espace',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: kTextColor),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: kTextColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildMySpaceSection(),
            const SizedBox(height: 32),
            _buildProfileSettingsSection(),
            const SizedBox(height: 32),
            _buildUpcomingEventsSection(),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: kAccentColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
        label: const Text(
          'Ajouter mon\nintention',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(3, context),
    );
  }

  Widget _buildMySpaceSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: kAccentColor, size: 28),
              const SizedBox(width: 12),
              const Text(
                '7',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kTextColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Jours de prière consécutifs',
                  style: TextStyle(color: kTextSecondaryColor.withOpacity(0.8), fontSize: 13),
                ),
              ),
              // Tiny bar chart representation
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (index) => Container(
                  width: 4,
                  height: (index + 1) * 4.0,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: index == 4 ? kAccentColor : kDividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUserProfileSnippet(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircularProgress(0.5, '50%', 'Lire les Évangiles\npar mois'),
              _buildCircularProgress(0.75, '75%', 'Service une fois\npar mois'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSnippet() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/signup_top.png'), // Placeholder
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre parcours actuel :',
                  style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                ),
                Text(
                  'Niveau 2 - La Vie dans l\'Esprit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            '3/10',
            style: TextStyle(color: kTextSecondaryColor.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double value, String label, String description) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(kAccentColor.withOpacity(0.8)),
                backgroundColor: kDividerColor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: kTextSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildProfileSettingsSection() {
    return Column(
      children: [
        _buildListTile(Icons.person_outline, 'Profil', trailing: Switch(value: true, onChanged: (v){}, activeColor: kAccentColor,)),
        const SizedBox(height: 12),
        _buildListTile(Icons.wb_sunny_outlined, 'Mon Programme de Prière'),
        const SizedBox(height: 12),
        _buildListTile(Icons.dark_mode_outlined, 'Mode Nuit'),
        const SizedBox(height: 12),
        _buildListTile(Icons.notifications_outlined, 'Rappels'),
        const SizedBox(height: 12),
        _buildListTile(Icons.favorite_outline, 'Favoris'),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
          trailing ?? const Icon(Icons.chevron_right, color: kDividerColor),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Événements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Questions/Réponses - Shalom Berger...',
                  style: TextStyle(color: kTextColor.withOpacity(0.8), fontSize: 14),
                ),
              ),
              const Icon(Icons.calendar_today_outlined, color: kAccentColor, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kTextSecondaryColor,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/grow-in-faith');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories),
            label: 'Prier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Découvrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Communauté',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
