import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';
import 'package:flutter_auth/Screens/profile/components/profile_header.dart';
import 'package:flutter_auth/Screens/profile/components/profile_stats.dart';
import 'package:flutter_auth/Screens/profile/components/profile_menu.dart';
import 'package:flutter_auth/Screens/profile/components/prayer_progress.dart';
import 'package:flutter_auth/Screens/profile/components/achievements_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 420,
              floating: false,
              pinned: true,
              backgroundColor: kPrimaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor,
                        kPrimaryLightColor,
                      ],
                    ),
                  ),
                  child: ProfileHeader(),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Activité'),
                  Tab(text: 'Progrès'),
                  Tab(text: 'Paramètres'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityTab(),
            _buildProgressTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileStats(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
            const SizedBox(height: 24),
            _buildUpcomingEvents(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrayerProgress(),
            const SizedBox(height: 24),
            AchievementsSection(),
            const SizedBox(height: 24),
            _buildSpiritualGoals(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(defaultPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ProfileMenu(),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Activité Récente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            'Chapelet du jour',
            'Il y a 2 heures',
            Icons.celebration,
            kAccentColor,
            'Mystères Joyeux complétés',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Office des Laudes',
            'Ce matin à 7h00',
            Icons.church,
            kPrimaryColor,
            'Prière du matin terminée',
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'Examen de conscience',
            'Hier soir',
            Icons.healing,
            kSecondaryColor,
            'Préparation à la confession',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Événements à Venir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEventItem(
            'Messe dominicale',
            'Demain - 10h00',
            Icons.church,
            kPrimaryColor,
            'Paroisse Saint-Jean',
          ),
          const SizedBox(height: 12),
          _buildEventItem(
            'Groupe de prière',
            'Mercredi - 18h30',
            Icons.groups,
            kAccentColor,
            'Salle paroissiale',
          ),
          const SizedBox(height: 12),
          _buildEventItem(
            'Confession',
            'Samedi - 15h00',
            Icons.healing,
            kSecondaryColor,
            'Église Notre-Dame',
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String time, IconData icon, Color color, String location) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                location,
                style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kAccentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Rappel',
                style: TextStyle(fontSize: 10, color: kAccentColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpiritualGoals() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: kAccentColor),
              const SizedBox(width: 8),
              const Text(
                'Objectifs Spirituels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGoalItem(
            'Prière quotidienne',
            '21 jours consécutifs',
            0.7,
            Icons.schedule,
          ),
          const SizedBox(height: 12),
          _buildGoalItem(
            'Lecture de l\'Évangile',
            '15 minutes par jour',
            0.5,
            Icons.auto_stories,
          ),
          const SizedBox(height: 12),
          _buildGoalItem(
            'Chapelet hebdomadaire',
            '3 fois cette semaine',
            0.33,
            Icons.celebration,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String title, String description, double progress, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kAccentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: kAccentColor, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: kAccentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: kDividerColor,
          valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
          minHeight: 4,
        ),
      ],
    );
  }
}
