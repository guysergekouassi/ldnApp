import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/models/prayer.dart';
import 'package:flutter_auth/components/glass_card.dart';
import 'package:flutter_auth/Screens/grow_in_faith/components/media_detail_screen.dart';

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
          const Center(child: Text('Méditation Content')),
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
          return Container(
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
    return GlassCard(
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
    );
  }

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
        return Column(
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
        );
      },
    );
  }

  Widget _buildSpiritualChallengesCard() {
    return GlassCard(
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
    );
  }

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
}
