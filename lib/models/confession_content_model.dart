class ConfessionStep {
  final String number;
  final String title;
  final String description;

  ConfessionStep({
    required this.number,
    required this.title,
    required this.description,
  });

  factory ConfessionStep.fromMap(Map<String, dynamic> data) {
    return ConfessionStep(
      number: data['number']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
    );
  }
}

class ConfessionContent {
  final String introText;
  final String acteTitle;
  final String acteIntro;
  final String acteText;
  final List<ConfessionStep> steps;

  ConfessionContent({
    required this.introText,
    required this.acteTitle,
    required this.acteIntro,
    required this.acteText,
    required this.steps,
  });

  factory ConfessionContent.fromFirestore(Map<String, dynamic> data) {
    final rawSteps = data['steps'] as List<dynamic>? ?? [];
    return ConfessionContent(
      introText: data['introText']?.toString() ?? '',
      acteTitle: data['acteTitle']?.toString() ?? 'Acte de Contrition',
      acteIntro: data['acteIntro']?.toString() ?? '',
      acteText: data['acteText']?.toString() ?? '',
      steps: rawSteps
          .map((e) => ConfessionStep.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
