import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class PrayerJourneyScreen extends StatelessWidget {
  final String title;
  final String description;

  const PrayerJourneyScreen({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulated steps
    final List<Map<String, dynamic>> steps = [
      {'day': 1, 'title': 'L\'Appel à la Confiance', 'isCompleted': true},
      {'day': 2, 'title': 'L\'Humilité du Cœur', 'isCompleted': true},
      {'day': 3, 'title': 'La Force du Pardon', 'isCompleted': false},
      {'day': 4, 'title': 'L\'Amour du Prochain', 'isCompleted': false},
      {'day': 5, 'title': 'La Persévérance', 'isCompleted': false},
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: kPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Image.asset(
                'assets/images/signup_top.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: kTextSecondaryColor),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Votre progression',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...steps.map((step) => _buildStepItem(step)).toList(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Continuer le parcours'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: step['isCompleted'] ? kAccentColor : kDividerColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${step['day']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: step['isCompleted'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    step['isCompleted'] ? 'Complété' : 'À venir',
                    style: TextStyle(fontSize: 12, color: kTextSecondaryColor),
                  ),
                ],
              ),
            ),
            if (step['isCompleted'])
              const Icon(Icons.check_circle, color: kAccentColor)
            else
              const Icon(Icons.lock_outline, color: kDividerColor, size: 20),
          ],
        ),
      ),
    );
  }
}
