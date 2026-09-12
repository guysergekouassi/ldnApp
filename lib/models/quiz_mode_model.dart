/// Les trois façons de jouer un même quiz.
///
/// Un « jeu » de l'écran Quiz & Jeux n'est pas une banque de questions à part :
/// c'est une règle appliquée à la banque commune. Toutes les catégories sont
/// donc jouables dans les trois jeux.
enum QuizMode {
  /// Une question après l'autre, sans limite de temps. Le mode par défaut.
  classique,

  /// Quinze secondes par question ; le temps écoulé compte comme une erreur.
  chrono,

  /// Questions et réponses mélangées, et la première erreur arrête la partie.
  melange,
}

/// Convertit le champ `mode` d'un document `gamification_games`. Un mode
/// inconnu — ou absent, pour les jeux semés avant cette version — retombe sur
/// le jeu classique plutôt que d'empêcher de jouer.
QuizMode quizModeDepuisNom(String? nom) {
  switch (nom?.trim().toLowerCase()) {
    case 'chrono':
      return QuizMode.chrono;
    case 'melange':
    case 'mélange':
      return QuizMode.melange;
    default:
      return QuizMode.classique;
  }
}

extension QuizModeInfos on QuizMode {
  String get nom {
    switch (this) {
      case QuizMode.chrono:
        return "Chrono";
      case QuizMode.melange:
        return "Mélange";
      case QuizMode.classique:
        return "Classique";
    }
  }

  /// Phrase affichée avant de lancer une partie, pour que le joueur sache à
  /// quoi il s'engage.
  String get regle {
    switch (this) {
      case QuizMode.chrono:
        return "15 secondes par question. Le temps écoulé compte comme une erreur, mais les points sont majorés de moitié.";
      case QuizMode.melange:
        return "Questions et réponses mélangées, sans droit à l'erreur : la partie s'arrête à la première faute. Points doublés.";
      case QuizMode.classique:
        return "Prends ton temps : aucune limite, aucune pénalité. Les points dépendent de tes bonnes réponses.";
    }
  }

  /// Appliqué aux points du quiz à la fin de la partie.
  double get multiplicateurPoints {
    switch (this) {
      case QuizMode.chrono:
        return 1.5;
      case QuizMode.melange:
        return 2.0;
      case QuizMode.classique:
        return 1.0;
    }
  }

  /// Null quand le mode ne limite pas le temps.
  int? get secondesParQuestion => this == QuizMode.chrono ? 15 : null;

  /// Vrai quand la première mauvaise réponse termine la partie.
  bool get sansDroitALErreur => this == QuizMode.melange;

  /// Vrai quand l'ordre des questions et des réponses doit être tiré au sort.
  bool get melangeLesQuestions => this == QuizMode.melange;
}
