import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/intention_model.dart';
import 'create_intention_screen.dart';

class AllIntentionsScreen extends StatefulWidget {
  const AllIntentionsScreen({Key? key}) : super(key: key);

  @override
  State<AllIntentionsScreen> createState() => _AllIntentionsScreenState();
}

class _AllIntentionsScreenState extends State<AllIntentionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _basculerEpingle(Intention intention) async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connecte-toi pour épingler une intention."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final epingle = await _firestoreService.togglePinIntention(_uid!, intention.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(epingle
            ? "Intention épinglée : elle reste en tête de ta liste 📌"
            : "Intention désépinglée."),
        backgroundColor: epingle ? Colors.orange : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Mur des intentions", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateIntentionScreen()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<Set<String>>(
        stream: _uid != null
            ? _firestoreService.getPinnedIntentionIds(_uid!)
            : Stream.value(<String>{}),
        builder: (context, epingleesSnapshot) {
          final epinglees = epingleesSnapshot.data ?? <String>{};

          return StreamBuilder<List<Intention>>(
        stream: _firestoreService.getIntentions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune intention pour le moment.", style: TextStyle(color: Colors.grey)));
          }

          // Les intentions épinglées remontent en tête du mur.
          final intentions = FirestoreService.trierAvecEpinglees(snapshot.data!, epinglees);

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: intentions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final intention = intentions[index];
              final color = Color(int.parse(intention.colorHex.replaceFirst('#', '0xFF')));
              final estEpinglee = epinglees.contains(intention.id);

              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // Liseré orangé : repère visuel des intentions épinglées.
                  border: estEpinglee ? Border.all(color: Colors.orange, width: 1.5) : null,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pan_tool_outlined, color: color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            intention.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            tooltip: estEpinglee ? "Désépingler" : "Épingler cette intention",
                            icon: Icon(
                              estEpinglee ? Icons.push_pin : Icons.push_pin_outlined,
                              size: 20,
                              color: estEpinglee ? Colors.orange : Colors.grey.shade400,
                            ),
                            onPressed: () => _basculerEpingle(intention),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      intention.description,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 18),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  "${intention.count} prières",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _firestoreService.incrementIntentionCount(intention.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Merci de prier pour cette intention !"), backgroundColor: Colors.green),
                            );
                          },
                          icon: const Icon(Icons.pan_tool_outlined, size: 14, color: Colors.white),
                          label: const Text("Prier", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }
      );
        },
      ),
    );
  }
}
