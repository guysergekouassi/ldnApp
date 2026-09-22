import 'package:flutter/material.dart';

/// Signature de marque affichée en pied de page : « Une initiative
/// Lumière Des Nations ».
///
/// Posée en bas des écrans principaux (accueil, Mon Espace), elle rattache
/// l'application à l'association sans occuper de place dans la navigation.
class LdnSignature extends StatelessWidget {
  /// Version resserrée, sans mention de droits : pour les pieds de feuilles
  /// modales ou les écrans secondaires.
  final bool compact;

  /// Texte affiché au-dessus du nom. Laisser vide pour n'afficher que la marque.
  final String accroche;

  const LdnSignature({
    Key? key,
    this.compact = false,
    this.accroche = "Une initiative",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final couleurTexte = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final couleurMarque = isDark ? Colors.white : const Color(0xFF0F172A);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 12 : 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            // Filet fin centré, qui sépare la signature du contenu sans
            // alourdir la page avec un Divider pleine largeur.
            SizedBox(
              width: 60,
              child: Divider(color: couleurTexte.withOpacity(0.4), thickness: 1),
            ),
            const SizedBox(height: 16),
          ],
          if (accroche.isNotEmpty)
            Text(
              accroche,
              style: TextStyle(fontSize: 11, color: couleurTexte, letterSpacing: 0.5),
            ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo-LDN-notext.png",
                height: compact ? 22 : 28,
                // Le pied de page ne doit jamais casser l'écran si le visuel
                // manque : on retombe sur le monogramme typographique.
                errorBuilder: (context, error, stackTrace) => Text(
                  "LDN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 13 : 15,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Lumière Des Nations",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: couleurMarque,
                  ),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 10),
            Text(
              "© ${DateTime.now().year} LDN · JEP — Jeunesse En Prière",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: couleurTexte),
            ),
            const SizedBox(height: 4),
            Text(
              "« Je fais de toi la lumière des nations » — Is 49, 6",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: couleurTexte,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
