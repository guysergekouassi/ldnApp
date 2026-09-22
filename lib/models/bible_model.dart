/// Un verset : son numéro et son texte.
class Verset {
  final int numero;
  final String texte;

  const Verset({required this.numero, required this.texte});

  factory Verset.fromJson(Map<String, dynamic> data) => Verset(
        numero: data['n'] ?? 0,
        texte: (data['t'] ?? '').toString(),
      );
}

/// Un chapitre et ses versets.
class ChapitreBiblique {
  final int numero;
  final List<Verset> versets;

  const ChapitreBiblique({required this.numero, required this.versets});

  factory ChapitreBiblique.fromJson(Map<String, dynamic> data) =>
      ChapitreBiblique(
        numero: data['numero'] ?? 0,
        versets: ((data['versets'] as List?) ?? const [])
            .map((v) => Verset.fromJson(Map<String, dynamic>.from(v as Map)))
            .toList(),
      );
}

/// L'entrée d'un livre dans le sommaire : de quoi dresser la liste sans
/// charger le texte, qui pèse jusqu'à 400 Ko pour un seul livre.
class LivreBiblique {
  final String id;
  final String nom;

  /// Abréviation du lectionnaire (« Mc »), telle qu'elle apparaît dans les
  /// références des plans de lecture.
  final String abbr;

  /// « AT » ou « NT ».
  final String testament;

  /// Rang dans l'ordre des livres, pour afficher le sommaire dans l'ordre de
  /// la Bible et non par ordre alphabétique.
  final int ordre;

  final int nombreDeChapitres;
  final int nombreDeVersets;

  const LivreBiblique({
    required this.id,
    required this.nom,
    required this.abbr,
    required this.testament,
    required this.ordre,
    required this.nombreDeChapitres,
    required this.nombreDeVersets,
  });

  bool get estAncienTestament => testament == 'AT';

  factory LivreBiblique.fromJson(Map<String, dynamic> data) => LivreBiblique(
        id: (data['id'] ?? '').toString(),
        nom: (data['nom'] ?? '').toString(),
        abbr: (data['abbr'] ?? '').toString(),
        testament: (data['testament'] ?? 'AT').toString(),
        ordre: data['ordre'] ?? 0,
        nombreDeChapitres: data['chapitres'] ?? 0,
        nombreDeVersets: data['versets'] ?? 0,
      );
}

/// Un livre avec son texte.
class LivreOuvert {
  final LivreBiblique livre;
  final List<ChapitreBiblique> chapitres;

  const LivreOuvert({required this.livre, required this.chapitres});
}
