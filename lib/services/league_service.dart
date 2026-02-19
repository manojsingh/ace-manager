// Force re-analysis
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/models/user_profile.dart';
import 'package:ace_manager/models/match.dart';
import 'package:ace_manager/models/session_participant.dart';
import 'package:intl/intl.dart';

import 'package:ace_manager/models/league_dashboard_data.dart';

class LeagueService {
  final SupabaseClient _client;

  LeagueService(this._client);

  static final LeagueService instance = LeagueService(Supabase.instance.client);

  Future<List<LeagueDashboardData>> getDashboardData() async {
    final leaguesWithRole = await getMyLeagues();
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    List<LeagueDashboardData> dashboardData = [];

    for (var lwr in leaguesWithRole) {
      // 1. Get active session (or most recent)
      // leveraging simple query for now, ideal would be RPC or join
      final sessions = await getLeagueSessions(lwr.league.id);
      
      LeagueSession? activeSession;
      SessionParticipant? userStats;
      LeagueMatch? nextMatch;

      if (sessions.isNotEmpty) {
        // Prefer 'active' session, else first one (most recent by date sorting in getLeagueSessions)
        activeSession = sessions.firstWhere(
          (s) => s.status == 'active',
          orElse: () => sessions.first,
        );

        if (activeSession != null) {
          // 2. Get User Stats (Rank)
          userStats = await getUserSessionStats(activeSession.id, userId);

          // 3. Get Next Match (where user is participant and status is scheduled)
          // This requires a new query or helper
          nextMatch = await _getNextMatchForUser(activeSession.id, userId);
        }
      }

      dashboardData.add(LeagueDashboardData(
        league: lwr.league,
        userRole: lwr.role,
        activeSession: activeSession,
        userStats: userStats,
        nextMatch: nextMatch,
      ));
    }

    return dashboardData;
  }

  Future<LeagueMatch?> _getNextMatchForUser(String sessionId, String userId) async {
    try {
      // Find matches where user is a participant
      // This is tricky with simple selects because match_participants is a join table
      // Easier to fetch all matches for session and filter in memory if list is small, 
      // OR use a specific RPC/Query. 
      // For MVP, capturing "matches" table where session_id match, and checking participants via separate call or embedded join
      
      // Let's rely on getSessionMatches and filter in memory for now (simpler, less SQL risk)
      final allMatches = await getSessionMatches(sessionId);
      final now = DateTime.now();

      // Filter for matches involving user that are in future
      final userMatches = allMatches.where((m) {
        final isParticipant = m.participants.any((p) => p.userId == userId);
        final isFuture = m.date.isAfter(now);
        final isScheduled = m.status != 'completed'; // assuming status check
        return isParticipant && isFuture && isScheduled;
      }).toList();

      if (userMatches.isEmpty) return null;
      
      // Sort by date (nearest first)
      userMatches.sort((a, b) => a.date.compareTo(b.date));
      return userMatches.first;
    } catch (e) {
      return null;
    }
  }

  Future<List<LeagueWithRole>> getMyLeagues() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // Step 1: Fetch all league memberships for the user
      final membersResponse = await _client
          .from('league_members')
          .select()
          .eq('user_id', userId);

      final membersData = membersResponse as List<dynamic>;
      if (membersData.isEmpty) return [];

      // Step 2: Extract league IDs and roles
      final leagueIds = membersData.map((m) => m['league_id'] as String).toList();
      final rolesMap = {for (var m in membersData) m['league_id'] as String: m['role'] as String};

      // Step 3: Fetch the actual leagues
      final leaguesResponse = await _client
          .from('leagues')
          .select()
          .filter('id', 'in', leagueIds);

      final leaguesData = leaguesResponse as List<dynamic>;

