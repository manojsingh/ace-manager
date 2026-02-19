class LeagueSession {
  final String id;
  final String leagueId;
  final String? name; // Added name
  final DateTime startDate; // Added startDate
  final DateTime? endDate; // Added endDate
  final String? status; // Added status
  final String? format; // 'Round Robin', 'Ladder'
  final String? gameType; // 'Singles', 'Doubles'
  final String? rules;
  final bool courtPromotion;
  final List<DateTime> roundDates; // Added roundDates

  LeagueSession({
    required this.id,
    required this.leagueId,
    this.name,
    required this.startDate,
    this.endDate,
    this.status,
    this.format,
    this.gameType,
    this.rules,
    this.courtPromotion = false,
    this.roundDates = const [],
  });

  factory LeagueSession.fromJson(Map<String, dynamic> json) {
    return LeagueSession(
      id: json['id'] as String,
      leagueId: json['league_id'] as String,
      name: json['name'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      status: json['status'] as String? ?? 'upcoming',
      format: json['format'] as String?,
      gameType: json['game_type'] as String?,
      rules: json['rules'] as String?,
      courtPromotion: json['court_promotion'] as bool? ?? false,
      roundDates: json['round_dates'] != null
          ? (json['round_dates'] as List).map((e) => DateTime.parse(e as String)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'league_id': leagueId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'format': format,
      'game_type': gameType,
      'rules': rules,
      'court_promotion': courtPromotion,
      'round_dates': roundDates.map((e) => e.toIso8601String()).toList(),
    };
  }
}
