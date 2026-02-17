import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Succès Spirituels',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAchievementGrid(),
              const SizedBox(height: 20),
              _buildNextAchievements(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementGrid() {
    final achievements = [
      Achievement(
        icon: Icons.celebration,
        title: 'Chapelet Royal',
        description: '50 chapelets complétés',
        color: kAccentColor,
        isUnlocked: true,
      ),
      Achievement(
        icon: Icons.church,
        title: 'Dévot des Heures',
        description: '100 offices des heures',
        color: kPrimaryColor,
        isUnlocked: true,
      ),
      Achievement(
        icon: Icons.calendar_today,
        title: 'Fidélité',
        description: '30 jours de prière consécutifs',
        color: kSecondaryColor,
        isUnlocked: true,
      ),
      Achievement(
        icon: Icons.favorite,
        title: 'Cœur de Jésus',
        description: '100 actes de contrition',
        color: Colors.red,
        isUnlocked: false,
      ),
      Achievement(
        icon: Icons.auto_stories,
        title: 'Scripturaire',
        description: 'Lire tout le Nouveau Testament',
        color: Colors.green,
        isUnlocked: false,
      ),
      Achievement(
        icon: Icons.groups,
        title: 'Communautaire',
        description: 'Participer à 25 événements',
        color: Colors.purple,
        isUnlocked: false,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement.isUnlocked 
          ? achievement.color.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked 
            ? achievement.color.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                ? achievement.color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.isUnlocked 
                ? achievement.color
                : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: achievement.isUnlocked 
                ? achievement.color
                : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: achievement.isUnlocked 
                ? kTextSecondaryColor
                : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prochains Succès',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildNextAchievement(
          'Cœur de Jésus',
          '25/100 actes de contrition',
          0.25,
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildNextAchievement(
          'Scripturaire',
          '15/27 livres lus',
          0.56,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildNextAchievement(
          'Communautaire',
          '10/25 événements',
          0.4,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildNextAchievement(String title, String progress, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.lock, color: color, size: 20),
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
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value,
                backgroundColor: kDividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          progress,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Achievement {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isUnlocked;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isUnlocked,
  });
}
