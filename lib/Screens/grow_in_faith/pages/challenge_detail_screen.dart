import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  const ChallengeDetailScreen({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Défi Spirituel', style: TextStyle(color: kTextColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined, color: kAccentColor, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kTextSecondaryColor),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Durée', '30 jours'),
                      _buildStatItem('Participants', '1.2k'),
                      _buildStatItem('Niveau', 'Moyen'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Règles du défi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRuleItem('1', 'Priez chaque matin pendant 5 minutes.'),
            _buildRuleItem('2', 'Partagez un verset avec un proche.'),
            _buildRuleItem('3', 'Notez vos gratitudes le soir.'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Rejoindre le défi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
        Text(label, style: const TextStyle(fontSize: 12, color: kTextSecondaryColor)),
      ],
    );
  }

  Widget _buildRuleItem(String number, String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: const TextStyle(fontWeight: FontWeight.bold, color: kAccentColor)),
          const SizedBox(width: 12),
          Expanded(child: Text(rule)),
        ],
      ),
    );
  }
}
