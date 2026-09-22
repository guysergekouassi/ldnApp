import '../models/discipline_model.dart';

/// Engagements proposés dans la règle de vie.
///
/// Volontairement court et réaliste : une règle de vie qu'on ne peut pas tenir
/// décourage plus qu'elle ne construit. Le membre en choisit trois au minimum,
/// et rien n'empêche de commencer par les plus simples.
const List<EngagementSpirituel> catalogueEngagements = [
  EngagementSpirituel(
    id: 'priere_matin',
    titre: "Prière du matin",
    description: "Offrir sa journée avant de la commencer, même en deux minutes.",
    iconName: 'wb_sunny_outlined',
    frequence: FrequenceEngagement.quotidien,
  ),
  EngagementSpirituel(
    id: 'parole',
    titre: "Un passage de la Parole",
    description: "L'évangile du jour, ou l'étape de son plan de lecture.",
    iconName: 'menu_book',
    frequence: FrequenceEngagement.quotidien,
  ),
  EngagementSpirituel(
    id: 'chapelet',
    titre: "Chapelet",
    description: "Une dizaine suffit les jours chargés : mieux vaut court que rien.",
    iconName: 'circle_outlined',
    frequence: FrequenceEngagement.quotidien,
  ),
  EngagementSpirituel(
    id: 'examen_soir',
    titre: "Examen du soir",
    description: "Relire sa journée devant Dieu avant de dormir.",
    iconName: 'nightlight_round',
    frequence: FrequenceEngagement.quotidien,
  ),
  EngagementSpirituel(
    id: 'silence',
    titre: "Dix minutes de silence",
    description: "Sans téléphone, sans musique. Se taire pour écouter.",
    iconName: 'self_improvement',
    frequence: FrequenceEngagement.quotidien,
  ),
  EngagementSpirituel(
    id: 'messe',
    titre: "Messe dominicale",
    description: "Le rendez-vous de toute la communauté chrétienne.",
    iconName: 'church_outlined',
    frequence: FrequenceEngagement.hebdomadaire,
  ),
  EngagementSpirituel(
    id: 'jeune',
    titre: "Un jeûne hebdomadaire",
    description: "Le vendredi par tradition : un repas, un écran, une habitude.",
    iconName: 'no_food_outlined',
    frequence: FrequenceEngagement.hebdomadaire,
  ),
  EngagementSpirituel(
    id: 'adoration',
    titre: "Un temps d'adoration",
    description: "Une demi-heure devant le Saint-Sacrement, chaque semaine.",
    iconName: 'auto_awesome',
    frequence: FrequenceEngagement.hebdomadaire,
  ),
  EngagementSpirituel(
    id: 'service',
    titre: "Un geste de service",
    description: "Une visite, un coup de main, une aumône. Concret, pas théorique.",
    iconName: 'volunteer_activism',
    frequence: FrequenceEngagement.hebdomadaire,
  ),
  EngagementSpirituel(
    id: 'confession',
    titre: "Confession",
    description: "Se laisser relever régulièrement, sans attendre d'être au fond.",
    iconName: 'favorite_border',
    frequence: FrequenceEngagement.mensuel,
  ),
];

/// Retrouve un engagement par son identifiant. Renvoie null pour un
/// identifiant inconnu — une règle de vie enregistrée par une version
/// antérieure peut citer un engagement retiré du catalogue depuis.
EngagementSpirituel? engagementParId(String id) {
  for (final engagement in catalogueEngagements) {
    if (engagement.id == id) return engagement;
  }
  return null;
}
