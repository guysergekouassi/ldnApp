import 'package:flutter/material.dart';

import '../components/ldn_signature.dart';
import '../models/bible_model.dart';
import '../services/bible_service.dart';
import 'bible_lecture_screen.dart';

/// Sommaire de la Bible : les 73 livres, Ancien puis Nouveau Testament.
class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  static const Color _vert = Color(0xFF16A34A);

  late Future<List<LivreBiblique>> _livres;
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _livres = BibleService.instance.sommaire();
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
          "La Bible",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<LivreBiblique>>(
        future: _livres,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _vert));
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "La Bible n'a pas pu être ouverte.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final tous = snapshot.data ?? const <LivreBiblique>[];
          final livres = _filtrer(tous);
          final ancien = livres.where((l) => l.estAncienTestament).toList();
          final nouveau = livres.where((l) => !l.estAncienTestament).toList();

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              _buildRecherche(),
              const SizedBox(height: 16),
              if (livres.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Aucun livre ne porte ce nom.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              if (ancien.isNotEmpty) ...[
                _buildTitre("Ancien Testament", ancien.length),
                ...ancien.map(_buildLivre),
                const SizedBox(height: 10),
              ],
              if (nouveau.isNotEmpty) ...[
                _buildTitre("Nouveau Testament", nouveau.length),
                ...nouveau.map(_buildLivre),
              ],
              const SizedBox(height: 20),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Traduction Augustin Crampon, édition de 1923.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const LdnSignature(),
            ],
          );
        },
      ),
    );
  }

  List<LivreBiblique> _filtrer(List<LivreBiblique> livres) {
    final cherche = _recherche.trim().toLowerCase();
    if (cherche.isEmpty) return livres;
    return livres
        .where((l) =>
            l.nom.toLowerCase().contains(cherche) ||
            l.abbr.toLowerCase().contains(cherche))
        .toList();
  }

  Widget _buildRecherche() {
    return TextField(
      onChanged: (valeur) => setState(() => _recherche = valeur),
      decoration: InputDecoration(
        hintText: "Chercher un livre…",
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
          borderSide: const BorderSide(color: _vert),
        ),
      ),
    );
  }

  Widget _buildTitre(String libelle, int nombre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Text(
            libelle.toUpperCase(),
            style: const TextStyle(
              color: _vert,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$nombre livres",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLivre(LivreBiblique livre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            livre.abbr,
            style: const TextStyle(color: _vert, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(
          livre.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
        ),
        subtitle: Text(
          livre.nombreDeChapitres == 1
              ? "${livre.nombreDeVersets} versets"
              : "${livre.nombreDeChapitres} chapitres",
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BibleLectureScreen(livre: livre)),
        ),
      ),
    );
  }
}
