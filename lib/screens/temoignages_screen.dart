import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../components/ldn_signature.dart';
import '../components/user_avatar.dart';
import '../models/temoignage_model.dart';
import '../services/firestore_service.dart';
import '../services/share_service.dart';

/// Ouvre le formulaire de dépôt d'un témoignage.
///
/// Exposé hors de l'écran pour que la carte de l'accueil puisse l'appeler
/// directement, sans passer par la liste complète.
Future<bool?> showTemoignageForm(BuildContext context) {
  if (FirebaseAuth.instance.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Connecte-toi pour partager ton témoignage."),
        backgroundColor: Colors.orange,
      ),
    );
    return Future.value(null);
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TemoignageForm(),
  );
}

class TemoignagesScreen extends StatefulWidget {
  const TemoignagesScreen({Key? key}) : super(key: key);

  @override
  State<TemoignagesScreen> createState() => _TemoignagesScreenState();
}

class _TemoignagesScreenState extends State<TemoignagesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Témoignages",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTemoignageForm(context),
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        label: const Text(
          "Témoigner",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<Set<String>>(
        stream: _firestoreService.getLikedTemoignageIds(),
        builder: (context, aimesSnapshot) {
          final aimes = aimesSnapshot.data ?? <String>{};

          return StreamBuilder<List<Temoignage>>(
            stream: _firestoreService.getTemoignages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.orange));
              }

              final temoignages = snapshot.data ?? [];
              if (temoignages.isEmpty) return _buildVide();

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
                itemCount: temoignages.length + 1,
                separatorBuilder: (context, index) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  if (index == temoignages.length) return const LdnSignature();
                  final temoignage = temoignages[index];
                  return _buildCarte(temoignage, aimes.contains(temoignage.id));
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 48, color: Colors.orange.shade200),
            const SizedBox(height: 15),
            const Text(
              "Aucun témoignage pour l'instant",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sois le premier à raconter ce que Dieu a fait dans ta vie.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarte(Temoignage temoignage, bool estAime) {
    final estAuteur = _uid != null && temoignage.authorUid == _uid;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(temoignage, 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temoignage.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    if (temoignage.createdAt != null)
                      Text(
                        // Format numérique : les données de locale `fr_FR`
                        // ne sont pas initialisées dans l'application.
                        DateFormat('dd/MM/yyyy').format(temoignage.createdAt!),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                  ],
                ),
              ),
              if (estAuteur)
                SizedBox(
                  width: 28,
                  height: 28,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    tooltip: "Supprimer",
                    icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (_) => _supprimer(temoignage),
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text("Supprimer", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (temoignage.title.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              temoignage.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A), height: 1.3),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            temoignage.content,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),
          Row(
            children: [
              LikeButton(
                estAime: estAime,
                compteur: temoignage.likes,
                onTap: () => _firestoreService.toggleLikeTemoignage(temoignage.id),
              ),
              const SizedBox(width: 12),
              _buildPartager(temoignage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Temoignage temoignage, double radius) {
    if (temoignage.authorAvatarUrl.isNotEmpty) {
      return UserAvatar(imageReference: temoignage.authorAvatarUrl, radius: radius);
    }

    // Les témoignages livrés avec l'application n'ont pas de photo : les
    // initiales valent mieux qu'un avatar générique répété sur toute la liste.
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.orange.shade50,
      child: Text(
        temoignage.initiales,
        style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: radius * 0.7),
      ),
    );
  }

  Widget _buildPartager(Temoignage temoignage) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => ShareService.sharePost(
        authorName: temoignage.authorName,
        content: temoignage.title.isEmpty
            ? temoignage.content
            : "${temoignage.title}\n\n${temoignage.content}",
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.reply, color: Colors.grey, size: 16),
            SizedBox(width: 6),
            Text("Partager", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _supprimer(Temoignage temoignage) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Supprimer ce témoignage ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Il ne sera plus visible par la communauté."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    await _firestoreService.deleteTemoignage(temoignage.id);
  }
}

/// Bouton « j'aime » sur fond blanc, partagé par le fil d'actualité et les
/// témoignages : cœur plein et orangé quand le membre a aimé, contour gris
/// sinon, pour que l'état soit lisible d'un coup d'œil.
class LikeButton extends StatelessWidget {
  final bool estAime;
  final int compteur;
  final VoidCallback onTap;
  final double taille;

  const LikeButton({
    Key? key,
    required this.estAime,
    required this.compteur,
    required this.onTap,
    this.taille = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: taille * 0.75, vertical: taille * 0.44),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: estAime ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              estAime ? Icons.favorite : Icons.favorite_border,
              color: estAime ? Colors.red : Colors.grey,
              size: taille,
            ),
            SizedBox(width: taille * 0.37),
            Text(
              "$compteur",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: estAime ? Colors.red : Colors.grey,
                fontSize: taille * 0.75,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemoignageForm extends StatefulWidget {
  const _TemoignageForm({Key? key}) : super(key: key);

  @override
  State<_TemoignageForm> createState() => _TemoignageFormState();
}

class _TemoignageFormState extends State<_TemoignageForm> {
  final _titreController = TextEditingController();
  final _contenuController = TextEditingController();
  bool _envoiEnCours = false;

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    final contenu = _contenuController.text.trim();
    if (contenu.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Raconte un peu plus : au moins quelques phrases."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Capturé avant l'envoi : après le `pop`, ce `context` n'est plus rattaché
    // à un Scaffold et la confirmation ne s'afficherait pas.
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _envoiEnCours = true);
    try {
      await FirestoreService().addTemoignage(_titreController.text, contenu);
      if (!mounted) return;
      Navigator.pop(context, true);
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Merci ! Ton témoignage est publié 🙏"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _envoiEnCours = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Publication impossible. Vérifie ta connexion."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Remonte la feuille au-dessus du clavier : sans cela le champ de saisie
      // du récit reste masqué pendant la frappe.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Partager mon témoignage",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              const Text(
                "Ce que le Seigneur a fait pour toi peut relever quelqu'un aujourd'hui.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titreController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: "Titre (facultatif)",
                  hintText: "Ex. : Dieu a ouvert une porte fermée",
                  counterText: "",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _contenuController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                maxLength: 1500,
                decoration: InputDecoration(
                  labelText: "Mon témoignage",
                  hintText: "Raconte simplement ce que tu as vécu…",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _envoiEnCours ? null : _envoyer,
                  child: _envoiEnCours
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          "Publier mon témoignage",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
