import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/models/prayer.dart';
import 'package:flutter_auth/components/glass_card.dart';
import 'package:flutter_auth/Screens/grow_in_faith/components/media_detail_screen.dart';
import 'package:flutter_auth/Screens/prayer_agenda/prayer_agenda_screen.dart';
import 'package:flutter_auth/Screens/divine_office/divine_office_screen.dart';
import 'package:flutter_auth/Screens/rosary/rosary_screen.dart';
import 'package:flutter_auth/Screens/confession/confession_screen.dart';
import 'package:flutter_auth/Screens/grow_in_faith/pages/prayer_detail_screen.dart';
import 'package:flutter_auth/Screens/grow_in_faith/pages/bible_category_screen.dart';
import 'package:flutter_auth/Screens/grow_in_faith/pages/prayer_journey_screen.dart';
import 'package:flutter_auth/Screens/grow_in_faith/pages/challenge_detail_screen.dart';

class GrowInFaithScreen extends StatefulWidget {
  const GrowInFaithScreen({Key? key}) : super(key: key);

  @override
  _GrowInFaithScreenState createState() => _GrowInFaithScreenState();
}

class _GrowInFaithScreenState extends State<GrowInFaithScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Prayer> _prayers = Prayer.getSamplePrayers();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Prions Ensemble',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: kAccentColor,
          unselectedLabelColor: kTextSecondaryColor,
          indicatorColor: kAccentColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Prières'),
            Tab(text: 'Enseignements'),
            Tab(text: 'Méditation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Prières Tab
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader('Préparation à la Confession'),
                const SizedBox(height: 16),
                _buildConfessionCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('Chapelet Guidé'),
                const SizedBox(height: 16),
                _buildRosaryCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('Office des Heures'),
                const SizedBox(height: 16),
                _buildDivineOfficeCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('Agenda de Prière'),
                const SizedBox(height: 16),
                _buildPrayerAgendaCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('Prions Ensemble'),
                const SizedBox(height: 16),
                _buildPrayerHorizontalList(),
                const SizedBox(height: 32),
                _buildSectionHeader('Parcours de Prière'),
                const SizedBox(height: 16),
                _buildPrayerJourneyList(),
                const SizedBox(height: 32),
                _buildSectionHeader('Trouvez la Parole pour votre situation'),
                const SizedBox(height: 20),
                _buildWordCategoriesGrid(),
                const SizedBox(height: 32),
                _buildSectionHeader('Défis Spirituels'),
                const SizedBox(height: 16),
                _buildSpiritualChallengesCard(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          // Enseignements Tab
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader('À la une'),
                const SizedBox(height: 16),
                _buildFeaturedTeaching(),
                const SizedBox(height: 32),
                _buildSectionHeader('Vidéos Récentes'),
                const SizedBox(height: 16),
                _buildMediaList(type: 'video'),
                const SizedBox(height: 32),
                _buildSectionHeader('Audios & Podcasts'),
                const SizedBox(height: 16),
                _buildMediaList(type: 'audio'),
                const SizedBox(height: 30),
              ],
            ),
          ),
          // Méditation Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildMeditationOfTheDay(),
                const SizedBox(height: 32),
                _buildSectionHeader('Parcours de Méditation'),
                const SizedBox(height: 16),
                _buildMeditationPaths(),
                const SizedBox(height: 32),
                _buildSectionHeader('Sons d\'ambiance'),
                const SizedBox(height: 16),
                _buildAmbientSounds(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(1),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
    );
  }

  Widget _buildPrayerHorizontalList() {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _prayers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final prayer = _prayers[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrayerDetailScreen(
                    title: prayer.title,
                    content: prayer.description + '\n\nSeigneur, nous nous confions à toi et nous te demandons ta grâce et ta protection.',
                    category: prayer.category,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.asset(
                      'assets/images/login_bottom.png',
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      prayer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerJourneyList() {
    return Column(
      children: [
        _buildJourneyItem(
          title: 'Neuvaine à Marie Étoile',
          subtitle: 'Prions pour les étudiants...',
          image: 'assets/images/main_top.png',
        ),
        const SizedBox(height: 16),
        _buildJourneyItem(
          title: 'Série de la Miséricorde Ep 2',
          subtitle: 'Prions pour la guérison...',
          image: 'assets/images/signup_top.png',
        ),
      ],
    );
  }

  Widget _buildJourneyItem({required String title, required String subtitle, required String image}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrayerJourneyScreen(
              title: title,
              description: subtitle,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: kTextSecondaryColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextSecondaryColor),
          ],
        ),
      ),
    );

  Widget _buildWordCategoriesGrid() {
    final categories = [
      {'icon': Icons.warning_amber_rounded, 'label': 'Peur'},
      {'icon': Icons.emoji_objects_outlined, 'label': 'Espérance'},
      {'icon': Icons.school_outlined, 'label': 'Études'},
      {'icon': Icons.psychology_outlined, 'label': 'Discernement'},
      {'icon': Icons.military_tech_outlined, 'label': 'Excellence'},
      {'icon': Icons.help_outline, 'label': 'Doute'},
      {'icon': Icons.favorite_border, 'label': 'Sexualité'},
      {'icon': Icons.sentiment_satisfied_alt, 'label': 'Sensualité'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BibleCategoryScreen(
                  category: category['label'] as String,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(category['icon'] as IconData, color: kAccentColor, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                category['label'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfessionCard() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.healing, color: kAccentColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préparation à la Confession',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Examen de conscience et prières',
                  style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: kAccentColor, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfessionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRosaryCard() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.celebration, color: kAccentColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapelet Guidé',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Priez le chapelet avec méditations',
                  style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: kAccentColor, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RosaryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDivineOfficeCard() {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.church_outlined, color: kAccentColor, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office des Heures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Prière liturgique avec audio',
                  style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: kAccentColor, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DivineOfficeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerAgendaCard() {
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
                  'Agenda de Prière',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Planifiez vos temps de prière quotidiens',
                  style: TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: kAccentColor, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerAgendaScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualChallengesCard() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeDetailScreen(
              title: 'Défi de la Semaine',
              description: 'Priez le chapelet chaque jour pendant une semaine pour renforcer votre foi et votre connexion spirituelle.',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events_outlined, color: kAccentColor, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Défi de la Semaine',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Priez le chapelet chaque jour',
                        style: TextStyle(color: kTextSecondaryColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.4,
              backgroundColor: kDividerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(kAccentColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );

  Widget _buildBottomNavigationBar(int currentIndex) {
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
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/community');
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

  Widget _buildMediaList({required String type}) {
    final isVideo = type == 'video';
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final isRow1 = index == 0;
        return _buildMediaCard(
          title: isVideo 
              ? (isRow1 ? 'Enseignement : Foi et Espérance' : 'L\'Art de la Prière')
              : (isRow1 ? 'Louange Matinale - Adoration' : 'Méditation sur le Psaume 23'),
          duration: isVideo ? '02:30' : '05:45',
          isVideo: isVideo,
          author: isVideo ? 'Pasteur David' : 'Sœur Marie',
          image: isVideo ? 'assets/images/main_top.png' : 'assets/images/signup_top.png',
          audioUrl: isVideo ? null : 'https://raw.githubusercontent.com/rafaelreis-hotmart/Audio-Sample-files/master/sample.mp3',
          videoUrl: isVideo ? 'assets/VID/intro_video.mp4' : null,
        );
      },
    );
  }

  Widget _buildMediaCard({
    required String title,
    required String duration,
    required bool isVideo,
    required String author,
    required String image,
    String? audioUrl,
    String? videoUrl,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaDetailScreen(
              title: title,
              author: author,
              duration: duration,
              isVideo: isVideo,
              image: image,
              audioUrl: audioUrl,
              videoUrl: videoUrl,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(defaultBorderRadius)),
                  child: Image.asset(
                    image,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(defaultBorderRadius)),
                  ),
                ),
                Icon(
                  isVideo ? Icons.play_circle_fill : Icons.headphones,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isVideo ? kPrimaryColor.withOpacity(0.1) : kAccentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isVideo ? 'VIDÉO' : 'AUDIO',
                            style: TextStyle(
                              color: isVideo ? kPrimaryColor : kAccentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          duration,
                          style: const TextStyle(fontSize: 12, color: kTextSecondaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      author,
                      style: const TextStyle(fontSize: 12, color: kTextSecondaryColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMeditationOfTheDay() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(defaultBorderRadius)),
                child: Image.asset(
                  'assets/images/main_top.png',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(defaultBorderRadius)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'MÉDITATION DU JOUR',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Trouver la Paix Intérieure',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Une session de 10 minutes pour calmer votre esprit et vous connecter à votre foi.',
                    style: TextStyle(fontSize: 14, color: kTextSecondaryColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationPaths() {
    final paths = [
      {'title': 'Débuter la Méditation', 'count': '5 sessions', 'icon': Icons.spa_outlined},
      {'title': 'Gérer le Stress', 'count': '7 sessions', 'icon': Icons.wb_sunny_outlined},
      {'title': 'Sommeil Paisible', 'count': '3 sessions', 'icon': Icons.nights_stay_outlined},
      {'title': 'Gratitude Quotidienne', 'count': '10 sessions', 'icon': Icons.favorite_border},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final path = paths[index];
        return InkWell(
          onTap: () {},
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(path['icon'] as IconData, color: kAccentColor),
                const SizedBox(height: 8),
                Text(
                  path['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  path['count'] as String,
                  style: const TextStyle(color: kTextSecondaryColor, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientSounds() {
    final sounds = [
      {'name': 'Pluie Douce', 'icon': Icons.umbrella_outlined},
      {'name': 'Forêt', 'icon': Icons.forest_outlined},
      {'name': 'Océan', 'icon': Icons.waves_outlined},
      {'name': 'Rivière', 'icon': Icons.water_outlined},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sounds.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final sound = sounds[index];
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(sound['icon'] as IconData, color: kPrimaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                sound['name'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildFeaturedTeaching() {
    return InkWell(
      onTap: () {},
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(defaultBorderRadius)),
                  child: Image.asset(
                    'assets/images/signup_top.png',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('POPULAIRE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Les Secrets de la Prière Efficace',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: kAccentColor.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 14, color: kAccentColor),
                      ),
                      const SizedBox(width: 8),
                      const Text('Par Sœur Thérèse', style: TextStyle(color: kTextSecondaryColor, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: kTextSecondaryColor),
                      const SizedBox(width: 4),
                      const Text('15 min', style: TextStyle(color: kTextSecondaryColor, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


