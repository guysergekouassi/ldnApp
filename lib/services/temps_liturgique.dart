/// Calendrier liturgique romain (forme ordinaire), calculé localement.
///
/// Tout part de la date de Pâques : le Carême, le Temps pascal et la
/// Pentecôte s'en déduisent, l'Avent et le Temps de Noël se calent sur le
/// 25 décembre. Aucun appel réseau n'est nécessaire, donc le bandeau du temps
/// liturgique reste juste hors ligne.
library;

/// Un temps liturgique en cours, avec ses bornes et sa couleur.
class TempsLiturgique {
  final String nom;

  /// Phrase courte affichée sous le nom, dans le bandeau d'accueil.
  final String accroche;

  /// Couleur liturgique du temps, au format `#RRGGBB`.
  final String couleurHex;

  final DateTime debut;

  /// Dernier jour du temps, inclus.
  final DateTime fin;

  const TempsLiturgique({
    required this.nom,
    required this.accroche,
    required this.couleurHex,
    required this.debut,
    required this.fin,
  });

  /// Nombre de jours restants, jour en cours compris. Vaut 1 le dernier jour.
  int joursRestantsDepuis(DateTime jour) {
    final j = CalendrierLiturgique.jourSeul(jour);
    if (j.isAfter(fin)) return 0;
    return fin.difference(j).inDays + 1;
  }

  /// Rang du jour dans le temps liturgique, à partir de 1.
  int jourNumeroDepuis(DateTime jour) {
    final j = CalendrierLiturgique.jourSeul(jour);
    if (j.isBefore(debut)) return 0;
    return j.difference(debut).inDays + 1;
  }

  int get dureeEnJours => fin.difference(debut).inDays + 1;
}

/// Une fête à venir, telle qu'affichée dans le compte à rebours.
class FeteLiturgique {
  final String nom;
  final DateTime date;

  const FeteLiturgique(this.nom, this.date);

  int joursRestantsDepuis(DateTime jour) =>
      date.difference(CalendrierLiturgique.jourSeul(jour)).inDays;
}

class CalendrierLiturgique {
  const CalendrierLiturgique._();

  /// Tronque l'heure : toutes les comparaisons se font de jour à jour.
  static DateTime jourSeul(DateTime date) => DateTime(date.year, date.month, date.day);

  /// Dimanche de Pâques pour l'année donnée (comput grégorien, algorithme de
  /// Meeus/Jones/Butcher).
  static DateTime paques(int annee) {
    final a = annee % 19;
    final b = annee ~/ 100;
    final c = annee % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final mois = (h + l - 7 * m + 114) ~/ 31;
    final jour = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(annee, mois, jour);
  }

  static DateTime mercrediDesCendres(int annee) =>
      paques(annee).subtract(const Duration(days: 46));

  static DateTime jeudiSaint(int annee) =>
      paques(annee).subtract(const Duration(days: 3));

  /// Deuxième dimanche de Pâques, fête de la Divine Miséricorde.
  static DateTime divineMisericorde(int annee) =>
      paques(annee).add(const Duration(days: 7));

  static DateTime ascension(int annee) => paques(annee).add(const Duration(days: 39));

  static DateTime pentecote(int annee) => paques(annee).add(const Duration(days: 49));

  /// Premier dimanche de l'Avent : trois semaines avant le dernier dimanche
  /// qui précède Noël.
  static DateTime premierDimancheDeLAvent(int annee) {
    final noel = DateTime(annee, 12, 25);
    // `weekday` vaut 7 le dimanche : on recule alors d'une semaine entière,
    // le 4e dimanche de l'Avent ne pouvant pas tomber le jour de Noël.
    var recul = noel.weekday % 7;
    if (recul == 0) recul = 7;
    return noel.subtract(Duration(days: recul + 21));
  }

  /// Épiphanie telle qu'elle est célébrée en France : le dimanche compris
  /// entre le 2 et le 8 janvier.
  static DateTime epiphanie(int annee) {
    final deuxJanvier = DateTime(annee, 1, 2);
    final joursAvantDimanche = (7 - deuxJanvier.weekday) % 7;
    return deuxJanvier.add(Duration(days: joursAvantDimanche));
  }

  /// Baptême du Seigneur, qui clôt le Temps de Noël. Il suit l'Épiphanie d'une
  /// semaine, sauf quand celle-ci tombe tard : il est alors reporté au lundi.
  static DateTime baptemeDuSeigneur(int annee) {
    final jourEpiphanie = epiphanie(annee);
    if (jourEpiphanie.day >= 7) return jourEpiphanie.add(const Duration(days: 1));
    return jourEpiphanie.add(const Duration(days: 7));
  }

