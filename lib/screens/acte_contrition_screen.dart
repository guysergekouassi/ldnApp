import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/confession_content_model.dart';

class ActeContritionScreen extends StatefulWidget {
  const ActeContritionScreen({Key? key}) : super(key: key);

  @override
  State<ActeContritionScreen> createState() => _ActeContritionScreenState();
}


class _ActeContritionScreenState extends State<ActeContritionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isSaving = false;

  Future<void> _terminerConfession() async {
    if (_uid == null) {
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _firestoreService.enregistrerConfession(_uid!);
      await _firestoreService.validerJourDePriere(_uid!);
    } catch (e) {
      debugPrint("Erreur enregistrement confession: $e");
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Confession enregistrée. Que la paix du Christ soit avec toi 🙏"), backgroundColor: Color(0xFFE99D1A)),
    );
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<ConfessionContent?>(
        stream: _firestoreService.getConfessionContent(),
        builder: (context, snapshot) {
          final content = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: CircularProgressIndicator(color: Color(0xFFE99D1A)),
                        )
                      else ...[
                        _buildStepsCard(content),
                        const SizedBox(height: 20),
                        _buildActeContritionCard(content),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE99D1A),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          onPressed: _isSaving ? null : _terminerConfession,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text("J'ai terminé ma confession", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/sunset_bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          // Hauteur minimale et non figée : avec un texte agrandi par les
          // réglages système, le contenu débordait de l'en-tête.
          constraints: const BoxConstraints(minHeight: 280),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
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
                      "La Confession",
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
                      "Dans le",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE99D1A), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "Confessionnal",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _buildStepsCard(ConfessionContent? content) {
    final steps = content?.steps ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text("DÉROULEMENT", style: TextStyle(fontSize: 10, color: Color(0xFFE99D1A), fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (steps.isEmpty)
            const Text("Aucune étape disponible pour le moment.", style: TextStyle(color: Colors.grey))
          else
            ...steps.map((step) => _buildStepRow(step.number, step.title, step.description)),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFE99D1A),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActeContritionCard(ConfessionContent? content) {
    final title = content?.acteTitle.isNotEmpty == true ? content!.acteTitle : "Acte de Contrition";
    final intro = content?.acteIntro ?? "";
    final texte = content?.acteText ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE99D1A).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE99D1A).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE99D1A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.favorite, color: Color(0xFFE99D1A), size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (intro.isNotEmpty) ...[
            Text(
              intro,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 15),
          ],
          Text(
            texte.isNotEmpty ? texte : "Aucun texte disponible pour le moment.",
            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.6, fontWeight: FontWeight.w500),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
