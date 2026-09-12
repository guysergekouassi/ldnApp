import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'acte_contrition_screen.dart';
import '../services/firestore_service.dart';
import '../models/examen_item_model.dart';
import '../models/confession_content_model.dart';

class PreparationConfessionScreen extends StatefulWidget {
  const PreparationConfessionScreen({Key? key}) : super(key: key);

  @override
  State<PreparationConfessionScreen> createState() => _PreparationConfessionScreenState();
}

class _PreparationConfessionScreenState extends State<PreparationConfessionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _firestoreService.checkAndInitializeExamenConscience();
    _firestoreService.checkAndInitializeConfessionContent();
  }

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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildIntroCard(),
                  const SizedBox(height: 20),
                  _buildExamenConscience(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
          height: 280,
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
                      "Confession",
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
                      "Prépare ton cœur au",
                      style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFE99D1A), Colors.orangeAccent],
                          ).createShader(bounds),
                          child: const Text(
                            "Pardon",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const Text(
                          " de Dieu",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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

  Widget _buildIntroCard() {
    return StreamBuilder<ConfessionContent?>(
      stream: _firestoreService.getConfessionContent(),
      builder: (context, snapshot) {
        final introText = snapshot.data?.introText.isNotEmpty == true
            ? snapshot.data!.introText
            : "Prends un moment de silence. L'examen de conscience t'aide à reconnaître tes péchés pour mieux les confier à la miséricorde de Dieu.";

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFE99D1A).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.info_outline, color: Color(0xFFE99D1A)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  introText,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamenConscience() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: StreamBuilder<List<ExamenItem>>(
        stream: _firestoreService.getExamenConscience(),
        builder: (context, itemsSnapshot) {
          if (itemsSnapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFE99D1A))),
            );
          }

          final items = itemsSnapshot.data ?? [];
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "Aucun point d'examen disponible pour le moment.",
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return StreamBuilder<List<String>>(
            stream: _uid != null ? _firestoreService.getExamenSelection(_uid!) : Stream.value(<String>[]),
            builder: (context, selectionSnapshot) {
              final checkedIds = selectionSnapshot.data ?? <String>[];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("EXAMEN DE CONSCIENCE", style: TextStyle(fontSize: 10, color: Color(0xFFE99D1A), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ..._buildCategory("Envers Dieu", items.where((i) => i.category == 'dieu').toList(), checkedIds),
                  ..._buildCategory("Envers mon prochain", items.where((i) => i.category == 'prochain').toList(), checkedIds),
                  ..._buildCategory("Envers moi-même", items.where((i) => i.category == 'soi').toList(), checkedIds),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE99D1A),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ActeContritionScreen(),
                          ),
                        );
                      },
                      child: const Text("Je suis prêt pour la Confession", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildCategory(String title, List<ExamenItem> items, List<String> checkedIds) {
    if (items.isEmpty) return [];
    return [
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      const SizedBox(height: 15),
      ...items.map((item) => _buildCheckItem(item, checkedIds.contains(item.id))),
      const SizedBox(height: 20),
    ];
  }

  Widget _buildCheckItem(ExamenItem item, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (_uid == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Connectez-vous pour sauvegarder votre examen."), backgroundColor: Colors.orange),
            );
            return;
          }
          _firestoreService.toggleExamenItem(_uid!, item.id, !isChecked);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? const Color(0xFFE99D1A) : Colors.white,
                border: Border.all(color: isChecked ? const Color(0xFFE99D1A) : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isChecked ? Colors.grey : Colors.black87,
                  decoration: isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
