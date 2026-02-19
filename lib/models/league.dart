import 'package:ace_manager/models/user_profile.dart';

class League {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String? location;
  final bool isPublic;
  final String? logoUrl;

  League({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.location,
    this.isPublic = true,
    this.logoUrl,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String,
      location: json['location'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class LeagueMember {
  final String id;
  final String leagueId;
  final String userId;
  final String role; // 'owner', 'admin', 'player'
  final UserProfile? profile;

  LeagueMember({
    required this.id,
    required this.leagueId,
    required this.userId,
    required this.role,
    this.profile,
  });

  factory LeagueMember.fromJson(Map<String, dynamic> json) {
    UserProfile? profile;
    if (json['profiles'] != null) {
      profile = UserProfile.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return LeagueMember(
      id: json['id'] as String,
      leagueId: json['league_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      profile: profile,
    );
  }
}

class LeagueWithRole {
  final League league;
  final String role;

  LeagueWithRole({required this.league, required this.role});
}
