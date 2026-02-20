import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class BibleCategoryScreen extends StatelessWidget {
  final String category;

  const BibleCategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulated data
    final List<Map<String, String>> verses = [
      {
        'verse': 'Ne crains rien, car je suis avec toi ; ne promène pas des regards inquiets, car je suis ton Dieu.',
        'reference': 'Ésaïe 41:10',
      },
      {
        'verse': 'Quand je marche dans la vallée de l\'ombre de la mort, je ne crains aucun mal, car tu es avec moi.',
        'reference': 'Psaume 23:4',
      },
      {
        'verse': 'Le Seigneur est ma lumière et mon salut ; de qui aurais-je crainte ?',
        'reference': 'Psaume 27:1',
      },
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'La Parole : $category',
          style: const TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(defaultPadding),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final item = verses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: kAccentColor, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    item['verse']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: kTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item['reference']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                        fontSize: 14,
                      ),
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
}
