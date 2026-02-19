class SessionCreationData {
  String? leagueId;
  
  // Step 1: Basic Info
  String? name;
  DateTime? startDate;
  DateTime? endDate;
  String? location; // Club

  // Step 2: Format & Rules
  String? gameType; // 'Singles', 'Doubles'
  String? format; // 'Round Robin', 'Ladder'
  String? rules;
  bool courtPromotion = false;

  // Step 3: Members
  List<String> selectedMemberIds = [];

  SessionCreationData({
    this.leagueId,
    this.name,
    this.startDate,
    this.endDate,
    this.location,
    this.gameType,
    this.format,
    this.rules,
    this.courtPromotion = false,
  });
}
