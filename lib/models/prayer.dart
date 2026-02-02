class Prayer {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final bool isFeatured;
  final String category;

  Prayer({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isFeatured = false,
    required this.category,
  });

  // Sample data for testing
  static List<Prayer> getSamplePrayers() {
    return [
      Prayer(
        id: '1',
        title: 'Neuvaine à Marie Étoile',
        description: 'Prière de 9 jours pour se confier à Marie',
        imagePath: 'assets/images/prayer1.jpg',
        isFeatured: true,
        category: 'prière',
      ),
      Prayer(
        id: '2',
        title: 'Chapelet de la Miséricorde',
        description: 'Prière pour la miséricorde divine',
        imagePath: 'assets/images/prayer2.jpg',
        category: 'prière',
      ),
    ];
  }
}

class VerseOfTheDay {
  final String verse;
  final String reference;
  final String prayer;
  final String buttonText;

  VerseOfTheDay({
    required this.verse,
    required this.reference,
    required this.prayer,
    required this.buttonText,
  });

  static VerseOfTheDay getTodaysVerse() {
    return VerseOfTheDay(
      verse: 'L\'Éternel est ma lumière et mon salut',
      reference: 'Psaume 27:1',
      prayer: 'Prions pour les étudiants qui passent leurs examens.',
      buttonText: 'Prier maintenant',
    );
  }
}

class CommunityPrayer {
  final String id;
  final String title;
  final String description;
  final int daysLeft;
  final int participants;

  CommunityPrayer({
    required this.id,
    required this.title,
    required this.description,
    required this.daysLeft,
    required this.participants,
  });

  static CommunityPrayer getCommunityPrayer() {
    return CommunityPrayer(
      id: '1',
      title: 'Votre Streak de 7 Jours',
      description: 'Prière quotidienne pour la paix',
      daysLeft: 3,
      participants: 42,
    );
  }
}
