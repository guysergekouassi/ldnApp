/// Contenu des parcours et du chemin Métanoïa livrés avec l'application.
///
/// Les leçons semées par les premières versions ne contenaient qu'un texte
/// d'attente (« Contenu complet de la méditation… »). L'amorçage s'appuie
/// désormais sur ce catalogue : il remplace ces textes d'attente, complète ce
/// qui manque, et laisse intact tout contenu déjà rédigé depuis la console.
class LeconCatalogue {
  final int numero;
  final String titre;
  final String resume;
  final String contenu;

  const LeconCatalogue({
    required this.numero,
    required this.titre,
    required this.resume,
    required this.contenu,
  });
}

class ParcoursCatalogue {
  final String id;
  final String titre;
  final List<LeconCatalogue> lecons;

  const ParcoursCatalogue({required this.id, required this.titre, required this.lecons});
}

class NiveauMetanoiaCatalogue {
  final String id;
  final String titre;
  final String sousTitre;
  final int ordre;
  final String imageAsset;
  final List<LeconCatalogue> lecons;

  const NiveauMetanoiaCatalogue({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.ordre,
    required this.imageAsset,
    required this.lecons,
  });
}

/// Marqueur des textes d'attente à remplacer.
const String texteDAttenteParcours = 'Contenu complet de la méditation';

