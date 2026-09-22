import 'package:flutter/material.dart';

import '../services/temps_liturgique.dart';

/// Bandeau du temps liturgique en cours, aux couleurs de la liturgie.
///
/// Tout est calculé localement par [CalendrierLiturgique] : le bandeau reste
/// juste hors ligne et ne dépend d'aucun contenu à saisir côté Firestore.
class BandeauTempsLiturgique extends StatelessWidget {
  /// Jour évalué. Sert surtout aux aperçus ; l'application passe la date du
  /// jour, que l'accueil rafraîchit au passage de minuit.
  final DateTime? jour;

  /// Version resserrée, sans la proposition de vie ni la barre de progression.
  final bool compact;

  const BandeauTempsLiturgique({Key? key, this.jour, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final aujourdHui = jour ?? DateTime.now();
    final temps = CalendrierLiturgique.tempsDuJour(aujourdHui);
    final couleur = _couleur(temps.couleurHex);

    final numero = temps.jourNumeroDepuis(aujourdHui);
    final restants = temps.joursRestantsDepuis(aujourdHui);
    final progression = temps.dureeEnJours <= 0
        ? 0.0
        : (numero / temps.dureeEnJours).clamp(0.0, 1.0);

    final fete = CalendrierLiturgique.prochaineFete(aujourdHui);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [couleur, Color.lerp(couleur, Colors.black, 0.25) ?? couleur],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.church_outlined, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  temps.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Jour $numero",
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            temps.accroche,
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
          ),
          if (!compact) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progression,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restants == 1
                  ? "Dernier jour de ce temps liturgique."
                  : "Encore $restants jours dans ce temps.",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.wb_twilight, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      CalendrierLiturgique.propositionDuTemps(temps.nom),
                      style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (fete != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, color: Colors.white.withOpacity(0.8), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _libelleFete(fete, aujourdHui),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _libelleFete(FeteLiturgique fete, DateTime aujourdHui) {
    final jours = fete.joursRestantsDepuis(aujourdHui);
    if (jours == 0) return "Aujourd'hui : ${fete.nom}";
    if (jours == 1) return "Demain : ${fete.nom}";
    return "${fete.nom} dans $jours jours";
  }

  Color _couleur(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF16A34A);
    }
  }
}
