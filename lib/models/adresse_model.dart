class Adresse {
  final String id;
  final String name;
  final String category;
  final String location;
  final String schedule;
  final String contact;

  Adresse({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.schedule,
    required this.contact,
  });

  factory Adresse.fromFirestore(Map<String, dynamic> data, String id) {
    return Adresse(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      schedule: data['schedule'] ?? '',
      contact: data['contact'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'schedule': schedule,
      'contact': contact,
    };
  }
}
