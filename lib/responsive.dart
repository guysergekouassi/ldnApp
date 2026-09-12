import 'package:flutter/material.dart';

/// Adaptation de l'interface à la taille de l'écran.
///
/// L'application a été dessinée pour un téléphone d'environ 390 dp de large
/// (iPhone 14 / Pixel 7). Sur un écran plus étroit — un Galaxy A03, un iPhone SE
/// ou tout appareil à 320-360 dp — les tailles fixes finissent par déborder.
/// [AppScale] fournit un facteur unique dont dépendent polices, espacements et
/// icônes, de sorte qu'un même écran tienne partout.
extension AppScale on BuildContext {
  static const double _referenceWidth = 390.0;

  /// Facteur d'échelle borné : on réduit jusqu'à 82 % sur les petits écrans et
  /// on agrandit au plus de 15 % sur les grands, pour éviter des textes
  /// minuscules d'un côté et démesurés de l'autre.
  double get scaleFactor {
    final width = MediaQuery.of(this).size.width;
    return (width / _referenceWidth).clamp(0.82, 1.15);
  }

  /// Taille de police adaptée.
  double sp(double size) => size * scaleFactor;

  /// Espacement ou dimension adapté.
  double gap(double size) => size * scaleFactor;

  /// Vrai sur les écrans étroits, où il vaut mieux empiler que juxtaposer.
  bool get isNarrow => MediaQuery.of(this).size.width < 360;
}

/// Borne l'agrandissement de police du système.
///
/// Android et iOS permettent de pousser la taille du texte jusqu'à 200 %.
/// Cette application utilise beaucoup de tailles fixes et de cartes de hauteur
/// contrainte : sans borne, ces réglages font déborder presque tous les écrans.
/// On respecte le choix de l'utilisateur jusqu'à 130 %, au-delà on plafonne.
class ClampedTextScale extends StatelessWidget {
  final Widget child;
  final double maxScale;

  const ClampedTextScale({
    Key? key,
    required this.child,
    this.maxScale = 1.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: maxScale),
      ),
      child: child,
    );
  }
}