const List<ParcoursCatalogue> parcoursCatalogue = [
  // ───────────────────────── À l'écoute de Dieu ─────────────────────────
  ParcoursCatalogue(
    id: 'ecoute_dieu',
    titre: "À l'écoute de Dieu",
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "Le silence intérieur",
        resume: "Faire taire les bruits du monde.",
        contenu: "« Le Seigneur n'était pas dans l'ouragan… et après le feu, le murmure d'une brise légère. » — 1 Rois 19, 11-12\n\n"
            "Élie attendait Dieu dans le fracas. Il le trouve dans un souffle. Nos journées sont pleines de bruit : notifications, musique, conversations, pensées qui tournent. Ce n'est pas que Dieu se tait, c'est que nous n'avons plus d'espace pour l'entendre.\n\n"
            "Le silence n'est pas le vide. C'est faire de la place. Cinq minutes sans écran, sans musique, sans rien attendre de spectaculaire : simplement rester là, devant Lui, et respirer.\n\n"
            "Aujourd'hui : choisis un moment précis de ta journée et coupe ton téléphone pendant cinq minutes. Assieds-toi. Dis simplement : « Parle, Seigneur, ton serviteur écoute. »",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "La Parole",
        resume: "Écouter Dieu à travers la Bible.",
        contenu: "« Ta parole est une lampe à mes pieds, une lumière sur mon sentier. » — Psaume 119, 105\n\n"
            "Dieu ne parle pas d'abord par des impressions, mais par sa Parole. La Bible n'est pas un livre d'histoire à parcourir vite : c'est une lettre adressée à toi, aujourd'hui.\n\n"
            "Prends un passage court. Lis-le lentement, deux fois. Repère la phrase qui s'accroche à toi — celle qui te dérange ou te console. Reste dessus. C'est souvent là que Dieu parle.\n\n"
            "Aujourd'hui : lis l'Évangile du jour dans l'application, puis note dans ton carnet la seule phrase que tu veux emporter avec toi.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "Le discernement",
        resume: "Reconnaître la voix de l'Esprit Saint.",
        contenu: "« Mes brebis écoutent ma voix ; je les connais et elles me suivent. » — Jean 10, 27\n\n"
            "Beaucoup de voix parlent en nous : la peur, l'orgueil, l'habitude, le regard des autres. Comment reconnaître celle de Dieu ? À ses fruits. La voix de Dieu apaise même quand elle exige ; elle relève, elle ne condamne pas. La voix qui accuse, presse et écrase ne vient pas de Lui.\n\n"
            "Le discernement n'est pas un talent, c'est une habitude qui se prend. On apprend à reconnaître une voix en la fréquentant.\n\n"
            "Aujourd'hui : relis ta journée d'hier. Quel mouvement t'a rapproché de la paix ? Lequel t'en a éloigné ?",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "L'obéissance",
        resume: "Agir selon ce que l'on a entendu.",
        contenu: "« Faites tout ce qu'il vous dira. » — Jean 2, 5\n\n"
            "Écouter sans agir, c'est encore ne pas écouter. Marie, à Cana, ne discute pas : elle fait confiance et met les serviteurs en mouvement. L'obéissance chrétienne n'est pas une soumission triste, c'est la réponse d'un fils à un Père digne de confiance.\n\n"
            "Souvent, Dieu ne demande pas la grande décision que nous redoutons, mais le petit pas que nous repoussons : un appel à passer, un pardon à demander, une habitude à quitter.\n\n"
            "Aujourd'hui : identifie une chose, une seule, que tu sais devoir faire depuis longtemps. Fais-la avant ce soir.",
      ),
      LeconCatalogue(
        numero: 5,
        titre: "La persévérance",
        resume: "Demeurer à l'écoute chaque jour.",
        contenu: "« Demeurez en moi, comme moi en vous. » — Jean 15, 4\n\n"
            "Les jours d'enthousiasme ne durent pas ; c'est normal, et ce n'est pas un échec. La foi se construit dans les journées ordinaires, quand on revient s'asseoir alors qu'on ne ressent rien.\n\n"
            "Mieux vaut cinq minutes chaque jour qu'une heure une fois par mois. La fidélité des petites choses creuse en nous une capacité d'écoute que l'intensité ne donne jamais.\n\n"
            "Aujourd'hui : fixe l'heure et le lieu de ta prière pour les sept prochains jours, et règle un rappel dans l'application. Le lieu et l'heure font plus que la bonne volonté.",
      ),
    ],
  ),

  // ─────────────────────────── L'Esprit Saint ───────────────────────────
  ParcoursCatalogue(
    id: 'esprit_saint',
    titre: "L'Esprit Saint",
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "Qui est l'Esprit Saint ?",
        resume: "La troisième personne de la Trinité.",
        contenu: "« L'Esprit de Dieu planait sur les eaux. » — Genèse 1, 2\n\n"
            "L'Esprit Saint n'est ni une énergie, ni une ambiance : il est Dieu, une personne, présent dès la première page de la Bible et donné à ton baptême. On ne le voit pas plus qu'on ne voit le vent, mais on en voit les effets.\n\n"
            "Il est celui qui rend la foi vivante : sans lui, l'Évangile reste un texte et la prière un monologue.\n\n"
            "Aujourd'hui : dis-lui simplement, à voix haute, « Esprit Saint, je crois que tu habites en moi. Fais-toi connaître. » Puis reste une minute en silence.",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "Le Consolateur",
        resume: "Celui qui nous accompagne.",
        contenu: "« Je prierai le Père, et il vous donnera un autre Défenseur qui sera pour toujours avec vous. » — Jean 14, 16\n\n"
            "Le mot employé par Jésus signifie l'avocat, celui qu'on appelle à ses côtés. L'Esprit ne supprime pas l'épreuve : il se tient dedans avec toi. Consoler, ce n'est pas distraire, c'est être avec.\n\n"
            "Quand tu ne sais plus quoi dire à Dieu, c'est lui qui prie en toi : « L'Esprit vient au secours de notre faiblesse » (Romains 8, 26).\n\n"
            "Aujourd'hui : pense à une situation où tu te sens seul. Invite l'Esprit à y entrer, nommément, sans rien demander d'autre.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "Les dons de l'Esprit",
        resume: "Recevoir ses grâces.",
        contenu: "« Sagesse et intelligence, conseil et force, connaissance, piété et crainte du Seigneur. » — d'après Isaïe 11, 2-3\n\n"
            "Sept dons, reçus à la confirmation, qui ne sont pas des décorations mais des aptitudes : voir clair, décider juste, tenir bon, aimer vrai.\n\n"
            "Ils travaillent souvent sans bruit. Cette parole qui t'est venue au bon moment, ce courage inattendu, cette paix au milieu d'une décision difficile : c'est lui.\n\n"
            "Aujourd'hui : demande le don dont tu manques le plus en ce moment. Nomme-le. Dieu ne refuse pas l'Esprit à qui le demande (Luc 11, 13).",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "Les fruits de l'Esprit",
        resume: "Ce qu'il produit en nous.",
        contenu: "« Le fruit de l'Esprit est amour, joie, paix, patience, bonté, bienveillance, fidélité, douceur, maîtrise de soi. » — Galates 5, 22-23\n\n"
            "On ne juge pas un arbre à ses intentions mais à ses fruits. Ces neuf mots sont le test le plus honnête de notre vie spirituelle : une prière qui ne rend ni plus patient ni plus doux a manqué quelque chose.\n\n"
            "Le fruit met du temps. Il pousse sans qu'on le voie pousser.\n\n"
            "Aujourd'hui : relis la liste et demande à un proche lequel de ces fruits il voit le moins chez toi. Accueille la réponse sans te justifier.",
      ),
      LeconCatalogue(
        numero: 5,
        titre: "La Pentecôte",
        resume: "Être rempli de sa puissance.",
        contenu: "« Ils furent tous remplis d'Esprit Saint et se mirent à parler. » — Actes 2, 4\n\n"
            "Des hommes enfermés par peur sortent et parlent devant la foule. Rien n'a changé autour d'eux ; tout a changé en eux. La Pentecôte n'est pas un souvenir : c'est ce que l'Esprit veut faire encore.\n\n"
            "Il ne s'agit pas de vivre des choses extraordinaires, mais de vivre ordinairement avec une force qui ne vient pas de nous.\n\n"
            "Aujourd'hui : demande à l'Esprit une audace précise — parler à quelqu'un, pardonner, reprendre une démarche laissée de côté — et fais-la.",
      ),
    ],
  ),

  // ──────────────────────────── Suivre Jésus ────────────────────────────
  ParcoursCatalogue(
    id: 'suivre_jesus',
    titre: "Suivre Jésus",
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "Qui est Jésus ?",
        resume: "Le fondement de notre foi.",
        contenu: "« Et vous, que dites-vous ? Pour vous, qui suis-je ? » — Matthieu 16, 15\n\n"
            "La question n'est pas ce que les autres pensent de Jésus, mais qui il est pour toi. Un sage parmi d'autres ? Un souvenir d'enfance ? Ou le Fils de Dieu, vivant aujourd'hui ?\n\n"
            "Le christianisme ne commence pas par une morale ni par une organisation, mais par une rencontre avec quelqu'un.\n\n"
            "Aujourd'hui : réponds à sa question par écrit, en une phrase, avec tes mots à toi. Garde cette phrase, tu y reviendras à la fin du parcours.",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "La Croix",
        resume: "Le pardon et le salut.",
        contenu: "« Il n'y a pas de plus grand amour que de donner sa vie pour ceux qu'on aime. » — Jean 15, 13\n\n"
            "La croix n'est pas un accident de parcours ni une punition divine : c'est la mesure d'un amour qui va jusqu'au bout. Ce que tu n'oses pas raconter à personne, il l'a déjà porté.\n\n"
            "Regarder la croix, c'est cesser d'essayer de mériter ce qui est donné gratuitement.\n\n"
            "Aujourd'hui : dépose devant lui une chose dont tu as honte. Dis-la simplement, sans tourner autour. Puis reste en silence et laisse-toi regarder.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "La Résurrection",
        resume: "Une vie nouvelle.",
        contenu: "« Pourquoi cherchez-vous le Vivant parmi les morts ? » — Luc 24, 5\n\n"
            "Si le Christ n'est pas ressuscité, notre foi est vide (1 Corinthiens 15, 14). Tout tient à ce matin-là. La Résurrection dit que la mort, l'échec et le péché n'ont pas le dernier mot — ni dans l'histoire, ni dans ta vie.\n\n"
            "Il y a en toi des situations que tu crois définitivement mortes. Il est le Vivant, aussi pour celles-là.\n\n"
            "Aujourd'hui : nomme une situation où tu as cessé d'espérer. Confie-la au Ressuscité, et demande un signe de vie, même petit.",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "La Prière",
        resume: "Parler avec son Père.",
        contenu: "« Quand tu pries, retire-toi dans ta chambre, ferme la porte, et prie ton Père. » — Matthieu 6, 6\n\n"
            "Prier n'est pas réciter, c'est parler et écouter. Dieu ne demande pas de belles formules : il demande la vérité. Dis-lui ce qui est, y compris ta fatigue et ton doute.\n\n"
            "Quatre mouvements suffisent : merci, pardon, s'il te plaît, me voici.\n\n"
            "Aujourd'hui : prie ces quatre mots, l'un après l'autre, en prenant une minute pour chacun.",
      ),
      LeconCatalogue(
        numero: 5,
        titre: "La Bible",
        resume: "Nourriture quotidienne.",
        contenu: "« L'homme ne vit pas seulement de pain, mais de toute parole qui sort de la bouche de Dieu. » — Matthieu 4, 4\n\n"
            "On ne mange pas une fois pour toute la semaine. La Parole se prend chaque jour, en petite quantité, régulièrement. Mieux vaut dix versets médités que trois chapitres survolés.\n\n"
            "Commence par un Évangile — Marc est le plus court — et lis-le du début à la fin, quelques versets par jour.\n\n"
            "Aujourd'hui : ouvre l'Évangile du jour et souligne un mot. Reviens-y ce soir avant de dormir.",
      ),
      LeconCatalogue(
        numero: 6,
        titre: "L'Église",
        resume: "La famille de Dieu.",
        contenu: "« Là où deux ou trois sont réunis en mon nom, je suis au milieu d'eux. » — Matthieu 18, 20\n\n"
            "On ne suit pas Jésus seul. L'Église n'est pas un bâtiment ni une administration : c'est un corps dont tu es un membre, avec ses blessures et ses saints.\n\n"
            "Une braise sortie du feu s'éteint en quelques minutes. La communauté n'est pas un supplément à la foi : elle la garde vivante.\n\n"
            "Aujourd'hui : contacte une personne de ta communauté que tu n'as pas vue depuis longtemps. Un message suffit.",
      ),
      LeconCatalogue(
        numero: 7,
        titre: "Le Témoignage",
        resume: "Partager sa foi.",
        contenu: "« Vous serez mes témoins… jusqu'aux extrémités de la terre. » — Actes 1, 8\n\n"
            "Témoigner n'est pas convaincre ni faire la leçon : c'est raconter ce qu'on a vu et reçu. Personne ne peut contester ton histoire.\n\n"
            "Le premier témoignage est une manière d'être : la façon dont tu écoutes, dont tu pardonnes, dont tu tiens parole. Les mots viennent après, quand on te les demande.\n\n"
            "Aujourd'hui : relis la phrase écrite au premier jour. Qu'est-ce qui a bougé ? Raconte-le à quelqu'un cette semaine.",
      ),
    ],
  ),
];

