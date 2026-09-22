import 'package:flutter/material.dart';

import '../models/bible_model.dart';
import '../services/bible_service.dart';

/// Lecture d'un livre, chapitre par chapitre.
class BibleLectureScreen extends StatefulWidget {
  final LivreBiblique livre;

  /// Chapitre à ouvrir d'emblée, quand on arrive depuis une référence.
  final int chapitreInitial;

  const BibleLectureScreen({
    super.key,
    required this.livre,
    this.chapitreInitial = 1,
  });

  @override
  State<BibleLectureScreen> createState() => _BibleLectureScreenState();
}

class _BibleLectureScreenState extends State<BibleLectureScreen> {
  static const Color _vert = Color(0xFF16A34A);

  late Future<LivreOuvert> _livre;
  late int _chapitre = widget.chapitreInitial;

  /// Le confort de lecture prime sur la densité : ce réglage ne touche qu'au
  /// texte biblique, pas à l'interface.
  double _taille = 16;

  @override
  void initState() {
    super.initState();
    _livre = BibleService.instance.ouvrir(widget.livre);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.livre.nom,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Taille du texte",
            icon: const Icon(Icons.text_fields, color: Colors.black54),
            onPressed: () =>
                setState(() => _taille = _taille >= 22 ? 14 : _taille + 2),
          ),
        ],
      ),
      body: FutureBuilder<LivreOuvert>(
        future: _livre,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _vert));
          }

          final ouvert = snapshot.data;
          if (ouvert == null || ouvert.chapitres.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "Ce livre n'a pas pu être ouvert.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final chapitre = ouvert.chapitres.firstWhere(
            (c) => c.numero == _chapitre,
            orElse: () => ouvert.chapitres.first,
          );

          return Column(
            children: [
              _buildChoixChapitre(ouvert),
              Expanded(child: _buildTexte(chapitre)),
              _buildNavigation(ouvert, chapitre),
            ],
          );
        },
      ),
    );
  }

  /// Bandeau des numéros de chapitre. Un livre d'un seul chapitre n'en a pas
  /// besoin : la bande n'aurait qu'un bouton.
  Widget _buildChoixChapitre(LivreOuvert ouvert) {
    if (ouvert.chapitres.length <= 1) return const SizedBox(height: 8);

    return Container(
      height: 46,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: ouvert.chapitres.length,
        itemBuilder: (context, i) {
          final numero = ouvert.chapitres[i].numero;
          final actif = numero == _chapitre;
          return GestureDetector(
            onTap: () => setState(() => _chapitre = numero),
            child: Container(
              width: 36,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: actif ? _vert : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$numero",
                style: TextStyle(
                  color: actif ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTexte(ChapitreBiblique chapitre) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(
          "Chapitre ${chapitre.numero}",
          style: const TextStyle(
            color: _vert,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 14),
        // Les versets se suivent dans un seul bloc, comme sur une page
        // imprimée : un verset par ligne hacherait la lecture continue.
        SelectableText.rich(
          TextSpan(
            children: [
              for (final verset in chapitre.versets) ...[
                TextSpan(
                  text: "${verset.numero} ",
                  style: TextStyle(
                    color: _vert,
                    fontSize: _taille * 0.7,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                ),
                TextSpan(
                  text: "${verset.texte} ",
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: _taille,
                    height: 1.8,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(LivreOuvert ouvert, ChapitreBiblique chapitre) {
    final index = ouvert.chapitres.indexOf(chapitre);
    final precedent = index > 0 ? ouvert.chapitres[index - 1].numero : null;
    final suivant = index < ouvert.chapitres.length - 1
        ? ouvert.chapitres[index + 1].numero
        : null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: precedent == null
                    ? null
                    : () => setState(() => _chapitre = precedent),
                icon: const Icon(Icons.arrow_back, size: 16, color: Colors.black54),
                label: const Text("Précédent",
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vert,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: suivant == null
                    ? null
                    : () => setState(() => _chapitre = suivant),
                icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                label: const Text("Suivant",
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
