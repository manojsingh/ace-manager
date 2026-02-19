class Court {
  final String id;
  final String clubId;
  final String name;
  final String surfaceType;
  final DateTime? createdAt;

  Court({
    required this.id,
    required this.clubId,
    required this.name,
    required this.surfaceType,
    this.createdAt,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as String,
      clubId: json['club_id'] as String,
      name: json['name'] as String,
      surfaceType: json['surface_type'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'name': name,
      'surface_type': surfaceType,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
