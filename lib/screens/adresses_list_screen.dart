import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/adresse_model.dart';

class AdressesListScreen extends StatelessWidget {
  final String category;

  AdressesListScreen({Key? key, required this.category}) : super(key: key);

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(category, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: StreamBuilder<List<Adresse>>(
        stream: _firestoreService.getAddresses(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Aucune adresse pour la catégorie $category.", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final adresses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: adresses.length,
            itemBuilder: (context, index) {
              final adresse = adresses[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category == 'Paroisses' ? Icons.church_outlined : 
                        category == 'Librairies' ? Icons.menu_book : Icons.place_outlined,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(adresse.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 5),
                              Expanded(child: Text(adresse.location, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.grey),
                              const SizedBox(width: 5),
                              Expanded(child: Text(adresse.schedule, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 5),
                              Expanded(child: Text(adresse.contact, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
