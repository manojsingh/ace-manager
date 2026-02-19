import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/models/match.dart';
import 'package:ace_manager/models/session_participant.dart';

class LeagueDashboardData {
  final League league;
  final String userRole;
  final LeagueSession? activeSession;
  final SessionParticipant? userStats;
  final LeagueMatch? nextMatch;

  LeagueDashboardData({
    required this.league,
    required this.userRole,
    this.activeSession,
    this.userStats,
    this.nextMatch,
  });
}
