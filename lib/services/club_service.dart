import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/models/club.dart';
import 'package:ace_manager/models/court.dart';
import 'package:flutter/foundation.dart';

class ClubService {
  final SupabaseClient _client;

  ClubService(this._client);

  static final ClubService instance = ClubService(Supabase.instance.client);

  Future<List<Club>> getAllClubs() async {
    try {
      final response = await _client
          .from('clubs')
          .select()
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => Club.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching clubs: $e');
      return [];
    }
  }

  Future<Club?> createClub(String name, String location, int courtCount, {String? imageUrl}) async {
    try {
      final response = await _client.from('clubs').insert({
        'name': name,
        'location': location,
        'court_count': courtCount,
        'image_url': imageUrl,
      }).select().single();

      return Club.fromJson(response);
    } catch (e) {
      debugPrint('Error creating club: $e');
      return null;
    }
  }

  Future<Club?> updateClub(String id, String name, String location, int courtCount, {String? imageUrl}) async {
    try {
      final response = await _client.from('clubs').update({
        'name': name,
        'location': location,
        'court_count': courtCount,
        'image_url': imageUrl,
      }).eq('id', id).select().single();

      return Club.fromJson(response);
    } catch (e) {
      debugPrint('Error updating club: $e');
      return null;
    }
  }

  Future<void> deleteClub(String id) async {
    try {
      await _client.from('clubs').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting club: $e');
      rethrow;
    }
  }

  // Court Methods

  Future<List<Court>> getClubCourts(String clubId) async {
    try {
      final response = await _client
          .from('courts')
          .select()
          .eq('club_id', clubId)
          .order('name', ascending: true);

      final data = response as List<dynamic>;
      return data.map((json) => Court.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching courts: $e');
      return [];
    }
  }

  Future<Court?> addCourt(String clubId, String name, String surfaceType) async {
    try {
      final response = await _client.from('courts').insert({
        'club_id': clubId,
        'name': name,
        'surface_type': surfaceType,
      }).select().single();

      return Court.fromJson(response);
    } catch (e) {
      debugPrint('Error adding court: $e');
      return null;
    }
  }

  Future<void> deleteCourt(String id) async {
    try {
      await _client.from('courts').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting court: $e');
      rethrow;
    }
  }
}
