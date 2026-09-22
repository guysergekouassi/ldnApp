import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth/services/temps_liturgique.dart';

void main() {
  group('Pâques', () {
    test('tombe aux dates connues du comput grégorien', () {
      final attendu = {
        2024: DateTime(2024, 3, 31),
        2025: DateTime(2025, 4, 20),
        2026: DateTime(2026, 4, 5),
        2027: DateTime(2027, 3, 28),
        2028: DateTime(2028, 4, 16),
        2030: DateTime(2030, 4, 21),
        2038: DateTime(2038, 4, 25), // date la plus tardive possible
      };

      attendu.forEach((annee, date) {
        expect(CalendrierLiturgique.paques(annee), date, reason: 'Pâques $annee');
      });
    });

    test('les fêtes mobiles se déduisent de Pâques', () {
      expect(CalendrierLiturgique.mercrediDesCendres(2026), DateTime(2026, 2, 18));
      expect(CalendrierLiturgique.divineMisericorde(2026), DateTime(2026, 4, 12));
      expect(CalendrierLiturgique.ascension(2026), DateTime(2026, 5, 14));
      expect(CalendrierLiturgique.pentecote(2026), DateTime(2026, 5, 24));
    });
  });

  group('Avent', () {
    test('commence le dimanche entre le 27 novembre et le 3 décembre', () {
      for (var annee = 2024; annee <= 2035; annee++) {
        final avent = CalendrierLiturgique.premierDimancheDeLAvent(annee);
        expect(avent.weekday, DateTime.sunday, reason: 'Avent $annee');
        expect(avent.isAfter(DateTime(annee, 11, 26)), isTrue, reason: 'Avent $annee');
        expect(avent.isBefore(DateTime(annee, 12, 4)), isTrue, reason: 'Avent $annee');
      }
    });

    test('recule d’une semaine quand Noël tombe un dimanche', () {
      // 25 décembre 2022 : un dimanche.
      expect(CalendrierLiturgique.premierDimancheDeLAvent(2022), DateTime(2022, 11, 27));
      expect(CalendrierLiturgique.premierDimancheDeLAvent(2025), DateTime(2025, 11, 30));
    });
  });

  group('Temps du jour', () {
    test('nomme correctement chaque temps de l’année 2026', () {
      final cas = {
        DateTime(2026, 1, 5): "Temps de Noël",
        DateTime(2026, 2, 1): "Temps ordinaire",
        DateTime(2026, 2, 18): "Carême", // mercredi des Cendres
        DateTime(2026, 3, 30): "Carême",
        DateTime(2026, 4, 2): "Triduum pascal", // jeudi saint
        DateTime(2026, 4, 5): "Temps pascal", // Pâques
        DateTime(2026, 5, 24): "Temps pascal", // Pentecôte, dernier jour
        DateTime(2026, 5, 25): "Temps ordinaire",
        DateTime(2026, 11, 29): "Avent",
        DateTime(2026, 12, 25): "Temps de Noël",
      };

      cas.forEach((jour, nom) {
        expect(CalendrierLiturgique.tempsDuJour(jour).nom, nom, reason: '$jour');
      });
    });

    test('couvre chaque jour sans trou ni chevauchement', () {
      var jour = DateTime(2026, 1, 1);
      while (jour.isBefore(DateTime(2027, 1, 1))) {
        final temps = CalendrierLiturgique.tempsDuJour(jour);
        expect(temps.debut.isAfter(jour), isFalse, reason: 'début > $jour');
        expect(temps.fin.isBefore(jour), isFalse, reason: 'fin < $jour');
        expect(temps.joursRestantsDepuis(jour), greaterThan(0), reason: '$jour');
        expect(temps.jourNumeroDepuis(jour), greaterThan(0), reason: '$jour');
        jour = jour.add(const Duration(days: 1));
      }
    });
  });

  group('Prochaine fête', () {
    test('renvoie la fête du jour même', () {
      final fete = CalendrierLiturgique.prochaineFete(DateTime(2026, 4, 5));
      expect(fete?.nom, "Pâques");
      expect(fete?.joursRestantsDepuis(DateTime(2026, 4, 5)), 0);
    });

    test('passe à l’année suivante après la dernière fête de décembre', () {
      final fete = CalendrierLiturgique.prochaineFete(DateTime(2026, 12, 26));
      expect(fete?.date.year, 2027);
      expect(fete?.nom, "Mercredi des Cendres");
    });
  });
}
