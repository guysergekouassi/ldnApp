class Fraternity {
  final String id;
  final String name;
  final String location;
  final int memberCount;
  final String nextMeetingDate;
  final String nextMeetingLocation;

  Fraternity({
    required this.id,
    required this.name,
    required this.location,
    required this.memberCount,
    required this.nextMeetingDate,
    required this.nextMeetingLocation,
  });

  factory Fraternity.fromFirestore(Map<String, dynamic> data, String id) {
    return Fraternity(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      memberCount: data['memberCount'] ?? 0,
      nextMeetingDate: data['nextMeetingDate'] ?? '',
      nextMeetingLocation: data['nextMeetingLocation'] ?? '',
    );
  }
}
