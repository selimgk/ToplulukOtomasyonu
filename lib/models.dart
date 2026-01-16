
class Event {
  final int? id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String location;
  final String? status; // 'pending', 'approved', 'rejected'
  final String? communityName; // New field

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
    this.status = 'pending',
    this.communityName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'location': location,
      'status': status,
      'communityName': communityName,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      status: map['status'] ?? 'pending',
      communityName: map['communityName'],
    );
  }
}

class Rsvp {
  final int? id;
  final int eventId;
  final String name;
  final String department;
  final String grade;
  final DateTime timestamp;
  final String status; // 'pending', 'confirmed', 'rejected'

  Rsvp({
    this.id,
    required this.eventId,
    required this.name,
    required this.department,
    required this.grade,
    required this.timestamp,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'department': department,
      'grade': grade,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory Rsvp.fromMap(Map<String, dynamic> map) {
    return Rsvp(
      id: map['id'],
      eventId: map['eventId'],
      name: map['name'],
      department: map['department'],
      grade: map['grade'],
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'] ?? 'pending',
    );
  }
}

class Community {
  final int? id;
  final String name;
  final String description;
  final String? image;
  final String? president;
  final int memberCount;
  final String? category;

  Community({
    this.id,
    required this.name,
    required this.description,
    this.image,
    this.president,
    this.memberCount = 0,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'president': president,
      'memberCount': memberCount,
      'category': category,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      image: map['image'],
      president: map['president'],
      memberCount: map['memberCount'] ?? 0,
      category: map['category'],
    );
  }
}
