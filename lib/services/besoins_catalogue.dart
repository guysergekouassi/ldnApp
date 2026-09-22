/// Besoins traités dans « Aller plus loin ».
///
/// Chaque besoin est livré avec ce que l'application sait réellement offrir :
/// une demande d'écoute, un groupe, la confession, une intention à déposer.
/// **Aucun numéro ni adresse extérieure n'est inventé ici** — les coordonnées
/// dépendent du pays, et une ligne d'écoute erronée affichée à quelqu'un en
/// détresse ferait plus de mal que pas de ligne du tout. L'équipe LDN les
/// ajoute depuis la console Firestore, dans le tableau `ressources`.
const List<Map<String, dynamic>> catalogueBesoins = [
  {
    'id': 'deuil',
    'titre': "Je traverse un deuil",
    'resume': "La perte d'un proche, et le temps qui ne console pas tout seul.",
    'iconName': 'favorite_border',
    'couleurHex': '#5B4FC8',
    'ordre': 1,
    'quoiSavoir':
        "Le deuil n'a pas de durée normale, et il ne se traverse pas en ligne droite : "
        "des jours calmes peuvent succéder à des jours très durs, puis revenir. "
        "Pleurer, être en colère, ne plus avoir envie de prier — rien de tout cela n'est un manque de foi.",
    'premiersPas': [
      "Dis-le à quelqu'un, même en une phrase. Le silence pèse plus lourd que les mots.",
      "Garde un rythme minimal : dormir, manger, sortir un peu.",
      "Confie ton défunt dans la prière, sans t'obliger à ressentir quoi que ce soit.",
    ],
    'ressources': [
      {
        'libelle': "Demander une écoute",
        'detail': "Parler à quelqu'un de l'équipe, une fois, sans engagement.",
        'type': 'interne',
        'cible': 'ecoute',
      },
      {
        'libelle': "Déposer une intention",
        'detail': "La communauté portera ton défunt et toi dans la prière.",
        'type': 'interne',
        'cible': 'intention',
      },
    ],
  },
  {
    'id': 'solitude',
    'titre': "Je me sens seul(e)",
    'resume': "Personne à qui parler, ou l'impression de ne compter pour personne.",
    'iconName': 'person_outline',
    'couleurHex': '#16A34A',
    'ordre': 2,
    'quoiSavoir':
        "La solitude n'est pas un défaut de caractère, et elle ne se règle pas par la seule volonté. "
        "Elle se desserre par de petits contacts répétés, plus sûrement que par une grande rencontre espérée.",
    'premiersPas': [
      "Choisis un rendez-vous par semaine, même court, et tiens-le.",
      "Rejoins un groupe : on y entre sans avoir à se justifier.",
      "Rends un service à quelqu'un : c'est souvent par là que le lien revient.",
    ],
    'ressources': [
      {
        'libelle': "Rejoindre un groupe",
        'detail': "Fratrie de quartier, groupe de prière, ou groupe en ligne.",
        'type': 'interne',
        'cible': 'groupe',
      },
      {
        'libelle': "Demander une écoute",
        'detail': "Un premier contact, pour ne plus porter ça seul.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
  {
    'id': 'detresse',
    'titre': "Je vais mal, j'ai des idées noires",
    'resume': "Angoisse, épuisement, envie que tout s'arrête.",
    'iconName': 'healing',
    'couleurHex': '#C72127',
    'ordre': 3,
    'quoiSavoir':
        "Ce que tu ressens est un signal, pas une faute. La souffrance psychique se soigne, "
        "comme une blessure physique, et demander de l'aide est un acte de courage — pas un aveu d'échec. "
        "La prière et les soins ne s'opposent pas : prends les deux.",
    'premiersPas': [
      "Si tu es en danger immédiat, appelle les secours ou va aux urgences les plus proches.",
      "Parle à une personne de confiance aujourd'hui, pas « quand ça ira mieux ».",
      "Consulte un médecin ou un psychologue : c'est leur métier, pas une extrémité.",
    ],
    'ressources': [
      {
        'libelle': "Demander une écoute",
        'detail': "L'équipe n'est pas un service médical, mais elle peut t'accompagner.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
  {
    'id': 'couple_famille',
    'titre': "Mon couple ou ma famille va mal",
    'resume': "Tensions, séparation, conflit qui dure.",
    'iconName': 'family_restroom',
    'couleurHex': '#E99D1A',
    'ordre': 4,
    'quoiSavoir':
        "Une crise n'est pas forcément la fin : beaucoup de couples et de familles en sortent, "
        "à condition de ne pas attendre que « ça passe ». Un tiers formé aide souvent là où "
        "les mêmes conversations tournent en rond.",
    'premiersPas': [
      "Nomme un fait précis plutôt qu'un reproche général.",
      "Accepte un tiers : conseiller conjugal, médiateur, accompagnateur.",
      "Prie pour l'autre, sans lui demander de changer d'abord.",
    ],
    'ressources': [
      {
        'libelle': "Un accompagnement spirituel",
        'detail': "Être suivi dans la durée, seul ou en couple.",
        'type': 'interne',
        'cible': 'ecoute',
      },
      {
        'libelle': "Rejoindre un groupe Couples & familles",
        'detail': "D'autres traversent la même chose.",
        'type': 'interne',
        'cible': 'groupe',
      },
    ],
  },
  {
    'id': 'dependance',
    'titre': "Je lutte contre une dépendance",
    'resume': "Alcool, drogue, jeux, pornographie, écrans.",
    'iconName': 'link_off',
    'couleurHex': '#7C3AED',
    'ordre': 5,
    'quoiSavoir':
        "Une dépendance n'est pas un simple manque de volonté : le cerveau s'est habitué, "
        "et il faut du soutien extérieur pour défaire cette habitude. Les rechutes font partie "
        "du chemin ; elles n'annulent pas les progrès déjà faits.",
    'premiersPas': [
      "Note ce qui déclenche, plutôt que de te juger après coup.",
      "Parle-en à une personne, une seule : le secret est le meilleur allié de la dépendance.",
      "Cherche un groupe d'entraide ou un professionnel : on n'en sort presque jamais seul.",
    ],
    'ressources': [
      {
        'libelle': "Demander une écoute",
        'detail': "Sans jugement, et sans que cela sorte de l'équipe.",
        'type': 'interne',
        'cible': 'ecoute',
      },
      {
        'libelle': "Préparer une confession",
        'detail': "Pour déposer ce qui pèse et repartir.",
        'type': 'interne',
        'cible': 'confession',
      },
    ],
  },
  {
    'id': 'violences',
    'titre': "Je subis des violences",
    'resume': "Coups, menaces, emprise, abus — aujourd'hui ou par le passé.",
    'iconName': 'shield_outlined',
    'couleurHex': '#B91C1C',
    'ordre': 6,
    'quoiSavoir':
        "Ce que tu subis n'est pas de ta faute, et aucun devoir religieux n'oblige à rester "
        "dans une situation dangereuse. Ta sécurité passe avant toute autre considération. "
        "Si les faits impliquent un membre de l'Église, ils doivent être signalés, sans exception.",
    'premiersPas': [
      "Si tu es en danger immédiat, appelle les secours ou mets-toi à l'abri.",
      "Parle à une personne extérieure à la situation, de confiance.",
      "Garde une trace des faits : dates, messages, témoins.",
    ],
    'ressources': [
      {
        'libelle': "Demander une écoute",
        'detail': "L'équipe t'orientera vers les personnes compétentes.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
  {
    'id': 'argent',
    'titre': "J'ai des difficultés financières",
    'resume': "Fins de mois impossibles, dettes, perte d'emploi.",
    'iconName': 'savings_outlined',
    'couleurHex': '#0F766E',
    'ordre': 7,
    'quoiSavoir':
        "La précarité isole, et la honte empêche souvent de demander à temps. "
        "Il existe presque toujours des dispositifs d'aide, mais ils supposent d'en parler.",
    'premiersPas': [
      "Fais la liste de ce qui rentre et de ce qui sort, même approximative.",
      "Demande avant d'être à découvert : plus tôt, plus de solutions.",
      "Parle-en à ton groupe ou à l'équipe : l'entraide fait partie de la vie chrétienne.",
    ],
    'ressources': [
      {
        'libelle': "Demander une écoute",
        'detail': "Pour être orienté vers une aide concrète.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
  {
    'id': 'doute',
    'titre': "Je doute de ma foi",
    'resume': "Dieu semble absent, ou la prière ne veut plus rien dire.",
    'iconName': 'help_outline',
    'couleurHex': '#5B4FC8',
    'ordre': 8,
    'quoiSavoir':
        "Le doute n'est pas le contraire de la foi : les plus grands croyants l'ont traversé. "
        "Une période aride ne signifie pas que Dieu s'est retiré, ni que tu as mal fait. "
        "Ce qui aide, c'est de tenir de petits gestes quand le goût n'y est plus.",
    'premiersPas': [
      "Garde un rite minimal, même sans rien ressentir.",
      "Pose tes questions à quelqu'un plutôt que de les enterrer.",
      "Reprends un texte : les Psaumes disent aussi la colère et l'absence.",
    ],
    'ressources': [
      {
        'libelle': "Poser une question",
        'detail': "Une question de foi, de doctrine ou de morale.",
        'type': 'interne',
        'cible': 'ecoute',
      },
      {
        'libelle': "Un plan de lecture",
        'detail': "Les Psaumes de confiance, pour prier avec des mots vrais.",
        'type': 'interne',
        'cible': 'bible',
      },
    ],
  },
  {
    'id': 'vocation',
    'titre': "Je cherche ma voie",
    'resume': "Vocation, orientation, choix de vie.",
    'iconName': 'explore_outlined',
    'couleurHex': '#D4A017',
    'ordre': 9,
    'quoiSavoir':
        "Un discernement se fait rarement seul et jamais dans l'urgence. "
        "On avance par petits pas vérifiables, pas par un signe définitif qu'on attendrait.",
    'premiersPas': [
      "Note ce qui te met en paix dans la durée, pas seulement ce qui t'enthousiasme.",
      "Parle à un accompagnateur : le discernement se fait à deux.",
      "Donne-toi une échéance, sinon la question tourne indéfiniment.",
    ],
    'ressources': [
      {
        'libelle': "Un accompagnement spirituel",
        'detail': "Être suivi dans la durée pour discerner.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
  {
    'id': 'reconciliation',
    'titre': "J'ai besoin de me réconcilier",
    'resume': "Avec Dieu, avec quelqu'un, ou avec soi-même.",
    'iconName': 'handshake_outlined',
    'couleurHex': '#16A34A',
    'ordre': 10,
    'quoiSavoir':
        "Pardonner n'est pas dire que ce n'était pas grave, ni se remettre en danger. "
        "C'est renoncer à ce que la rancune décide de ta vie. Cela prend du temps, et ce n'est pas linéaire.",
    'premiersPas': [
      "Nomme précisément ce qui a été blessé.",
      "Fais un pas, même minime, sans attendre que l'autre commence.",
      "Va à la confession : c'est le lieu prévu pour cela.",
    ],
    'ressources': [
      {
        'libelle': "Préparer une confession",
        'detail': "Un examen de conscience guidé, pas à pas.",
        'type': 'interne',
        'cible': 'confession',
      },
      {
        'libelle': "Demander une écoute",
        'detail': "Quand la démarche est trop lourde à faire seul.",
        'type': 'interne',
        'cible': 'ecoute',
      },
    ],
  },
];