/// Le chemin Métanoïa : trois niveaux de quatre leçons. Aucun amorçage
/// n'existait pour ce contenu, ce qui laissait l'écran Métanoïa et la carte
/// « Continuer mon parcours » vides.
const List<NiveauMetanoiaCatalogue> metanoiaCatalogue = [
  NiveauMetanoiaCatalogue(
    id: 'metanoia_niveau_1',
    titre: "Métanoia - Niveau 1",
    sousTitre: "Se tourner vers Dieu",
    ordre: 1,
    imageAsset: 'assets/mountain_bg.png',
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "Qu'est-ce que la métanoïa ?",
        resume: "Bien plus qu'un regret.",
        contenu: "« Convertissez-vous, car le royaume des Cieux est tout proche. » — Matthieu 4, 17\n\n"
            "Le mot grec metanoia signifie littéralement « changer d'esprit », retourner sa manière de voir. Ce n'est pas se flageller sur ses fautes : c'est se tourner vers quelqu'un.\n\n"
            "La conversion n'est pas un effort qui nous rendrait aimables ; c'est une réponse à un amour déjà là. On ne se convertit pas pour être aimé, on se convertit parce qu'on l'est.\n\n"
            "Aujourd'hui : demande-toi vers quoi ton cœur est spontanément tourné le matin au réveil. C'est là qu'il faut opérer le retournement.",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "Reconnaître ce qui pèse",
        resume: "Nommer, sans se condamner.",
        contenu: "« Si nous disons que nous n'avons pas de péché, nous nous égarons nous-mêmes. » — 1 Jean 1, 8\n\n"
            "On ne guérit pas ce qu'on refuse de nommer. Mettre un nom sur ce qui nous alourdit — une habitude, une rancune, une lâcheté — n'est pas de la culpabilité, c'est de la lucidité.\n\n"
            "La différence est simple : la culpabilité tourne autour de moi et m'écrase ; la lucidité me met en marche vers Dieu.\n\n"
            "Aujourd'hui : écris trois choses qui pèsent sur ta conscience. Ne les commente pas. Écris-les, c'est tout.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "Le regard du Père",
        resume: "Comment Dieu te regarde vraiment.",
        contenu: "« Comme il était encore loin, son père l'aperçut et fut saisi de compassion ; il courut se jeter à son cou. » — Luc 15, 20\n\n"
            "Le fils prodigue avait préparé un discours. Le père ne le laisse pas le finir. Beaucoup vivent avec l'image d'un Dieu comptable, qui attend l'erreur. L'Évangile montre un Père qui court.\n\n"
            "Tant que ce regard n'a pas changé en nous, la conversion reste une corvée.\n\n"
            "Aujourd'hui : relis Luc 15, 11-24 lentement, en te mettant à la place du fils qui revient.",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "Le premier pas",
        resume: "Passer de l'intention à l'acte.",
        contenu: "« Il se leva et alla vers son père. » — Luc 15, 20\n\n"
            "Entre le désir de changer et le changement, il y a un pas concret, toujours petit et souvent inconfortable. Le fils prodigue ne s'est pas transformé : il s'est levé et il a marché.\n\n"
            "Choisir un seul pas vaut mieux que promettre une vie nouvelle. Ce qui est trop grand ne se fait jamais.\n\n"
            "Aujourd'hui : parmi les trois choses écrites au jour 2, choisis-en une et pose le premier geste — une confession à préparer, un message à envoyer, une chose à rendre.",
      ),
    ],
  ),
  NiveauMetanoiaCatalogue(
    id: 'metanoia_niveau_2',
    titre: "Métanoia - Niveau 2",
    sousTitre: "Vivre du pardon",
    ordre: 2,
    imageAsset: 'assets/sunset_bg.jpg',
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "Recevoir le pardon",
        resume: "Le sacrement de la réconciliation.",
        contenu: "« Si nous reconnaissons nos péchés, il est fidèle et juste : il pardonne. » — 1 Jean 1, 9\n\n"
            "Dire ses fautes à voix haute, devant un prêtre, coûte — et c'est précisément pourquoi cela libère. Ce qui reste dans la tête tourne en rond ; ce qui est dit est déposé.\n\n"
            "Le pardon n'est pas mérité par la qualité de notre contrition : il est donné.\n\n"
            "Aujourd'hui : utilise la préparation à la confession de l'application et fixe une date. Une date précise, pas « bientôt ».",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "Pardonner à son tour",
        resume: "Le passage le plus difficile.",
        contenu: "« Pardonne-nous nos offenses, comme nous pardonnons aussi à ceux qui nous ont offensés. » — Matthieu 6, 12\n\n"
            "Pardonner n'est pas dire que ce n'était pas grave, ni se remettre en danger. C'est renoncer à faire payer. C'est souvent l'affaire de plusieurs années, et cela commence par une décision, pas par un sentiment.\n\n"
            "Tant que nous gardons une dette contre quelqu'un, nous restons attachés à lui par cette dette.\n\n"
            "Aujourd'hui : nomme une personne que tu n'as pas pardonnée. Demande la grâce de le vouloir — c'est déjà un immense pas.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "Se recevoir de Dieu",
        resume: "Faire la paix avec soi-même.",
        contenu: "« Tu as du prix à mes yeux et je t'aime. » — Isaïe 43, 4\n\n"
            "Certains pardonnent aux autres mais se condamnent eux-mêmes sans relâche. Refuser le pardon reçu, c'est encore prétendre en être le juge.\n\n"
            "Se recevoir de Dieu, c'est accepter d'être aimé avant d'être irréprochable.\n\n"
            "Aujourd'hui : écris la phrase d'Isaïe à la première personne, avec ton prénom, et relis-la trois fois dans la journée.",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "Des habitudes nouvelles",
        resume: "Ce qui tient dans la durée.",
        contenu: "« Ne vous conformez pas au monde présent, mais soyez transformés par le renouvellement de votre intelligence. » — Romains 12, 2\n\n"
            "Une conversion qui ne change rien à l'emploi du temps ne dure pas. Nos habitudes disent ce que nous croyons vraiment.\n\n"
            "Change une seule habitude à la fois, et donne-lui une place fixe dans la journée.\n\n"
            "Aujourd'hui : choisis une habitude à retirer et une à ajouter. Écris-les dans ton carnet spirituel, avec l'heure et le lieu de la nouvelle.",
      ),
    ],
  ),
  NiveauMetanoiaCatalogue(
    id: 'metanoia_niveau_3',
    titre: "Métanoia - Niveau 3",
    sousTitre: "Porter du fruit",
    ordre: 3,
    imageAsset: 'assets/mountain_bg.png',
    lecons: [
      LeconCatalogue(
        numero: 1,
        titre: "La prière fidèle",
        resume: "Tenir dans la durée.",
        contenu: "« Priez sans cesse. » — 1 Thessaloniciens 5, 17\n\n"
            "La fidélité vaut mieux que l'intensité. Une prière courte, tenue chaque jour, transforme davantage qu'un élan qui s'éteint au bout d'une semaine.\n\n"
            "Les jours de sécheresse font partie du chemin : y rester fidèle est déjà une prière.\n\n"
            "Aujourd'hui : vérifie tes rappels de prière dans l'application et ajuste-les à ta vraie journée, pas à celle que tu voudrais avoir.",
      ),
      LeconCatalogue(
        numero: 2,
        titre: "Le service concret",
        resume: "La foi se voit aux mains.",
        contenu: "« La foi, si elle n'a pas les œuvres, est morte. » — Jacques 2, 17\n\n"
            "La conversion descend du cœur jusqu'aux mains, ou elle reste une idée. Servir n'est pas une activité en plus : c'est le lieu où la foi devient vraie.\n\n"
            "Commence petit et régulier, plutôt que grand et occasionnel.\n\n"
            "Aujourd'hui : repère une personne de ton entourage qui a besoin d'aide et rends-lui un service précis cette semaine, sans le raconter.",
      ),
      LeconCatalogue(
        numero: 3,
        titre: "La communauté",
        resume: "Marcher avec d'autres.",
        contenu: "« Ils étaient assidus à l'enseignement des Apôtres et à la communion fraternelle. » — Actes 2, 42\n\n"
            "Les premiers chrétiens ne tenaient pas seuls. La communauté nous corrige, nous porte et nous empêche de nous raconter des histoires sur nous-mêmes.\n\n"
            "Elle est aussi imparfaite que nous : c'est la condition, pas l'objection.\n\n"
            "Aujourd'hui : rejoins ou relance un groupe — une fratrie, un temps de prière, un service paroissial. Fixe la première date.",
      ),
      LeconCatalogue(
        numero: 4,
        titre: "Témoigner sans bruit",
        resume: "Devenir une lumière.",
        contenu: "« Que votre lumière brille devant les hommes. » — Matthieu 5, 16\n\n"
            "Au terme du chemin, la question n'est pas « qu'ai-je accompli ? » mais « qui suis-je devenu ? ». Le fruit d'une conversion se voit rarement dans les discours ; il se voit dans la patience, la justesse, la joie tenace.\n\n"
            "On ne devient pas lumière en éclairant plus fort, mais en restant branché à la source.\n\n"
            "Aujourd'hui : relis ton chemin depuis le premier jour. Rends grâce pour un changement réel, même minuscule, et confie à Dieu ce qui n'a pas encore bougé.",
      ),
    ],
  ),
];
