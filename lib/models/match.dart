
class LeagueMatch {
  final String id;
  final String sessionId;
  final DateTime date;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String? score;
  final String? winnerId;
  final List<MatchParticipant> participants;

  LeagueMatch({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.status,
    this.score,
    this.winnerId,
    this.participants = const [],
  });

  factory LeagueMatch.fromJson(Map<String, dynamic> json) {
    var participantsList = <MatchParticipant>[];
    if (json['match_participants'] != null) {
      participantsList = (json['match_participants'] as List)
          .map((p) => MatchParticipant.fromJson(p))
          .toList();
    }

    return LeagueMatch(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      score: json['score'] as String?,
      winnerId: json['winner_id'] as String?,
      participants: participantsList,
    );
  }
}

class MatchParticipant {
  final String id;
  final String matchId;
  final String userId;
  final int? teamId;
  final String? userEmail; // For display, likely fetched via join
  final String? userName;  // For display

  MatchParticipant({
    required this.id,
    required this.matchId,
    required this.userId,
    this.teamId,
    this.userEmail,
    this.userName,
  });

  factory MatchParticipant.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data if available
    String? email;
    String? name;
    
    if (json['profiles'] != null) {
      final profile = json['profiles'];
      email = profile['email'];
      name = profile['first_name'] != null 
          ? '${profile['first_name']} ${profile['last_name'] ?? ''}'.trim() 
          : null;
    }

    return MatchParticipant(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      userId: json['user_id'] as String,
      teamId: json['team_id'] as int?,
      userEmail: email,
      userName: name,
    );
  }
}
