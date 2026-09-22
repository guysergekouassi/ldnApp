/// Plans de lecture de la Bible livrés avec l'application.
///
/// Chaque jour porte une référence et un point d'attention, jamais le texte
/// biblique : il appartient au lecteur de l'ouvrir dans sa Bible. Les
/// découpages suivent la structure réelle des livres (Marc a bien 16
/// chapitres, Philippiens 4), pour qu'un plan se termine sur le dernier
/// verset et pas au milieu d'une phrase.
class JourLectureCatalogue {
  final int jour;
  final String reference;
  final String focus;

  const JourLectureCatalogue(this.jour, this.reference, this.focus);
}

class PlanLectureCatalogue {
  final String id;
  final String titre;
  final String sousTitre;
  final String description;
  final String imageAsset;
  final String couleurHex;
  final int ordre;
  final List<JourLectureCatalogue> jours;

  const PlanLectureCatalogue({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.description,
    required this.imageAsset,
    required this.couleurHex,
    required this.ordre,
    required this.jours,
  });
}

const List<PlanLectureCatalogue> plansDeLecture = [
  PlanLectureCatalogue(
    id: 'marc',
    titre: "L'Évangile de Marc",
    sousTitre: "Un chapitre par jour",
    description:
        "Le plus court des quatre évangiles, et le plus rapide : Marc raconte Jésus au pas de course, "
        "des rives du Jourdain au tombeau ouvert. Un chapitre par jour, seize jours pour le traverser en entier.",
    imageAsset: "assets/images/bible.png.jpg",
    couleurHex: "#C72127",
    ordre: 1,
    jours: [
      JourLectureCatalogue(1, "Marc 1", "Tout commence par un appel : « Venez à ma suite. » Qu'est-ce qui, chez toi, résiste encore à cet appel ?"),
      JourLectureCatalogue(2, "Marc 2", "Des amis descendent un paralysé par le toit. Qui portes-tu devant Dieu en ce moment ?"),
      JourLectureCatalogue(3, "Marc 3", "Jésus choisit les Douze. Il ne prend pas les plus qualifiés, mais ceux qu'il appelle."),
      JourLectureCatalogue(4, "Marc 4", "Quatre terrains pour une même semence. Lequel décrit ton cœur aujourd'hui ?"),
      JourLectureCatalogue(5, "Marc 5", "Trois personnes sans espoir, trois relèvements. Aucune situation n'est hors de portée."),
      JourLectureCatalogue(6, "Marc 6", "Cinq pains, deux poissons. Dieu part de ce que tu as, pas de ce qui te manque."),
      JourLectureCatalogue(7, "Marc 7", "La pureté ne vient pas des mains lavées mais du cœur. Qu'est-ce qui sort du tien ?"),
      JourLectureCatalogue(8, "Marc 8", "« Et vous, qui dites-vous que je suis ? » Réponds pour toi, pas pour les autres."),
      JourLectureCatalogue(9, "Marc 9", "« Je crois, viens au secours de mon manque de foi. » La prière la plus honnête de l'Évangile."),
      JourLectureCatalogue(10, "Marc 10", "L'homme riche s'en va tristement. Qu'est-ce que tu ne veux pas lâcher ?"),
      JourLectureCatalogue(11, "Marc 11", "Jésus entre à Jérusalem acclamé, et purifie le Temple. Que doit-il purifier chez toi ?"),
      JourLectureCatalogue(12, "Marc 12", "Le plus grand commandement, et l'obole de la veuve : Dieu regarde la mesure du don."),
      JourLectureCatalogue(13, "Marc 13", "« Veillez. » Vivre prêt, ce n'est pas vivre inquiet."),
      JourLectureCatalogue(14, "Marc 14", "Gethsémani : « non pas ce que je veux, mais ce que tu veux. » Peux-tu prier cela ?"),
      JourLectureCatalogue(15, "Marc 15", "La Croix. Reste devant, sans rien vouloir expliquer."),
      JourLectureCatalogue(16, "Marc 16", "Le tombeau est vide. L'histoire ne se termine pas, elle commence."),
    ],
  ),
  PlanLectureCatalogue(
    id: 'philippiens',
    titre: "La joie chrétienne",
    sousTitre: "L'épître aux Philippiens",
    description:
        "Paul écrit depuis sa prison, et parle de joie à presque chaque page. Sept jours pour découvrir "
        "une joie qui ne dépend pas des circonstances.",
    imageAsset: "assets/sunset_bg.jpg",
    couleurHex: "#E99D1A",
    ordre: 2,
    jours: [
      JourLectureCatalogue(1, "Philippiens 1, 1-11", "Paul rend grâce avant de demander quoi que ce soit. Pour qui peux-tu rendre grâce ce matin ?"),
      JourLectureCatalogue(2, "Philippiens 1, 12-30", "Enchaîné, Paul voit l'Évangile avancer. Où Dieu travaille-t-il malgré ce qui te bloque ?"),
      JourLectureCatalogue(3, "Philippiens 2, 1-11", "L'hymne du Christ qui s'abaisse. Descendre, chez Dieu, c'est la manière d'aimer."),
      JourLectureCatalogue(4, "Philippiens 2, 12-30", "« Faites tout sans murmures. » Un test très concret de la journée qui vient."),
      JourLectureCatalogue(5, "Philippiens 3, 1-16", "Paul tient tout pour rien au regard du Christ. Qu'est-ce qui pèse trop lourd dans ta balance ?"),
      JourLectureCatalogue(6, "Philippiens 3, 17 – 4, 1", "« Notre cité se trouve dans les cieux. » Vivre ici en gardant l'horizon."),
      JourLectureCatalogue(7, "Philippiens 4, 2-23", "« Ne soyez inquiets de rien. » Nomme une inquiétude et confie-la précisément."),
    ],
  ),
  PlanLectureCatalogue(
    id: 'psaumes_confiance',
    titre: "Psaumes de confiance",
    sousTitre: "21 jours avec les Psaumes",
    description:
        "Les Psaumes disent tout : la joie, la colère, la peur, l'abandon. Vingt et un psaumes choisis "
        "pour apprendre à prier avec des mots vrais, y compris les jours difficiles.",
    imageAsset: "assets/mountain_bg.png",
    couleurHex: "#5B4FC8",
    ordre: 3,
    jours: [
      JourLectureCatalogue(1, "Psaume 1", "Deux chemins, un seul enracinement. Où plonges-tu tes racines ?"),
      JourLectureCatalogue(2, "Psaume 8", "« Qu'est-ce que l'homme pour que tu penses à lui ? » La bonne mesure de soi."),
      JourLectureCatalogue(3, "Psaume 16", "« Tu es mon seul bien. » Ose le dire, même si tu n'en es pas encore là."),
      JourLectureCatalogue(4, "Psaume 18", "Un psaume de délivrance. Rappelle-toi une fois où tu as été relevé."),
      JourLectureCatalogue(5, "Psaume 22", "Le cri du Christ en croix. Dieu accueille aussi la plainte."),
      JourLectureCatalogue(6, "Psaume 23", "Le Seigneur est mon berger. Lis-le lentement, deux fois."),
      JourLectureCatalogue(7, "Psaume 27", "« Le Seigneur est ma lumière et mon salut, de qui aurais-je crainte ? »"),
      JourLectureCatalogue(8, "Psaume 34", "« Goûtez et voyez. » La foi se vérifie en la pratiquant."),
      JourLectureCatalogue(9, "Psaume 37", "Ne t'irrite pas contre les méchants. La patience est une forme de foi."),
      JourLectureCatalogue(10, "Psaume 40", "« J'espérais le Seigneur : il s'est penché vers moi. » L'attente n'est pas vide."),
      JourLectureCatalogue(11, "Psaume 42", "« Mon âme a soif de Dieu. » Nomme ta soif d'aujourd'hui."),
      JourLectureCatalogue(12, "Psaume 46", "« Arrêtez, et sachez que je suis Dieu. » Une consigne à prendre au mot."),
      JourLectureCatalogue(13, "Psaume 51", "Le psaume du pardon. Demande un cœur nouveau, pas seulement l'oubli."),
      JourLectureCatalogue(14, "Psaume 62", "« En Dieu seul le repos pour mon âme. » Où cherches-tu le repos, en vrai ?"),
      JourLectureCatalogue(15, "Psaume 63", "« Dès l'aube je te cherche. » Essaie, demain matin, avant le téléphone."),
      JourLectureCatalogue(16, "Psaume 84", "« Heureux les habitants de ta maison. » Le désir d'un lieu où Dieu demeure."),
      JourLectureCatalogue(17, "Psaume 91", "Un psaume de protection, à prier pour quelqu'un que tu portes."),
      JourLectureCatalogue(18, "Psaume 103", "« Bénis le Seigneur, ô mon âme, n'oublie aucun de ses bienfaits. » Fais la liste."),
      JourLectureCatalogue(19, "Psaume 121", "« Je lève les yeux vers les montagnes. » Le psaume de ceux qui sont en route."),
      JourLectureCatalogue(20, "Psaume 130", "« Des profondeurs je crie vers toi. » Prier depuis le fond, c'est déjà prier."),
      JourLectureCatalogue(21, "Psaume 139", "« Tu me scrutes et tu me connais. » Être connu jusqu'au bout, et aimé quand même."),
    ],
  ),
  PlanLectureCatalogue(
    id: 'actes',
    titre: "L'Église naissante",
    sousTitre: "Les Actes des Apôtres",
    description:
        "Comment une poignée de disciples effrayés est devenue une Église répandue dans tout l'empire. "
        "Quatorze étapes dans le livre de l'Esprit Saint à l'œuvre.",
    imageAsset: "assets/images/bible.png.jpg",
    couleurHex: "#16A34A",
    ordre: 4,
    jours: [
      JourLectureCatalogue(1, "Actes 1", "Avant la mission, l'attente et la prière. On ne s'envoie pas soi-même."),
      JourLectureCatalogue(2, "Actes 2", "La Pentecôte : l'Esprit fait parler, et fait comprendre."),
      JourLectureCatalogue(3, "Actes 3 – 4", "« De l'argent, je n'en ai pas ; mais ce que j'ai, je te le donne. » Que peux-tu donner ?"),
      JourLectureCatalogue(4, "Actes 5", "Vérité et mensonge dans la communauté naissante. L'Église n'est pas un décor."),
      JourLectureCatalogue(5, "Actes 6 – 7", "Étienne, le premier martyr, meurt en pardonnant. Le sang des témoins est une semence."),
      JourLectureCatalogue(6, "Actes 8", "Philippe et l'Éthiopien : « Comment le comprendrais-je si personne ne me guide ? »"),
      JourLectureCatalogue(7, "Actes 9", "Sur la route de Damas. Personne n'est trop loin pour être retourné."),
      JourLectureCatalogue(8, "Actes 10", "Pierre chez Corneille : Dieu est plus large que nos frontières."),
      JourLectureCatalogue(9, "Actes 11 – 12", "À Antioche, on les appelle « chrétiens » pour la première fois."),
      JourLectureCatalogue(10, "Actes 13", "Premier voyage missionnaire : l'Esprit envoie, la communauté confirme."),
      JourLectureCatalogue(11, "Actes 15", "Le concile de Jérusalem : l'Église décide ensemble, sans écraser personne."),
      JourLectureCatalogue(12, "Actes 16", "En prison, Paul et Silas chantent à minuit. La louange ouvre des portes."),
      JourLectureCatalogue(13, "Actes 17", "Paul à Athènes : parler la langue de ceux qui écoutent."),
      JourLectureCatalogue(14, "Actes 27 – 28", "Le naufrage, puis Rome. Rien n'arrête l'annonce, même pas le pire."),
    ],
  ),
];
