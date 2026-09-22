import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/demande_ecoute_model.dart';
import '../services/firestore_service.dart';

/// Les demandes d'écoute, vues par un responsable de la communauté.
///
/// Cet écran n'est atteignable que par ceux qui ont un document dans `admins`,
/// et les règles Firestore appliquent la même condition : cacher le bouton ne
/// suffirait pas à protéger des confidences.
class AdminDemandesScreen extends StatefulWidget {
  const AdminDemandesScreen({super.key});

  @override
  State<AdminDemandesScreen> createState() => _AdminDemandesScreenState();
}

class _AdminDemandesScreenState extends State<AdminDemandesScreen> {
  static const Color _violet = Color(0xFF5B4FC8);

  final FirestoreService _firestoreService = FirestoreService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Quand il est vrai, les demandes closes sont masquées : ce qui attend une
  /// réponse ne doit pas se noyer dans l'historique.
  bool _seulementOuvertes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Demandes d'écoute",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<DemandeEcoute>>(
        stream: _firestoreService.getToutesLesDemandesEcoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _violet));
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "Ces demandes ne te sont pas accessibles.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final toutes = snapshot.data ?? const <DemandeEcoute>[];
          final ouvertes = toutes.where((d) => d.estOuverte).length;
          final affichees =
              _seulementOuvertes ? toutes.where((d) => d.estOuverte).toList() : toutes;

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              _buildEntete(toutes.length, ouvertes),
              const SizedBox(height: 14),
              _buildFiltre(toutes.length - ouvertes),
              const SizedBox(height: 12),
              if (affichees.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Text(
                    toutes.isEmpty
                        ? "Aucune demande pour le moment."
                        : "Aucune demande en attente. Tout est traité.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ...affichees.map(_buildDemande),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEntete(int total, int ouvertes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: _violet, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == 0
                  ? "Personne n'a encore déposé de demande."
                  : ouvertes == 0
                      ? "$total demande${total > 1 ? 's' : ''}, toutes traitées."
                      : "$ouvertes demande${ouvertes > 1 ? 's' : ''} en attente. "
                          "Quelqu'un attend une réponse de l'autre côté.",
              style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltre(int closes) {
    if (closes == 0) return const SizedBox.shrink();

    return Row(
      children: [
        Switch(
          value: _seulementOuvertes,
          activeColor: _violet,
          onChanged: (valeur) => setState(() => _seulementOuvertes = valeur),
        ),
        const Expanded(
          child: Text(
            "Masquer les demandes closes",
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDemande(DemandeEcoute demande) {
    final coordonnee = demande.coordonnee;
    final date = demande.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: demande.statut == StatutDemande.envoyee
            ? Border.all(color: _violet.withOpacity(0.35))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TypeDemandeEcoute.libelle(demande.type),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
              ),
              _buildEtiquetteStatut(demande.statut),
            ],
          ),
          if (date != null) ...[
            const SizedBox(height: 3),
            Text(
              DateFormat("d MMMM y 'à' HH'h'mm", 'fr_FR').format(date),
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
          if (demande.sujet.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              demande.sujet,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            demande.message,
            style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.contact_phone_outlined, size: 14, color: _violet),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    coordonnee.isEmpty
                        ? MoyenDeContact.libelle(demande.moyenContact)
                        : "${MoyenDeContact.libelle(demande.moyenContact)} · $coordonnee",
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildActions(demande),
        ],
      ),
    );
  }

  Widget _buildEtiquetteStatut(String statut) {
    final couleur = statut == StatutDemande.terminee
        ? Colors.grey
        : statut == StatutDemande.priseEnCharge
            ? const Color(0xFF16A34A)
            : _violet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        StatutDemande.libelle(statut),
        style: TextStyle(color: couleur, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActions(DemandeEcoute demande) {
    if (demande.statut == StatutDemande.terminee) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => _changer(demande, StatutDemande.priseEnCharge),
          child: const Text("Rouvrir", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
      );
    }

    return Row(
      children: [
        if (demande.statut == StatutDemande.envoyee)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _violet,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _changer(demande, StatutDemande.priseEnCharge),
              child: const Text(
                "Je m'en occupe",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (demande.statut == StatutDemande.priseEnCharge)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _changer(demande, StatutDemande.terminee),
              child: const Text(
                "Clôturer",
                style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _changer(DemandeEcoute demande, String statut) async {
    try {
      await _firestoreService.changerStatutDemande(
        demandeId: demande.id,
        statut: statut,
        parUid: _uid,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le changement n'a pas pu être enregistré.")),
      );
    }
  }
}
