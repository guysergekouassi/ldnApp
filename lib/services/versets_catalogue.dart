/// Versets proposés en rotation pour « Le verset du jour ».
///
/// Jusqu'ici l'application lisait un document unique, jamais renouvelé : le
/// même verset s'affichait indéfiniment. Ces versets sont semés dans la
/// collection `daily_verses`, et celui du jour est choisi par une rotation
/// déterministe — tous les utilisateurs voient le même verset le même jour,
/// même hors ligne, et la liste peut être complétée depuis la console.
class VersetCatalogue {
  final String id;
  final String contenu;
  final String reference;
  final int ordre;

  const VersetCatalogue({
    required this.id,
    required this.contenu,
    required this.reference,
    required this.ordre,
  });
}

/// Affiché tant que la collection n'a pas encore été semée.
const VersetCatalogue versetParDefaut = VersetCatalogue(
  id: 'v001',
  contenu: "Ta parole est une lampe à mes pieds, une lumière sur mon sentier.",
  reference: "Psaume 119, 105",
  ordre: 1,
);

const List<VersetCatalogue> versetsCatalogue = [
  VersetCatalogue(id: 'v001', ordre: 1, contenu: "Ta parole est une lampe à mes pieds, une lumière sur mon sentier.", reference: "Psaume 119, 105"),
  VersetCatalogue(id: 'v002', ordre: 2, contenu: "Je suis le chemin, la vérité et la vie.", reference: "Jean 14, 6"),
  VersetCatalogue(id: 'v003', ordre: 3, contenu: "Le Seigneur est mon berger : je ne manque de rien.", reference: "Psaume 23, 1"),
  VersetCatalogue(id: 'v004', ordre: 4, contenu: "Venez à moi, vous tous qui peinez sous le poids du fardeau, et moi, je vous procurerai le repos.", reference: "Matthieu 11, 28"),
  VersetCatalogue(id: 'v005', ordre: 5, contenu: "Dieu est amour : celui qui demeure dans l'amour demeure en Dieu.", reference: "1 Jean 4, 16"),
  VersetCatalogue(id: 'v006', ordre: 6, contenu: "Je puis tout en celui qui me donne la force.", reference: "Philippiens 4, 13"),
  VersetCatalogue(id: 'v007', ordre: 7, contenu: "Ne crains pas, car je suis avec toi ; ne sois pas effrayé, car je suis ton Dieu.", reference: "Isaïe 41, 10"),
  VersetCatalogue(id: 'v008', ordre: 8, contenu: "Demandez, on vous donnera ; cherchez, vous trouverez ; frappez, on vous ouvrira.", reference: "Matthieu 7, 7"),
  VersetCatalogue(id: 'v009', ordre: 9, contenu: "Aimez-vous les uns les autres comme je vous ai aimés.", reference: "Jean 13, 34"),
  VersetCatalogue(id: 'v010', ordre: 10, contenu: "Le Seigneur est ma lumière et mon salut ; de qui aurais-je crainte ?", reference: "Psaume 27, 1"),
  VersetCatalogue(id: 'v011', ordre: 11, contenu: "Heureux les cœurs purs, car ils verront Dieu.", reference: "Matthieu 5, 8"),
  VersetCatalogue(id: 'v012', ordre: 12, contenu: "Que votre cœur ne soit pas bouleversé : vous croyez en Dieu, croyez aussi en moi.", reference: "Jean 14, 1"),
  VersetCatalogue(id: 'v013', ordre: 13, contenu: "Tout concourt au bien de ceux qui aiment Dieu.", reference: "Romains 8, 28"),
  VersetCatalogue(id: 'v014', ordre: 14, contenu: "Ma grâce te suffit : ma puissance donne toute sa mesure dans la faiblesse.", reference: "2 Corinthiens 12, 9"),
  VersetCatalogue(id: 'v015', ordre: 15, contenu: "Voici que je fais toutes choses nouvelles.", reference: "Apocalypse 21, 5"),
  VersetCatalogue(id: 'v016', ordre: 16, contenu: "Je suis le pain de vie. Celui qui vient à moi n'aura jamais faim.", reference: "Jean 6, 35"),
  VersetCatalogue(id: 'v017', ordre: 17, contenu: "Cherchez d'abord le royaume de Dieu et sa justice, et tout cela vous sera donné par surcroît.", reference: "Matthieu 6, 33"),
  VersetCatalogue(id: 'v018', ordre: 18, contenu: "Le Seigneur est proche de ceux qui ont le cœur brisé.", reference: "Psaume 34, 19"),
  VersetCatalogue(id: 'v019', ordre: 19, contenu: "Si Dieu est pour nous, qui sera contre nous ?", reference: "Romains 8, 31"),
  VersetCatalogue(id: 'v020', ordre: 20, contenu: "Veillez et priez, pour ne pas entrer en tentation.", reference: "Matthieu 26, 41"),
  VersetCatalogue(id: 'v021', ordre: 21, contenu: "Rendez grâce en toute circonstance : c'est ce que Dieu attend de vous.", reference: "1 Thessaloniciens 5, 18"),
  VersetCatalogue(id: 'v022', ordre: 22, contenu: "Bénis le Seigneur, ô mon âme, n'oublie aucun de ses bienfaits.", reference: "Psaume 103, 2"),
  VersetCatalogue(id: 'v023', ordre: 23, contenu: "Vous êtes la lumière du monde.", reference: "Matthieu 5, 14"),
  VersetCatalogue(id: 'v024', ordre: 24, contenu: "La foi est la garantie des biens que l'on espère, la preuve des réalités qu'on ne voit pas.", reference: "Hébreux 11, 1"),
  VersetCatalogue(id: 'v025', ordre: 25, contenu: "Il fait toute chose belle en son temps.", reference: "Qohélet 3, 11"),
  VersetCatalogue(id: 'v026', ordre: 26, contenu: "Rien n'est impossible à Dieu.", reference: "Luc 1, 37"),
  VersetCatalogue(id: 'v027', ordre: 27, contenu: "Le fruit de l'Esprit est amour, joie, paix, patience, bonté, bienveillance.", reference: "Galates 5, 22"),
  VersetCatalogue(id: 'v028', ordre: 28, contenu: "Approchez-vous de Dieu, et il s'approchera de vous.", reference: "Jacques 4, 8"),
  VersetCatalogue(id: 'v029', ordre: 29, contenu: "Je t'ai appelé par ton nom : tu es à moi.", reference: "Isaïe 43, 1"),
  VersetCatalogue(id: 'v030', ordre: 30, contenu: "Sois sans crainte, crois seulement.", reference: "Marc 5, 36"),
  VersetCatalogue(id: 'v031', ordre: 31, contenu: "Le Seigneur combattra pour vous ; vous, restez tranquilles.", reference: "Exode 14, 14"),
  VersetCatalogue(id: 'v032', ordre: 32, contenu: "Mon âme exalte le Seigneur, exulte mon esprit en Dieu, mon Sauveur.", reference: "Luc 1, 46-47"),
  VersetCatalogue(id: 'v033', ordre: 33, contenu: "Père, non pas ma volonté, mais la tienne.", reference: "Luc 22, 42"),
  VersetCatalogue(id: 'v034', ordre: 34, contenu: "Je vous laisse la paix, je vous donne ma paix.", reference: "Jean 14, 27"),
  VersetCatalogue(id: 'v035', ordre: 35, contenu: "Espère le Seigneur, sois fort et prends courage.", reference: "Psaume 27, 14"),
  VersetCatalogue(id: 'v036', ordre: 36, contenu: "Il y a plus de bonheur à donner qu'à recevoir.", reference: "Actes 20, 35"),
  VersetCatalogue(id: 'v037', ordre: 37, contenu: "Que tout ce que vous faites se fasse dans l'amour.", reference: "1 Corinthiens 16, 14"),
  VersetCatalogue(id: 'v038', ordre: 38, contenu: "Demeurez en moi, comme moi en vous.", reference: "Jean 15, 4"),
  VersetCatalogue(id: 'v039', ordre: 39, contenu: "Le Seigneur te garde de tout mal, il garde ta vie.", reference: "Psaume 121, 7"),
  VersetCatalogue(id: 'v040', ordre: 40, contenu: "Dieu ne nous a pas donné un esprit de peur, mais de force, d'amour et de sagesse.", reference: "2 Timothée 1, 7"),
];
