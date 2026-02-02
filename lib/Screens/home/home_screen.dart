import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/models/prayer.dart';
import 'package:flutter_auth/components/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final verseOfTheDay = VerseOfTheDay.getTodaysVerse();
    final communityPrayer = CommunityPrayer.getCommunityPrayer();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Accueil /5',
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
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildVerseOfTheDayCard(verseOfTheDay),
            const SizedBox(height: 24),
            _buildCommunityPrayerCard(communityPrayer),
            const SizedBox(height: 24),
            Text('Où en êtes-vous ?', style: kCardTitleStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _buildPersonalAgendaCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bienvenue Marie !',
              style: kTitleStyle.copyWith(fontSize: 26, letterSpacing: -0.5),
            ),
            const SizedBox(width: 8),
            const Text('🙏', style: TextStyle(fontSize: 24)),
          ],
        ),
      ],
    );
  }

  Widget _buildVerseOfTheDayCard(VerseOfTheDay verse) {
    return GlassCard(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
          gradient: LinearGradient(
            colors: [
              kPrimaryColor.withOpacity(0.8),
              kPrimaryColor.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/main_top.png'), // Placeholder or background
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verset du Jour',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '« ${verse.verse} »',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              verse.reference,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Prière du Jour',
              style: TextStyle(
                color: kAccentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              verse.prayer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  minimumSize: const Size(180, 45),
                  maximumSize: const Size(220, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  verse.buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityPrayerCard(CommunityPrayer prayer) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Intention Communautaire',
                  style: kCardTitleStyle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Je prie',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Votre Streak de 7 Jours :',
                style: TextStyle(color: kTextSecondaryColor, fontSize: 14),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.local_fire_department, color: kAccentColor, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: kDividerColor, height: 1),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.church_outlined,
                  title: 'Parcours Métanoia',
                  subtitle: 'Phase 1 - Préparation',
                  badge: '9 AP%',
                  badgeColor: kAccentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Office des Heures',
                  subtitle: 'Prière du matin : 2/10',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.volume_up_outlined,
                  title: 'Office des Heures',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.psychology_outlined,
                  title: 'Chapelet Guidé',
                  progress: '3/30',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kAccentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? kPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    String? progress,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (progress != null)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    value: 0.1,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
                    backgroundColor: kDividerColor,
                  ),
                ),
              Icon(icon, color: kAccentColor, size: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          if (progress != null)
            Text(
              progress,
              style: const TextStyle(color: kTextSecondaryColor, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalAgendaCard() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: kAccentColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda Personnel',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Planifiez votre temps de prière',
                  style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name != '/home') {
          Navigator.pushReplacementNamed(context, '/home');
        }
        break;
      case 1:
        if (ModalRoute.of(context)?.settings.name != '/grow-in-faith') {
          Navigator.pushReplacementNamed(context, '/grow-in-faith');
        }
        break;
      case 3:
        if (ModalRoute.of(context)?.settings.name != '/community') {
          Navigator.pushReplacementNamed(context, '/community');
        }
        break;
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kTextSecondaryColor,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        currentIndex: 0,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined, size: 24),
            activeIcon: Icon(Icons.auto_stories, size: 24),
            label: 'Prier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, size: 24),
            activeIcon: Icon(Icons.explore, size: 24),
            label: 'Découvrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline, size: 24),
            activeIcon: Icon(Icons.people, size: 24),
            label: 'Communauté',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
