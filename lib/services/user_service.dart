import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/models/user_profile.dart';

class UserService {
  final SupabaseClient _client;

  UserService(this._client);

  // Singleton instance for easy access (optional, but good for now)
  static final UserService instance = UserService(Supabase.instance.client);

  Future<UserProfile?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      // Merge auth data (email) with profile data
      final data = response;
      data['email'] = user.email; // Add email from auth user to the map for model

      return UserProfile.fromJson(data);
    } catch (e) {
      // Fallback if profile fetch fails (e.g. detailed profile not created yet)
      // keeping the old metadata logic as a safe fallback
      final metadata = user.userMetadata;
      final fullName = metadata?['full_name'] as String? ?? 'Alex Rivera';
      final parts = fullName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : 'Alex';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : 'Rivera';

      return UserProfile(
        id: user.id,
        email: user.email ?? '',
        firstName: firstName,
        lastName: lastName,
        role: 'player', // Default to player on fallback
      );
    }
  }
}
