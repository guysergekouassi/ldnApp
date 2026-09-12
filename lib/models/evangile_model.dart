class MesseLecture {
  final String type;
  final String title;
  final String reference;
  final String text;

  MesseLecture({
    required this.type,
    required this.title, 
    required this.reference, 
    required this.text,
  });

  factory MesseLecture.fromAelf(Map<String, dynamic> data) {
    String rawText = data['contenu'] ?? '';
    // Strip HTML tags using regex
    String cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Replace standard HTML entities if present
    cleanText = cleanText.replaceAll('&nbsp;', ' ')
                         .replaceAll('&rsquo;', "'")
                         .replaceAll('&laquo;', '«')
                         .replaceAll('&raquo;', '»');

    // Title fallback
    String title = data['intro_lue'] ?? '';
    if (title.isEmpty) {
      title = data['titre'] ?? 'Lecture';
    }

    return MesseLecture(
      type: data['type'] ?? 'lecture',
      title: title,
      reference: data['ref'] ?? '',
      text: cleanText.trim(),
    );
  }
}
