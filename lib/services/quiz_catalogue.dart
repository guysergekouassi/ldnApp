/// Catalogue des quiz livrés avec l'application.
///
/// Chaque quiz porte un identifiant stable : l'amorçage ne recrée que les
/// documents absents de Firestore, il peut donc être rejoué sans produire de
/// doublons, et il complète les catégories restées vides sans toucher aux quiz
/// déjà présents en base.
class QuestionCatalogue {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuestionCatalogue(this.question, this.options, this.correctIndex);
}

class QuizCatalogue {
  final String id;
  final String title;
  final String category;
  final String level;
  final int points;
  final int order;
  final List<QuestionCatalogue> questions;

  const QuizCatalogue({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.points,
    required this.order,
    required this.questions,
  });
}

/// Trois quiz par catégorie — Débutant, Intermédiaire, Expert — pour qu'aucune
/// catégorie n'ouvre sur un écran vide.
const List<QuizCatalogue> quizCatalogue = [
  // ─────────────────────────────── Bible ───────────────────────────────
  QuizCatalogue(
    id: 'bible_evangiles_debutant',
    title: "Les Évangiles",
    category: 'Bible',
    level: 'Débutant',
    points: 100,
    order: 1,
    questions: [
      QuestionCatalogue(
        "Combien y a-t-il d'évangiles dans le Nouveau Testament ?",
        ["Deux", "Quatre", "Sept", "Douze"],
        1,
      ),
      QuestionCatalogue(
        "Quel évangéliste est traditionnellement représenté par un lion ?",
        ["Matthieu", "Marc", "Luc", "Jean"],
        1,
      ),
      QuestionCatalogue(
        "Dans quel évangile trouve-t-on la parabole du Bon Samaritain ?",
        ["Matthieu", "Marc", "Luc", "Jean"],
        2,
      ),
      QuestionCatalogue(
        "Où Jésus est-il né selon les évangiles ?",
        ["Nazareth", "Bethléem", "Jérusalem", "Capharnaüm"],
        1,
      ),
      QuestionCatalogue(
        "Quel évangile commence par « Au commencement était le Verbe » ?",
        ["Matthieu", "Marc", "Luc", "Jean"],
        3,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'bible_ancien_testament_intermediaire',
    title: "L'Ancien Testament",
    category: 'Bible',
    level: 'Intermédiaire',
    points: 150,
    order: 2,
    questions: [
      QuestionCatalogue(
        "Quel est le premier livre de la Bible ?",
        ["La Genèse", "L'Exode", "Le Lévitique", "Josué"],
        0,
      ),
      QuestionCatalogue(
        "Qui conduit le peuple hébreu hors d'Égypte ?",
        ["Abraham", "Moïse", "David", "Élie"],
        1,
      ),
      QuestionCatalogue(
        "Combien de commandements Dieu donne-t-il à Moïse au Sinaï ?",
        ["Cinq", "Sept", "Dix", "Douze"],
        2,
      ),
      QuestionCatalogue(
        "Quel prophète est emporté au ciel sur un char de feu ?",
        ["Élie", "Élisée", "Isaïe", "Jérémie"],
        0,
      ),
      QuestionCatalogue(
        "Quel fils Abraham accepte-t-il d'offrir en sacrifice ?",
        ["Ismaël", "Isaac", "Jacob", "Joseph"],
        1,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'bible_paul_actes_expert',
    title: "Saint Paul et les Actes",
    category: 'Bible',
    level: 'Expert',
    points: 200,
    order: 3,
    questions: [
      QuestionCatalogue(
        "Sur la route de quelle ville Saul est-il terrassé par une lumière ?",
        ["Jéricho", "Damas", "Emmaüs", "Antioche"],
        1,
      ),
      QuestionCatalogue(
        "Quel compagnon de Paul est l'auteur traditionnel des Actes des Apôtres ?",
        ["Barnabé", "Timothée", "Luc", "Silas"],
        2,
      ),
      QuestionCatalogue(
        "Dans quelle ville Paul discute-t-il avec les philosophes à l'Aréopage ?",
        ["Athènes", "Corinthe", "Éphèse", "Rome"],
        0,
      ),
      QuestionCatalogue(
        "Quel événement est raconté au chapitre 2 des Actes des Apôtres ?",
        ["L'Ascension", "La Pentecôte", "La Transfiguration", "Le concile de Jérusalem"],
        1,
      ),
      QuestionCatalogue(
        "À quelle communauté Paul adresse-t-il l'hymne à la charité ?",
        ["Aux Romains", "Aux Corinthiens", "Aux Galates", "Aux Philippiens"],
        1,
      ),
    ],
  ),

  // ───────────────────────────── Catéchisme ─────────────────────────────
  QuizCatalogue(
    id: 'catechisme_sacrements_debutant',
    title: "Les sacrements",
    category: 'Catéchisme',
    level: 'Débutant',
    points: 100,
    order: 1,
    questions: [
      QuestionCatalogue(
        "Combien y a-t-il de sacrements dans l'Église catholique ?",
        ["Trois", "Cinq", "Sept", "Dix"],
        2,
      ),
      QuestionCatalogue(
        "Quel sacrement fait entrer dans l'Église ?",
        ["Le baptême", "La confirmation", "L'eucharistie", "Le mariage"],
        0,
      ),
      QuestionCatalogue(
        "Quel sacrement achève l'initiation chrétienne en donnant la force de l'Esprit Saint ?",
        ["L'eucharistie", "La confirmation", "L'onction des malades", "L'ordre"],
        1,
      ),
      QuestionCatalogue(
        "Comment appelle-t-on le sacrement du pardon ?",
        ["L'eucharistie", "Le baptême", "La réconciliation", "Le mariage"],
        2,
      ),
      QuestionCatalogue(
        "Quel sacrement les prêtres reçoivent-ils ?",
        ["Le mariage", "La confirmation", "L'onction des malades", "L'ordre"],
        3,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'catechisme_credo_intermediaire',
    title: "Le Credo",
    category: 'Catéchisme',
    level: 'Intermédiaire',
    points: 150,
    order: 2,
    questions: [
      QuestionCatalogue(
        "Combien de personnes y a-t-il en Dieu selon le Credo ?",
        ["Une", "Trois", "Sept", "Douze"],
        1,
      ),
      QuestionCatalogue(
        "Sous quel gouverneur romain Jésus a-t-il souffert selon le Credo ?",
        ["Ponce Pilate", "Hérode", "César Auguste", "Caïphe"],
        0,
      ),
      QuestionCatalogue(
        "Quel concile a fixé le Credo récité le dimanche ?",
        ["Le concile de Trente", "Nicée-Constantinople", "Vatican II", "Le concile du Latran"],
        1,
      ),
      QuestionCatalogue(
        "Que signifie le mot « catholique » dans le Credo ?",
        ["Romaine", "Ancienne", "Universelle", "Invisible"],
        2,
      ),
      QuestionCatalogue(
        "Par quelle affirmation le Credo des Apôtres se termine-t-il ?",
        [
          "La résurrection de la chair et la vie éternelle",
          "La communion des saints",
          "Le pardon des péchés",
          "La sainte Église catholique",
        ],
        0,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'catechisme_commandements_expert',
    title: "Commandements et grâce",
    category: 'Catéchisme',
    level: 'Expert',
    points: 200,
    order: 3,
    questions: [
      QuestionCatalogue(
        "Combien de commandements compte le Décalogue ?",
        ["Sept", "Dix", "Douze", "Quatorze"],
        1,
      ),
      QuestionCatalogue(
        "Quelles sont les trois vertus théologales ?",
        [
          "Foi, espérance et charité",
          "Prudence, justice et force",
          "Pauvreté, chasteté et obéissance",
          "Sagesse, conseil et piété",
        ],
        0,
      ),
      QuestionCatalogue(
        "Combien de dons du Saint-Esprit l'Église énumère-t-elle ?",
        ["Trois", "Cinq", "Sept", "Douze"],
        2,
      ),
      QuestionCatalogue(
        "Comment appelle-t-on la grâce reçue au baptême, qui fait participer à la vie divine ?",
        ["La grâce actuelle", "La grâce sanctifiante", "L'indulgence", "Le mérite"],
        1,
      ),
      QuestionCatalogue(
        "Quel est le plus grand commandement selon Jésus ?",
        [
          "Observer le sabbat",
          "Honorer son père et sa mère",
          "Aimer Dieu de tout son cœur et son prochain comme soi-même",
          "Ne pas se faire d'idoles",
        ],
        2,
      ),
    ],
  ),

  // ─────────────────────────────── Saints ───────────────────────────────
  QuizCatalogue(
    id: 'saints_patrons_debutant',
    title: "Les saints patrons",
    category: 'Saints',
    level: 'Débutant',
    points: 100,
    order: 1,
    questions: [
      QuestionCatalogue(
        "Quel saint est invoqué comme patron des voyageurs ?",
        ["Saint Antoine", "Saint Christophe", "Saint Joseph", "Saint Michel"],
        1,
      ),
      QuestionCatalogue(
        "Quel saint est le patron des animaux et de l'écologie ?",
        ["Saint François d'Assise", "Saint Dominique", "Saint Benoît", "Saint Ignace"],
        0,
      ),
      QuestionCatalogue(
        "Qui est le patron de l'Église universelle, époux de la Vierge Marie ?",
        ["Saint Pierre", "Saint Jean", "Saint Joseph", "Saint Paul"],
        2,
      ),
      QuestionCatalogue(
        "Quel archange est invoqué comme protecteur dans le combat contre le mal ?",
        ["Gabriel", "Raphaël", "Uriel", "Michel"],
        3,
      ),
      QuestionCatalogue(
        "Sainte Thérèse de l'Enfant-Jésus est patronne de quoi ?",
        ["Des malades", "Des missions", "Des étudiants", "Des musiciens"],
        1,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'saints_afrique_europe_intermediaire',
    title: "Saints d'Afrique et d'Europe",
    category: 'Saints',
    level: 'Intermédiaire',
    points: 150,
    order: 2,
    questions: [
      QuestionCatalogue(
        "Saint Augustin est né sur le territoire de quel pays actuel ?",
        ["L'Égypte", "L'Algérie", "L'Italie", "La Tunisie"],
        1,
      ),
      QuestionCatalogue(
        "Qui conduisit les martyrs de l'Ouganda, canonisés en 1964 ?",
        ["Charles Lwanga", "Isidore Bakanja", "Cyprien de Carthage", "Josaphat Kuncevyc"],
        0,
      ),
      QuestionCatalogue(
        "De quel pays sainte Joséphine Bakhita était-elle originaire ?",
        ["Le Nigéria", "Le Kenya", "Le Soudan", "Le Sénégal"],
        2,
      ),
      QuestionCatalogue(
        "Quelle sainte française conduisit les armées à la délivrance d'Orléans ?",
        ["Jeanne d'Arc", "Bernadette Soubirous", "Geneviève", "Clotilde"],
        0,
      ),
      QuestionCatalogue(
        "Saint Vincent de Paul a consacré sa vie au service :",
        ["Des rois", "Des pauvres", "Des savants", "Des soldats"],
        1,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'saints_docteurs_expert',
    title: "Les docteurs de l'Église",
    category: 'Saints',
    level: 'Expert',
    points: 200,
    order: 3,
    questions: [
      QuestionCatalogue(
        "Combien de femmes ont été proclamées docteurs de l'Église ?",
        ["Deux", "Quatre", "Six", "Dix"],
        1,
      ),
      QuestionCatalogue(
        "Quel docteur de l'Église a écrit la « Somme théologique » ?",
        ["Saint Bonaventure", "Saint Anselme", "Saint Thomas d'Aquin", "Saint Albert le Grand"],
        2,
      ),
      QuestionCatalogue(
        "Qui a traduit la Bible en latin, dans la version dite Vulgate ?",
        ["Saint Jérôme", "Saint Augustin", "Saint Ambroise", "Saint Grégoire"],
        0,
      ),
      QuestionCatalogue(
        "Quel ordre sainte Thérèse d'Avila a-t-elle réformé ?",
        ["Les Dominicains", "Le Carmel", "Les Franciscains", "Les Bénédictins"],
        1,
      ),
      QuestionCatalogue(
        "Quel évêque de Milan a baptisé saint Augustin ?",
        ["Saint Grégoire", "Saint Basile", "Saint Athanase", "Saint Ambroise"],
        3,
      ),
    ],
  ),

  // ───────────────────────── Vie chrétienne ─────────────────────────────
  QuizCatalogue(
    id: 'vie_priere_debutant',
    title: "La prière au quotidien",
    category: 'Vie chrétienne',
    level: 'Débutant',
    points: 100,
    order: 1,
    questions: [
      QuestionCatalogue(
        "Comment appelle-t-on la prière que Jésus a enseignée à ses disciples ?",
        ["Le Notre Père", "Le Je vous salue Marie", "Le Gloire au Père", "Le Credo"],
        0,
      ),
      QuestionCatalogue(
        "Combien de dizaines compte un chapelet ?",
        ["Trois", "Cinq", "Dix", "Quinze"],
        1,
      ),
      QuestionCatalogue(
        "Quels mystères du Rosaire médite-t-on le jeudi ?",
        ["Les mystères joyeux", "Les mystères douloureux", "Les mystères lumineux", "Les mystères glorieux"],
        2,
      ),
      QuestionCatalogue(
        "Comment appelle-t-on la prière de l'Église rythmée par les heures du jour ?",
        ["Le chapelet", "La liturgie des heures", "L'adoration", "La neuvaine"],
        1,
      ),
      QuestionCatalogue(
        "Quel jour les chrétiens célèbrent-ils la résurrection du Christ ?",
        ["Le vendredi", "Le samedi", "Le lundi", "Le dimanche"],
        3,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'vie_disciple_intermediaire',
    title: "Vivre en disciple",
    category: 'Vie chrétienne',
    level: 'Intermédiaire',
    points: 150,
    order: 2,
    questions: [
      QuestionCatalogue(
        "Laquelle de ces actions est une œuvre de miséricorde corporelle ?",
        ["Conseiller ceux qui doutent", "Consoler les affligés", "Visiter les prisonniers", "Pardonner les offenses"],
        2,
      ),
      QuestionCatalogue(
        "Que marque le mercredi des Cendres ?",
        ["L'entrée en Carême", "La fin du Carême", "Le début de l'Avent", "La Pentecôte"],
        0,
      ),
      QuestionCatalogue(
        "Combien de jours dure le Carême ?",
        ["Trente", "Quarante", "Cinquante", "Soixante"],
        1,
      ),
      QuestionCatalogue(
        "Quelles sont les trois pratiques du Carême proposées par l'Évangile ?",
        [
          "Le silence, le chant et la lecture",
          "La confession, la messe et le chapelet",
          "La prière, le jeûne et l'aumône",
          "Le pèlerinage, la veille et l'offrande",
        ],
        2,
      ),
      QuestionCatalogue(
        "Que signifie le mot « métanoïa » ?",
        ["La contemplation", "La conversion du cœur", "La louange", "L'obéissance"],
        1,
      ),
    ],
  ),
  QuizCatalogue(
    id: 'vie_charite_expert',
    title: "Charité et doctrine sociale",
    category: 'Vie chrétienne',
    level: 'Expert',
    points: 200,
    order: 3,
    questions: [
      QuestionCatalogue(
        "Quelle encyclique de Léon XIII fonde la doctrine sociale de l'Église en 1891 ?",
        ["Rerum Novarum", "Quadragesimo Anno", "Populorum Progressio", "Centesimus Annus"],
        0,
      ),
      QuestionCatalogue(
        "Quel principe demande que les décisions soient prises au plus près des personnes concernées ?",
        ["La solidarité", "La subsidiarité", "La gratuité", "La sobriété"],
        1,
      ),
      QuestionCatalogue(
        "Quelle encyclique du pape François porte sur la sauvegarde de la maison commune ?",
        ["Lumen Fidei", "Evangelii Gaudium", "Laudato Si'", "Fratelli Tutti"],
        2,
      ),
      QuestionCatalogue(
        "Sur quoi repose toute la doctrine sociale de l'Église ?",
        [
          "La dignité de la personne humaine",
          "La prospérité des nations",
          "L'autorité des États",
          "La croissance économique",
        ],
        0,
      ),
      QuestionCatalogue(
        "Que demande le principe de la destination universelle des biens ?",
        [
          "Que les biens soient partagés également par la loi",
          "Que les biens de la création servent à tous",
          "Que la propriété privée soit supprimée",
          "Que les richesses reviennent à l'Église",
        ],
        1,
      ),
    ],
  ),
];
