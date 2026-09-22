import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/neuvaine_model.dart';
import 'neuvaines_screen.dart';

class NeuvainesListScreen extends StatefulWidget {
  const NeuvainesListScreen({Key? key}) : super(key: key);

  @override
  State<NeuvainesListScreen> createState() => _NeuvainesListScreenState();
}

class _NeuvainesListScreenState extends State<NeuvainesListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  /// Intention sélectionnée, ou null pour « Toutes ».
  String? _intentionFiltre;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: StreamBuilder<List<Neuvaine>>(
                stream: _firestoreService.getNeuvaines(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Une erreur est survenue.", style: TextStyle(color: Colors.red)),
                    );
                  }

                  final neuvaines = snapshot.data ?? [];

                  if (neuvaines.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        "Aucune neuvaine disponible pour le moment.\nReviens bientôt !",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  // On ne propose que les intentions réellement présentes :
                  // un filtre qui ne renvoie rien est pire que pas de filtre.
                  final intentionsDisponibles = <String>{
                    for (final n in neuvaines) ...n.intentions,
                  }.toList()
                    ..sort((a, b) => NeuvaineTaxonomie.libelleIntention(a)
                        .compareTo(NeuvaineTaxonomie.libelleIntention(b)));

                  final visibles = _intentionFiltre == null
                      ? neuvaines
                      : neuvaines
                          .where((n) => n.intentions.contains(_intentionFiltre))
                          .toList();

                  return Column(
                    children: [
                      const SizedBox(height: 20),
                      if (intentionsDisponibles.length > 1)
                        _buildFiltres(intentionsDisponibles),
                      if (visibles.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            "Aucune neuvaine pour cette intention.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        )
                      else
                        ...visibles.map((neuvaine) => _buildNeuvaineCard(context, neuvaine)),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chips d'intention. Défilement horizontal : la liste s'allongera avec le
  /// catalogue, et doit tenir sur un écran étroit sans déborder.
  Widget _buildFiltres(List<String> intentions) {
    Widget chip(String label, String? valeur) {
      final actif = _intentionFiltre == valeur;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: actif ? FontWeight.bold : FontWeight.normal,
            color: actif ? Colors.white : const Color(0xFF0F172A),
          )),
          selected: actif,
          onSelected: (_) => setState(() => _intentionFiltre = actif ? null : valeur),
          selectedColor: Colors.orange,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: actif ? Colors.orange : Colors.grey.shade300),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            chip("Toutes", null),
            for (final i in intentions)
              chip(NeuvaineTaxonomie.libelleIntention(i), i),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mary_praying.png"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          // Hauteur minimale et non figée : avec un texte agrandi par les
          // réglages système, le contenu débordait de l'en-tête.
          constraints: const BoxConstraints(minHeight: 250),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.4),
                const Color(0xFFF8F9FA),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Text(
                      "Neuvaines",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                    ),
                    Container(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Parcours Spirituel",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Prier pendant ",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.orange, Colors.redAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "9 jours",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeuvaineCard(BuildContext context, Neuvaine neuvaine) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirestoreService().getNeuvaineProgress(neuvaine.id),
      builder: (context, snapshot) {
        bool isCompleted = false;
        if (snapshot.hasData) {
          isCompleted = snapshot.data!['isCompleted'] ?? false;
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NeuvainesScreen(neuvaine: neuvaine),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    'assets/sunset_bg.jpg', // Placeholder
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              neuvaine.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    "Terminée",
                                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "9 Jours",
                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        neuvaine.subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        neuvaine.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
