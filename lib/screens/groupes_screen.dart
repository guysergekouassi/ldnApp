import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/ldn_signature.dart';
import '../models/fraternity_model.dart';
import '../services/firestore_service.dart';

/// Annuaire des groupes locaux : « Rejoins un groupe ».
class GroupesScreen extends StatefulWidget {
  const GroupesScreen({Key? key}) : super(key: key);

  @override
  State<GroupesScreen> createState() => _GroupesScreenState();
}

class _GroupesScreenState extends State<GroupesScreen> {
  static const Color _violet = Color(0xFF5B4FC8);

  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  /// Clé de [TypeGroupe.libelles], ou null pour « tous ».
  String? _filtre;

  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Rejoins un groupe",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<String?>(
        stream: _uid != null
            ? _firestoreService.getMonGroupeId(_uid!)
            : Stream.value(null),
        builder: (context, monGroupeSnapshot) {
          final monGroupeId = monGroupeSnapshot.data;

          return StreamBuilder<List<Fraternity>>(
            stream: _firestoreService.getGroupes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _violet));
              }

              final tous = snapshot.data ?? <Fraternity>[];
              final groupes = _filtrer(tous);

              return ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  _buildIntro(tous.length),
                  const SizedBox(height: 14),
                  _buildRecherche(),
                  const SizedBox(height: 12),
                  _buildFiltres(tous),
                  const SizedBox(height: 16),
                  if (groupes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        "Aucun groupe ne correspond à ta recherche.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...groupes.map((g) => _buildGroupeCard(g, g.id == monGroupeId)),
                  const LdnSignature(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Fraternity> _filtrer(List<Fraternity> groupes) {
    final recherche = _recherche.trim().toLowerCase();

    return groupes.where((g) {
      if (_filtre != null && g.type != _filtre) return false;
      if (recherche.isEmpty) return true;
      // La recherche porte sur le nom et sur le lieu : c'est ce qu'on tape
      // quand on cherche « un groupe à Cocody ».
      return g.name.toLowerCase().contains(recherche) ||
          g.location.toLowerCase().contains(recherche);
    }).toList();
  }

  Widget _buildIntro(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_outlined, color: _violet, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total == 0
                  ? "L'annuaire des groupes se remplit. Reviens dans un instant."
                  : "$total groupes t'attendent. On ne grandit pas seul dans la foi : "
                      "rejoins celui qui te correspond, tu peux en changer à tout moment.",
              style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecherche() {
    return TextField(
      onChanged: (valeur) => setState(() => _recherche = valeur),
      decoration: InputDecoration(
        hintText: "Chercher un groupe ou une ville…",
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _violet),
        ),
      ),
    );
  }

  Widget _buildFiltres(List<Fraternity> groupes) {
    // On ne propose que les familles réellement présentes dans l'annuaire :
    // un filtre qui ne renvoie jamais rien n'aide personne.
    final types = groupes.map((g) => g.type).where((t) => t.isNotEmpty).toSet().toList()
      ..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPuce("Tous", _filtre == null, () => setState(() => _filtre = null)),
          ...types.map(
            (type) => _buildPuce(
              TypeGroupe.libelle(type),
              _filtre == type,
              () => setState(() => _filtre = _filtre == type ? null : type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuce(String libelle, bool actif, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: actif ? _violet : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: actif ? _violet : const Color(0xFFE5E7EB)),
          ),
          child: Text(
            libelle,
            style: TextStyle(
              color: actif ? Colors.white : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupeCard(Fraternity groupe, bool estLeMien) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: estLeMien ? Border.all(color: _violet, width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icone(TypeGroupe.icone(groupe.type)), color: _violet, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            groupe.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (estLeMien)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _violet,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Mon groupe",
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (groupe.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              groupe.description,
              style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: _violet),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  groupe.nextMeetingDate.isEmpty ? "Rencontres à venir" : groupe.nextMeetingDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ),
            ],
          ),
          if (groupe.nextMeetingLocation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 12, color: _violet),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    groupe.nextMeetingLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                groupe.memberCount == 0
                    ? "Sois le premier à rejoindre"
                    : "${groupe.memberCount} membre${groupe.memberCount > 1 ? 's' : ''}",
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (estLeMien)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 34),
                  ),
                  onPressed: () => _quitter(groupe),
                  child: const Text(
                    "Quitter",
                    style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              else if (!groupe.ouvert)
                const Text(
                  "Complet",
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _violet,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    minimumSize: const Size(0, 34),
                  ),
                  onPressed: () => _rejoindre(groupe),
                  child: const Text(
                    "Rejoindre",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rejoindre(Fraternity groupe) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour rejoindre un groupe."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final rejoint = await _firestoreService.rejoindreGroupe(_uid!, groupe);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(rejoint
            ? "Bienvenue dans « ${groupe.name} » 🙌"
            : "Tu fais déjà partie de ce groupe."),
        backgroundColor: rejoint ? Colors.green : Colors.orange,
      ),
    );
  }

  Future<void> _quitter(Fraternity groupe) async {
    if (_uid == null) return;

    final confirme = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Quitter ce groupe ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Tu ne verras plus les rencontres de "${groupe.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Rester", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Quitter", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirme != true) return;
    await _firestoreService.quitterGroupe(_uid!, groupe.id);
  }

  IconData _icone(String nom) {
    switch (nom) {
      case 'people_outline':
        return Icons.people_outline;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      case 'handshake_outlined':
        return Icons.handshake_outlined;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.groups_outlined;
    }
  }
}
