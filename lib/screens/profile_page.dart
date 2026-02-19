import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/user_profile.dart';
import 'package:ace_manager/services/user_service.dart';
import 'package:ace_manager/screens/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const primaryColor = Color(0xFF00DB6E);
  static const backgroundLight = Colors.white;
  static const borderLight = Color(0xFFE2E8F0);
  static const textDark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text('My Profile', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<UserProfile?>(
        future: UserService.instance.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          
          // Fallback UI if profile is null (shouldn't happen if auth is largely working)
          if (profile == null) {
            return const Center(child: Text("Unable to load profile"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 4),
                          color: Colors.grey[100],
                          image: profile.avatarUrl != null 
                              ? DecorationImage(image: NetworkImage(profile.avatarUrl!), fit: BoxFit.cover)
                              : const DecorationImage(image: AssetImage("assets/images/user_avatar.png"), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name & Role
                Text(
                  profile.fullName,
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.role.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Section
                _buildInfoTile(context, textTheme, Icons.email_outlined, 'Email', profile.email),
                const SizedBox(height: 16),
                _buildInfoTile(context, textTheme, Icons.phone_outlined, 'Phone', '+1 (555) 000-0000'), // Placeholder for now
                
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),

                // Settings & Logout
                _buildActionTile(context, textTheme, Icons.settings_outlined, 'Settings', () {}),
                _buildActionTile(context, textTheme, Icons.help_outline, 'Help & Support', () {}),
                _buildActionTile(
                  context, 
                  textTheme, 
                  Icons.logout, 
                  'Logout', 
                  () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                      );
                    }
                  },
                  color: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, TextTheme textTheme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelSmall?.copyWith(color: Colors.grey[500])),
                Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, 
    TextTheme textTheme, 
    IconData icon, 
    String label, 
    VoidCallback onTap, 
    {Color? color}
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? textDark).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color ?? textDark),
      ),
      title: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
