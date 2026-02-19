class Club {
  final String id;
  final String name;
  final String location;
  final int courtCount;
  final String? imageUrl;
  final DateTime? createdAt;

  Club({
    required this.id,
    required this.name,
    required this.location,
    required this.courtCount,
    this.imageUrl,
    this.createdAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      courtCount: json['court_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'court_count': courtCount,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
