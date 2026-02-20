import 'package:flutter/material.dart';
import 'package:flutter_auth/constants.dart';
import 'package:flutter_auth/components/glass_card.dart';

class PrayerDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final String? imagePath;

  const PrayerDetailScreen({
    Key? key,
    required this.title,
    required this.content,
    required this.category,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath ?? 'assets/images/main_top.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kAccentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            color: kAccentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, color: kPrimaryColor),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, color: kPrimaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, color: kAccentColor, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.8,
                            color: kTextColor,
                            fontFamily: 'Georgia',
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'Amen',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Réflexion suggérée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Prenez un moment pour méditer sur l\'impact de ces mots dans votre vie aujourd\'hui. Qu\'est-ce que le Seigneur essaie de vous dire à travers cette prière ?',
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextSecondaryColor,
                      height: 1.5,
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
}