      // Step 4: Combine
      return leaguesData.map((json) {
        final league = League.fromJson(json);
        final role = rolesMap[league.id] ?? 'member';
        return LeagueWithRole(
          league: league,
          role: role,
        );
      }).toList();
    } catch (e) {
      // Return empty list on error for now
      debugPrint('Error fetching leagues: $e');
      return [];
    }
  }

  Future<League> createLeague({
    required String name,
    String? description,
    String? location,
    bool isPublic = true,
    String? logoUrl,
  }) async {
    // Use RPC for atomic creation and avoiding RLS issues
    final response = await _client.rpc('create_league_v2', params: {
      'p_name': name,
      'p_description': description,
      'p_location': location,
      'p_is_public': isPublic,
      'p_logo_url': logoUrl,
    }); // response is already a Map<String, dynamic> (json)

    return League.fromJson(response);
  }

  Future<List<LeagueMember>> getLeagueMembers(String leagueId) async {
    try {
      final response = await _client
          .from('league_members')
          .select('*, profiles(*)')
          .eq('league_id', leagueId);

      final data = response as List<dynamic>;
      return data.map((json) => LeagueMember.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateMemberRole(String memberId, String newRole) async {
    await _client.from('league_members').update({'role': newRole}).eq('id', memberId);
  }
  
  Future<List<LeagueSession>> getLeagueSessions(String leagueId) async {
    try {
      final response = await _client
          .from('league_sessions')
          .select()
          .eq('league_id', leagueId)
          .order('start_date', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => LeagueSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<LeagueSession> createSession({
    required String leagueId,
    required String name,
    required DateTime startDate,
    required DateTime? endDate,
    required String? format,
    required String? gameType,
    required String? rules,
    required bool courtPromotion,
    required List<String> participantIds,
  }) async {
    final response = await _client.rpc('create_league_session_with_participants', params: {
      'p_league_id': leagueId,
      'p_name': name,
      'p_start_date': startDate.toIso8601String(),
      'p_end_date': endDate?.toIso8601String(),
      'p_format': format,
      'p_game_type': gameType,
      'p_rules': rules,
      'p_court_promotion': courtPromotion,
      'p_participant_ids': participantIds,
    });

    return LeagueSession.fromJson(response);
  }

  Future<void> updateSessionSchedule(String sessionId, List<DateTime> roundDates) async {
    try {
      final datesPayload = roundDates.map((e) => e.toIso8601String()).toList();
      
      // Call the secure RPC (Remote Procedure Call)
      await _client.rpc('update_session_schedule', params: {
        'p_session_id': sessionId,
        'p_round_dates': datesPayload,
      });
    } catch (e) {
      debugPrint('Error updating session schedule: $e');
      rethrow;
    }
  }


  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final response = await _client.from('profiles').select().order('first_name', ascending: true);
      debugPrint('Profiles response: $response');
      final data = response as List<dynamic>;
      return data.map((json) => UserProfile.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching profiles: $e');
      return [];
    }
  }

  Future<void> addMember(String leagueId, String userId, {String role = 'player'}) async {
    try {
      await _client.from('league_members').insert({
        'league_id': leagueId,
        'user_id': userId,
        'role': role,
      });
    } catch (e) {
      debugPrint('Error adding member: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _client.rpc('delete_user_account', params: {'target_user_id': userId});
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }

  // --- Session Data Methods ---

  Future<List<LeagueMatch>> getSessionMatches(String sessionId) async {
    try {
      final response = await _client
          .from('matches')
          .select('*, match_participants(*, profiles(*))')
          .eq('session_id', sessionId)
          .order('date', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => LeagueMatch.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching matches: $e');
      return [];
    }
  }

  Future<List<SessionParticipant>> getSessionStandings(String sessionId) async {
    try {
      final response = await _client
          .from('session_participants')
          .select('*, profiles(*)')
          .eq('session_id', sessionId)
          .order('points', ascending: false)
          .order('wins', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => SessionParticipant.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching standings: $e');
      return [];
    }
  }

  Future<SessionParticipant?> getUserSessionStats(String sessionId, String userId) async {
    try {
      final response = await _client
          .from('session_participants')
          .select('*, profiles(*)')
          .eq('session_id', sessionId)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return SessionParticipant.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user stats: $e');
      return null;
    }
  }

  Future<void> addSessionParticipant(String sessionId, String userId) async {
    try {
      await _client.from('session_participants').insert({
        'session_id': sessionId,
        'user_id': userId,
        'status': 'active',
        'joined_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error adding session participant: $e');
      rethrow;
    }
  }

  Future<void> removeSessionParticipant(String sessionId, String userId) async {
    try {
      await _client
          .from('session_participants')
          .delete()
          .eq('session_id', sessionId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error removing session participant: $e');
      rethrow;
    }
  }

  Future<void> deleteLeague(String leagueId) async {
    try {
      // Manual Cascade Delete to ensure foreign key constraints don't block deletion
      
      // 1. Delete League Members
      await _client.from('league_members').delete().eq('league_id', leagueId);

      // 2. Get all sessions to delete their dependencies
      final sessionsResponse = await _client.from('league_sessions').select('id').eq('league_id', leagueId);
      final sessionIds = (sessionsResponse as List<dynamic>).map((s) => s['id'] as String).toList();

      if (sessionIds.isNotEmpty) {
        // 3. Delete Session Participants for these sessions
        await _client.from('session_participants').delete().filter('session_id', 'in', sessionIds);

        // 4. Delete Sessions (Matches should cascade if defined, but safe to leave to DB or delete if needed)
        // Assuming matches ON DELETE CASCADE is set as seen in sqls/create_matches_table.sql
        await _client.from('league_sessions').delete().eq('league_id', leagueId);
      }

      // 5. Delete the League itself
      await _client.from('leagues').delete().eq('id', leagueId);
    } catch (e) {
      debugPrint('Error deleting league: $e');
      rethrow;
    }
  }
  // --- Notification Methods ---

  Future<List<NotificationModel>> getUnreadNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> getNotifications({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final data = response as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }
  Future<void> updateParticipantAvailability(String sessionId, String userId, Map<String, String> availability) async {
    try {
      await _client
          .from('session_participants')
          .update({'availability': availability})
          .eq('session_id', sessionId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error updating availability: $e');
      rethrow;
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
