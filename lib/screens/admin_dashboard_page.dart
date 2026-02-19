import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/services/user_service.dart';
import 'package:ace_manager/models/user_profile.dart';
import 'package:ace_manager/screens/login_page.dart';
import 'package:ace_manager/screens/admin/user_management_page.dart';
import 'package:ace_manager/screens/admin/club_management_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const primaryColor = Color(0xFF00DB6E);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(Theme.of(context).textTheme);

    return FutureBuilder<UserProfile?>(
      future: UserService.instance.getCurrentUser(),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Admin Dashboard', style: textTheme.titleLarge),
            backgroundColor: Colors.white,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildAdminCard(
                context,
                textTheme,
                'User Management',
                'Manage all registered users, promote/demote roles.',
                Icons.people_alt,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const UserManagementPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
               _buildAdminCard(
                context,
                textTheme,
                'System Notifications',
                'Send app-wide announcements to all players.',
                Icons.notifications_active,
                () {
                  // TODO: Navigate to Notification Creator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification System coming soon')),
                  );
                },
              ),
               const SizedBox(height: 16),
               _buildAdminCard(
                context,
                textTheme,
                'League Configuration',
                'Create new leagues, set seasons, and manage constraints.',
                Icons.settings_input_component,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('League Config coming soon')),
                  );
                },
              ),
              const SizedBox(height: 16),
               _buildAdminCard(
                context,
                textTheme,
                'Club Management',
                'Add new clubs, and manage them.',
                Icons.sports_tennis,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ClubManagementPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminCard(
    BuildContext context, 
    TextTheme textTheme, 
    String title, 
    String subtitle, 
    IconData icon, 
    VoidCallback onTap
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
