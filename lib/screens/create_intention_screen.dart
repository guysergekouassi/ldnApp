import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class CreateIntentionScreen extends StatefulWidget {
  const CreateIntentionScreen({Key? key}) : super(key: key);

  @override
  State<CreateIntentionScreen> createState() => _CreateIntentionScreenState();
}

class _CreateIntentionScreenState extends State<CreateIntentionScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _submitIntention() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    if (title.isEmpty || description.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.addIntention(title, description);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intention confiée avec succès !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
        title: const Text("Confier une intention", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : _submitIntention,
              child: _isLoading 
                  ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Envoyer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quelle est votre intention de prière ?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                controller: _titleController,
                maxLength: 50,
                decoration: const InputDecoration(
                  hintText: "Titre (ex: Guérison, Examen, Paix...)",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  counterText: "",
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                controller: _descController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Décrivez brièvement votre intention afin que la communauté puisse prier pour vous...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "La communauté s'engage à vous porter dans ses prières.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
