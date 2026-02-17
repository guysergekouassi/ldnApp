import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class PrayerProgress extends StatelessWidget {
  const PrayerProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression de Prière',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSection('Aujourd\'hui', [
                _buildPrayerProgress('Chapelet du matin', 1.0, kAccentColor),
                _buildPrayerProgress('Angélus', 1.0, kPrimaryColor),
                _buildPrayerProgress('Office du soir', 0.0, kTextSecondaryColor),
              ]),
              const SizedBox(height: 20),
              _buildProgressSection('Cette semaine', [
                _buildPrayerProgress('Office des Laudes', 5/7, kPrimaryColor),
                _buildPrayerProgress('Chapelets', 4/7, kAccentColor),
                _buildPrayerProgress('Lecture Évangile', 6/7, kSecondaryColor),
                _buildPrayerProgress('Examen de conscience', 3/7, kTextSecondaryColor),
              ]),
              const SizedBox(height: 20),
              _buildProgressSection('Ce mois', [
                _buildPrayerProgress('Messes dominicales', 3/4, kPrimaryColor),
                _buildPrayerProgress('Confessions', 1/2, kSecondaryColor),
                _buildPrayerProgress('Adoration', 2/4, kAccentColor),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(String title, List<Widget> prayers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...prayers,
      ],
    );
  }

  Widget _buildPrayerProgress(String title, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: kDividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
