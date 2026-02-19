import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/screens/dashboard_page.dart';
import 'package:ace_manager/screens/league_sessions_page.dart';

class LeagueCreatedPage extends StatelessWidget {
  final League league;

  const LeagueCreatedPage({super.key, required this.league});

  static const primaryColor = Color(0xFF32D411);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6), // background-light
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar Placeholder (simulated by SafeArea, but adding padding)
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Celebration Banner Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Header Image / Pattern Area
                          Container(
                            height: 192, // h-48 = 12rem = 192px
                            color: primaryColor.withValues(alpha: 0.1),
                            child: Stack(
                              children: [
                                // Abstract Celebration Pattern (Simplified with Flutter shapes)
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Transform.rotate(
                                    angle: 12 * 3.14159 / 180,
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: primaryColor, width: 2),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 32,
                                  right: 48,
                                  child: Transform.rotate(
                                    angle: -45 * 3.14159 / 180,
                                    child: Container(
                                      width: 48,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ),
                                // Center Content
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withValues(alpha: 0.2),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'League Created!',
                                        style: textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Body Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  'Congratulations! Your league',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '"${league.name}"',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "You're now ready to start organizing and managing your competitions.",
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Action Items Container
                    Text(
                      'Next Steps',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pick where you'd like to begin",
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),

                    // Create Session Button
                    _buildActionButton(
                      context: context,
                      textTheme: textTheme,
                      title: 'Create Your First Session',
                      icon: Icons.event,
                      isPrimary: true,
                      onTap: () {
                         Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LeagueSessionsPage(leagueId: league.id, isOwner: true, leagueName: league.name)),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Invite Admins Button (Secondary)
                    _buildActionButton(
                      context: context,
                      textTheme: textTheme,
                      title: 'Invite Admins',
                      icon: Icons.group_add,
                      isPrimary: false,
                      onTap: () {
                         // TODO: Navigate to invite members/admins page
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite Admins - Coming Soon')));
                      },
                    ),
                     const SizedBox(height: 16),

                     // Go to Dashboard (Tertiary)
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const DashboardPage()),
                          (route) => false,
                        );
                      },
                      icon: const Text('Go to Dashboard'), // Label first
                      label: const Icon(Icons.arrow_forward, size: 18), // Icon second per design visual order
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                        textStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Info Footer
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // slate-100
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: primaryColor.withValues(alpha: 0.6), size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'You can manage your league settings, rules, and branding anytime from the administrative panel in your dashboard.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required TextTheme textTheme,
    required String title,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 72, // py-4 approx
      decoration: BoxDecoration(
        color: isPrimary ? primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPrimary ? Colors.white.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: isPrimary ? Colors.white : primaryColor, // Fixed: Secondary icon color to primary
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: isPrimary ? Colors.white : primaryColor, // Fixed: Secondary text color to primary
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  color: isPrimary ? Colors.white : primaryColor, // Fixed: Secondary icon color to primary
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