  /// Temps liturgique du jour donné (aujourd'hui par défaut).
  static TempsLiturgique tempsDuJour([DateTime? date]) {
    final jour = jourSeul(date ?? DateTime.now());
    final annee = jour.year;

    final avent = premierDimancheDeLAvent(annee);

    // Après le 1er dimanche de l'Avent, l'année liturgique est déjà celle de
    // l'an prochain : Noël et le Carême suivants s'y rattachent.
    if (!jour.isBefore(avent)) {
      final noel = DateTime(annee, 12, 25);
      if (jour.isBefore(noel)) {
        return TempsLiturgique(
          nom: "Avent",
          accroche: "Préparons nos cœurs à la venue du Sauveur.",
          couleurHex: "#7C3AED",
          debut: avent,
          fin: noel.subtract(const Duration(days: 1)),
        );
      }
      return TempsLiturgique(
        nom: "Temps de Noël",
        accroche: "Le Verbe s'est fait chair : Dieu habite parmi nous.",
        couleurHex: "#D4A017",
        debut: noel,
        fin: baptemeDuSeigneur(annee + 1),
      );
    }

    // Avant l'Avent : on est dans l'année liturgique ouverte en décembre
    // dernier, dont le Temps de Noël déborde sur janvier.
    final bapteme = baptemeDuSeigneur(annee);
    if (!jour.isAfter(bapteme)) {
      return TempsLiturgique(
        nom: "Temps de Noël",
        accroche: "Le Verbe s'est fait chair : Dieu habite parmi nous.",
        couleurHex: "#D4A017",
        debut: DateTime(annee - 1, 12, 25),
        fin: bapteme,
      );
    }

    final cendres = mercrediDesCendres(annee);
    final jeudi = jeudiSaint(annee);
    final dimancheDePaques = paques(annee);
    final dimanchePentecote = pentecote(annee);

    if (jour.isBefore(cendres)) {
      return TempsLiturgique(
        nom: "Temps ordinaire",
        accroche: "Jour après jour, marcher à la suite du Christ.",
        couleurHex: "#16A34A",
        debut: bapteme.add(const Duration(days: 1)),
        fin: cendres.subtract(const Duration(days: 1)),
      );
    }

    if (jour.isBefore(jeudi)) {
      return TempsLiturgique(
        nom: "Carême",
        accroche: "Prière, jeûne et partage vers la joie de Pâques.",
        couleurHex: "#7C3AED",
        debut: cendres,
        fin: jeudi.subtract(const Duration(days: 1)),
      );
    }

    if (jour.isBefore(dimancheDePaques)) {
      return TempsLiturgique(
        nom: "Triduum pascal",
        accroche: "Les trois jours où tout se joue : la Passion, la Croix, le Tombeau.",
        couleurHex: "#B91C1C",
        debut: jeudi,
        fin: dimancheDePaques.subtract(const Duration(days: 1)),
      );
    }

    if (!jour.isAfter(dimanchePentecote)) {
      return TempsLiturgique(
        nom: "Temps pascal",
        accroche: "Le Christ est ressuscité : il est vraiment ressuscité !",
        couleurHex: "#D4A017",
        debut: dimancheDePaques,
        fin: dimanchePentecote,
      );
    }

    return TempsLiturgique(
      nom: "Temps ordinaire",
      accroche: "Jour après jour, marcher à la suite du Christ.",
      couleurHex: "#16A34A",
      debut: dimanchePentecote.add(const Duration(days: 1)),
      fin: avent.subtract(const Duration(days: 1)),
    );
  }

  /// Prochaine grande fête à partir du jour donné, ou null si aucune des fêtes
  /// suivies ne tombe dans les douze prochains mois.
  ///
  /// Les fêtes des deux années civiles sont examinées : fin décembre, la
  /// prochaine échéance appartient déjà à l'année suivante.
  static FeteLiturgique? prochaineFete([DateTime? date]) {
    final jour = jourSeul(date ?? DateTime.now());

    final fetes = <FeteLiturgique>[
      for (final annee in [jour.year, jour.year + 1]) ...[
        FeteLiturgique("Mercredi des Cendres", mercrediDesCendres(annee)),
        FeteLiturgique("Pâques", paques(annee)),
        FeteLiturgique("Divine Miséricorde", divineMisericorde(annee)),
        FeteLiturgique("Ascension", ascension(annee)),
        FeteLiturgique("Pentecôte", pentecote(annee)),
        FeteLiturgique("Assomption", DateTime(annee, 8, 15)),
        FeteLiturgique("Toussaint", DateTime(annee, 11, 1)),
        FeteLiturgique("Entrée en Avent", premierDimancheDeLAvent(annee)),
        FeteLiturgique("Noël", DateTime(annee, 12, 25)),
      ],
    ]..sort((a, b) => a.date.compareTo(b.date));

    for (final fete in fetes) {
      if (!fete.date.isBefore(jour)) return fete;
    }
    return null;
  }

  /// Proposition de vie concrète, adaptée au temps liturgique.
  static String propositionDuTemps(String nomDuTemps) {
    switch (nomDuTemps) {
      case "Avent":
        return "Chaque soir de l'Avent, garde cinq minutes de silence pour préparer Noël autrement.";
      case "Temps de Noël":
        return "Prends le temps de rendre grâce : à qui peux-tu annoncer une bonne nouvelle aujourd'hui ?";
      case "Carême":
        return "Choisis une chose à laquelle renoncer, une prière à tenir, et un geste de partage.";
      case "Triduum pascal":
        return "Fais silence : accompagne le Christ de la Cène au tombeau, sans rien vouloir remplir.";
      case "Temps pascal":
        return "Cinquante jours de joie : dis à quelqu'un ce que le Ressuscité a changé chez toi.";
      default:
        return "Le temps ordinaire n'a rien de banal : c'est là que la fidélité se construit.";
    }
  }
}
