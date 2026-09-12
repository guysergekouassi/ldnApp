import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';

class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Calendrier des événements", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<AppEvent>>(
        stream: _firestoreService.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun événement prévu.", style: TextStyle(color: Colors.grey)));
          }

          final events = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event.day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                          Text(event.month, style: const TextStyle(fontSize: 10, color: Colors.orange)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(event.time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(width: 10),
                              const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(child: Text(event.location, style: const TextStyle(color: Colors.grey, fontSize: 11), overflow: TextOverflow.ellipsis)),
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
        }
      ),
    );
  }
}
