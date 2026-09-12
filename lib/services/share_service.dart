import 'package:share_plus/share_plus.dart';

/// Partage de contenu vers les applications du téléphone (WhatsApp, SMS,
/// mail…), via la feuille de partage native.
class ShareService {
  static const String _signature = "\n\nPartagé depuis Lumière des Nations 🙏";

  /// Partage une publication de la communauté.
  static Future<void> sharePost({
    required String authorName,
    required String content,
  }) {
    return SharePlus.instance.share(
      ShareParams(text: "« $content »\n— $authorName$_signature"),
    );
  }

  /// Partage un verset ou une lecture, avec sa référence biblique.
  static Future<void> shareVerse({
    required String reference,
    required String text,
  }) {
    return SharePlus.instance.share(
      ShareParams(text: "« $text »\n$reference$_signature"),
    );
  }
}
