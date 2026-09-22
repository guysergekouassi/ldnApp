/// Une ressource proposée pour un besoin donné.
///
/// Le type distingue ce que l'application sait faire elle-même (`interne`)
/// de ce qui renvoie vers l'extérieur. Les coordonnées extérieures ne sont pas
/// livrées avec l'application : elles dépendent du pays et doivent être
/// vérifiées par l'équipe avant d'être affichées à quelqu'un en difficulté.
class RessourceAide {
  final String libelle;
  final String detail;

  /// `interne` (une destination de l'application), `telephone`, `lien`, `lieu`.
  final String type;

  /// Clé d'action interne, numéro, URL ou adresse selon [type].
  final String cible;

  const RessourceAide({
    required this.libelle,
    required this.detail,
    required this.type,
    required this.cible,
  });

  factory RessourceAide.fromMap(Map<String, dynamic> data) {
    return RessourceAide(
      libelle: (data['libelle'] ?? '').toString().trim(),
      detail: (data['detail'] ?? '').toString().trim(),
      type: (data['type'] ?? 'interne').toString().trim(),
      cible: (data['cible'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toMap() => {
        'libelle': libelle,
        'detail': detail,
        'type': type,
        'cible': cible,
      };

  bool get estInterne => type == 'interne';
}

/// Un besoin traité dans « Aller plus loin », dans `aide_besoins`.
class BesoinAide {
  final String id;
  final String titre;
  final String resume;
  final String iconName;
  final String couleurHex;

  /// Ce qu'il est utile de savoir : un paragraphe, pas un sermon.
  final String quoiSavoir;

  /// Premiers pas concrets, dans l'ordre.
  final List<String> premiersPas;

  final List<RessourceAide> ressources;
  final int ordre;

  BesoinAide({
    required this.id,
    required this.titre,
    required this.resume,
    required this.iconName,
    required this.couleurHex,
    required this.quoiSavoir,
    required this.premiersPas,
    required this.ressources,
    required this.ordre,
  });

  factory BesoinAide.fromFirestore(Map<String, dynamic> data, String id) {
    return BesoinAide(
      id: id,
      titre: (data['titre'] ?? '').toString().trim(),
      resume: (data['resume'] ?? '').toString().trim(),
      iconName: (data['iconName'] ?? 'help_outline').toString().trim(),
      couleurHex: (data['couleurHex'] ?? '#5B4FC8').toString().trim(),
      quoiSavoir: (data['quoiSavoir'] ?? '').toString().trim(),
      premiersPas: (data['premiersPas'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      ressources: (data['ressources'] as List? ?? const [])
          .map((e) => RessourceAide.fromMap(e as Map<String, dynamic>))
          .toList(),
      ordre: data['ordre'] ?? 99,
    );
  }

  /// Ressources extérieures renseignées par l'équipe. Vide tant que personne
  /// n'a saisi de contact local : l'écran n'affiche alors pas la section.
  List<RessourceAide> get ressourcesExterieures =>
      ressources.where((r) => !r.estInterne && r.cible.isNotEmpty).toList();

  List<RessourceAide> get ressourcesInternes =>
      ressources.where((r) => r.estInterne).toList();
}
