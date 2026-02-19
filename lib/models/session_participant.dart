import 'package:ace_manager/models/user_profile.dart';

class SessionParticipant {
  final String id;
  final String sessionId;
  final String userId;
  final String status;
  final DateTime joinedAt;
  final int points;
  final int wins;
  final int losses;
  final int matchesPlayed;
  final UserProfile? profile;
  final Map<String, String> availability;

  SessionParticipant({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.points = 0,
    this.wins = 0,
    this.losses = 0,
    this.matchesPlayed = 0,
    this.profile,
    this.availability = const {},
  });

  factory SessionParticipant.fromJson(Map<String, dynamic> json) {
    UserProfile? profile;
    if (json['profiles'] != null) {
      profile = UserProfile.fromJson(json['profiles'] as Map<String, dynamic>);
    }

    return SessionParticipant(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String? ?? 'active',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      points: json['points'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      matchesPlayed: json['matches_played'] as int? ?? 0,
      profile: profile,
      availability: json['availability'] != null
          ? Map<String, String>.from(json['availability'] as Map)
          : {},
    );
  }

}
