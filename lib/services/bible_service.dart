import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/bible_model.dart';

/// Accès au texte de la Bible, embarqué dans l'application.
///
/// Traduction Augustin Crampon, édition de 1923 : elle est dans le domaine
/// public, donc distribuable sans autorisation, et c'est une Bible catholique
/// complète — les 73 livres, deutérocanoniques compris.
///
/// Le texte est embarqué plutôt qu'appelé sur un serveur : on lit la Parole
/// dans le train, à l'adoration, là où le réseau manque, et une lecture ne
/// doit pas dépendre d'une connexion ni coûter des données.
///
/// Un livre est chargé à la demande et gardé en mémoire : tout charger d'un
/// coup ferait lire 5 Mo de JSON au démarrage pour trois versets consultés.
class BibleService {
  BibleService._();

  static final BibleService instance = BibleService._();

  List<LivreBiblique>? _sommaire;
  final Map<String, LivreOuvert> _enMemoire = {};

  /// Le sommaire des 73 livres, dans l'ordre de la Bible.
  Future<List<LivreBiblique>> sommaire() async {
    if (_sommaire != null) return _sommaire!;

    final brut = await rootBundle.loadString('assets/bible/index.json');
    final livres = (json.decode(brut) as List)
        .map((l) => LivreBiblique.fromJson(Map<String, dynamic>.from(l as Map)))
        .toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));

    return _sommaire = livres;
  }

  Future<List<LivreBiblique>> ancienTestament() async =>
      (await sommaire()).where((l) => l.estAncienTestament).toList();

  Future<List<LivreBiblique>> nouveauTestament() async =>
      (await sommaire()).where((l) => !l.estAncienTestament).toList();

  /// Ouvre un livre et son texte.
  Future<LivreOuvert> ouvrir(LivreBiblique livre) async {
    final dejaLu = _enMemoire[livre.id];
    if (dejaLu != null) return dejaLu;

    final brut = await rootBundle.loadString('assets/bible/${livre.id}.json');
    final data = json.decode(brut) as Map<String, dynamic>;
    final chapitres = ((data['chapitres'] as List?) ?? const [])
        .map((c) => ChapitreBiblique.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();

    return _enMemoire[livre.id] = LivreOuvert(livre: livre, chapitres: chapitres);
  }

  /// Retrouve un livre par son abréviation (« Mc »), son nom ou son
  /// identifiant, pour ouvrir le texte depuis une référence de plan de
  /// lecture. Insensible à la casse et aux espaces.
  Future<LivreBiblique?> chercher(String reference) async {
    final cherche = reference.trim().toLowerCase().replaceAll(' ', '');
    if (cherche.isEmpty) return null;

    for (final livre in await sommaire()) {
      if (livre.abbr.toLowerCase().replaceAll(' ', '') == cherche ||
          livre.id == cherche ||
          livre.nom.toLowerCase() == reference.trim().toLowerCase()) {
        return livre;
      }
    }
    return null;
  }
}
