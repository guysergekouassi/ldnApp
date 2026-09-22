import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../components/ldn_signature.dart';
import '../models/demande_ecoute_model.dart';
import '../services/firestore_service.dart';

/// Demander une écoute ou un accompagnement, et suivre ses demandes.
///
/// Les demandes sont des données sensibles : les règles Firestore en réservent
/// la lecture à leur auteur, et l'écran le dit explicitement au membre.
class DemandeEcouteScreen extends StatefulWidget {
  /// Type présélectionné, quand on arrive depuis « Aller plus loin ».
  final String? typeInitial;

  /// Sujet pré-rempli, repris du besoin d'où l'on vient.
  final String? sujetInitial;

  const DemandeEcouteScreen({Key? key, this.typeInitial, this.sujetInitial})
      : super(key: key);

  @override
  State<DemandeEcouteScreen> createState() => _DemandeEcouteScreenState();
}

class _DemandeEcouteScreenState extends State<DemandeEcouteScreen> {
  static const Color _violet = Color(0xFF5B4FC8);

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final _sujetController = TextEditingController();
  final _messageController = TextEditingController();
  final _coordonneeController = TextEditingController();

  late String _type = widget.typeInitial ?? 'ecoute';
  String _moyenContact = 'app';
  bool _envoiEnCours = false;

  @override
  void initState() {
    super.initState();
    if (widget.sujetInitial != null) _sujetController.text = widget.sujetInitial!;
  }

  @override
  void dispose() {
    _sujetController.dispose();
    _messageController.dispose();
    _coordonneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Être accompagné",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _uid == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  "Connecte-toi pour demander un accompagnement.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildConfidentialite(),
                const SizedBox(height: 15),
                _buildMesDemandes(),
                _buildFormulaire(),
                const LdnSignature(),
              ],
            ),
    );
  }

  Widget _buildConfidentialite() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lock_outline, color: _violet, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Ce que tu écris ici n'est visible que par toi et par l'équipe d'accompagnement. "
              "Aucun autre membre n'y a accès, et rien n'apparaît dans la communauté.",
              style: TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesDemandes() {
    return StreamBuilder<List<DemandeEcoute>>(
      stream: _firestoreService.getMesDemandesEcoute(_uid!),
      builder: (context, snapshot) {
        final demandes = snapshot.data ?? <DemandeEcoute>[];
        if (demandes.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                "Mes demandes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
              ),
            ),
            ...demandes.map(_buildDemandeCard),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                "Nouvelle demande",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDemandeCard(DemandeEcoute demande) {
    final couleur = demande.statut == StatutDemande.priseEnCharge
        ? const Color(0xFF16A34A)
        : (demande.statut == StatutDemande.terminee ? Colors.grey : const Color(0xFFE99D1A));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: couleur.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  StatutDemande.libelle(demande.statut),
                  style: TextStyle(color: couleur, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              if (demande.createdAt != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(demande.createdAt!),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              if (demande.estOuverte)
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 16,
                    tooltip: "Annuler cette demande",
                    icon: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
                    onPressed: () => _annuler(demande),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            demande.sujet.isEmpty ? TypeDemandeEcoute.libelle(demande.type) : demande.sujet,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            StatutDemande.message(demande.statut),
            style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaire() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "De quoi as-tu besoin ?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          ...TypeDemandeEcoute.libelles.entries.map(_buildChoixType),
          const SizedBox(height: 18),
          TextField(
            controller: _sujetController,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: _decoration("En un mot", "Ex. : un deuil difficile"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 5,
            maxLength: 1500,
            decoration: _decoration(
              "Ce que tu veux dire",
              "Tu peux en dire peu : l'essentiel est de faire le premier pas.",
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Comment veux-tu être recontacté ?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MoyenDeContact.libelles.entries
                .map((e) => _buildPuceContact(e.key, e.value))
                .toList(),
          ),
          if (MoyenDeContact.demandeUneCoordonnee(_moyenContact)) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _coordonneeController,
              keyboardType: _moyenContact == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              decoration: _decoration(
                _moyenContact == 'email' ? "Mon email" : "Mon numéro",
                _moyenContact == 'email' ? "prenom@exemple.com" : "+225 ...",
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _violet,
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
                      "Envoyer ma demande",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "L'équipe est composée de bénévoles : compte quelques jours. "
            "Ce n'est pas un service d'urgence.",
            style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildChoixType(MapEntry<String, String> entree) {
    final choisi = _type == entree.key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _type = entree.key),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: choisi ? const Color(0xFFF3F0FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: choisi ? _violet : const Color(0xFFE5E7EB),
              width: choisi ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                choisi ? Icons.check_circle : Icons.circle_outlined,
                size: 20,
                color: choisi ? _violet : Colors.grey.shade400,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entree.value,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TypeDemandeEcoute.descriptions[entree.key] ?? '',
                      style: const TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuceContact(String cle, String libelle) {
    final choisi = _moyenContact == cle;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _moyenContact = cle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: choisi ? _violet : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: choisi ? _violet : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          libelle,
          style: TextStyle(
            color: choisi ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      counterText: "",
      alignLabelWithHint: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _violet),
      ),
    );
  }

  Future<void> _envoyer() async {
    final message = _messageController.text.trim();
    if (message.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Écris quelques mots pour que l'équipe puisse t'aider."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (MoyenDeContact.demandeUneCoordonnee(_moyenContact) &&
        _coordonneeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Indique la coordonnée à laquelle te joindre."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _envoiEnCours = true);
    try {
      await _firestoreService.envoyerDemandeEcoute(
        _uid!,
        type: _type,
        sujet: _sujetController.text,
        message: message,
        moyenContact: _moyenContact,
        coordonnee: _coordonneeController.text,
      );

      if (!mounted) return;
      _sujetController.clear();
      _messageController.clear();
      _coordonneeController.clear();
      setState(() => _envoiEnCours = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Demande envoyée. Tu n'es pas seul 🙏"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _envoiEnCours = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Envoi impossible. Vérifie ta connexion."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _annuler(DemandeEcoute demande) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Annuler cette demande ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text("Elle sera retirée et l'équipe ne la verra plus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Garder", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Annuler la demande", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    await _firestoreService.annulerDemandeEcoute(demande.id);
  }
}
