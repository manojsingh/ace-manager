import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/models/league_dashboard_data.dart';
import 'package:ace_manager/models/match.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/services/user_service.dart';
import 'package:ace_manager/screens/league_details_page.dart';
import 'package:ace_manager/screens/profile_page.dart';
import 'package:ace_manager/screens/admin_dashboard_page.dart';
import 'package:ace_manager/l10n/app_localizations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const primaryColor = Color(0xFF3CDD57);
  static const surfaceLight = Colors.white;
  static const backgroundLight = Color(0xFFF9FAFB);
  static const textCharcoal = Color(0xFF141712);
  static const textGrey = Color(0xFF738367);
  static const borderLight = Color(0xFFE5E7EB);

  int _selectedIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = await UserService.instance.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _isAdmin = user.isAdmin;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    await LeagueService.instance.markNotificationAsRead(notificationId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Header
               Padding(
                 padding: const EdgeInsets.only(bottom: 24.0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Welcome Back,', style: textTheme.bodyMedium?.copyWith(color: textGrey)),
                         Text('My Dashboard', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: textCharcoal)),
                       ],
                     ),
                     CircleAvatar(
                       radius: 20,
                       backgroundColor: primaryColor,
                       child: const Icon(Icons.person, color: Colors.white),
                     ),
                   ],
                 ),
               ),
               // Notifications
               FutureBuilder<List<NotificationModel>>(
                 future: LeagueService.instance.getUnreadNotifications(),
                 builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: snapshot.data!.map((n) => _buildNotificationBanner(textTheme, n)).toList(),
                    );
                 },
               ),
               const SizedBox(height: 16),
                        FutureBuilder<List<LeagueDashboardData>>(
                          future: LeagueService.instance.getDashboardData(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
                            }
                            
                            final dashboardData = snapshot.data ?? [];
                            final myManagedLeagues = dashboardData.where((d) => ['owner', 'admin'].contains(d.userRole)).toList();
                            final myParticipationLeagues = dashboardData.where((d) => d.userRole == 'player').toList();

                            // Find global next match
                            LeagueMatch? globalNextMatch;
                            LeagueDashboardData? nextMatchData;
                            
                            final allMatches = dashboardData
                                .where((d) => d.nextMatch != null)
                                .map((d) => d.nextMatch!)
                                .toList();
                            
                            if (allMatches.isNotEmpty) {
                              allMatches.sort((a, b) => a.date.compareTo(b.date));
                              globalNextMatch = allMatches.first;
                              nextMatchData = dashboardData.firstWhere((d) => d.nextMatch == globalNextMatch);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Upcoming Global Match
                                if (globalNextMatch != null && nextMatchData != null) ...[
                                   _buildUpcomingMatchCard(textTheme, globalNextMatch, nextMatchData.league.name),
                                   const SizedBox(height: 24),
                                ],

                                // Leagues I Manage
                                if (myManagedLeagues.isNotEmpty) ...[
                                  _buildSectionHeader(textTheme, 'Leagues I Manage', Icons.shield_outlined),
                                  const SizedBox(height: 16),
                                  ...myManagedLeagues.map((data) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildManageCard(textTheme, data),
                                  )),
                                  // Create New League Button
                                  _buildCreateLeagueButton(textTheme),
                                  const SizedBox(height: 32),
                                ],

                                // Leagues I'm In
                                _buildSectionHeader(textTheme, "Leagues I'm In", Icons.sports_tennis),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                     const SizedBox(), // Spacer
                                     Text(
                                       '${myParticipationLeagues.length} ACTIVE',
                                       style: textTheme.labelSmall?.copyWith(
                                         fontWeight: FontWeight.bold, 
                                         color: textGrey
                                       ),
                                     ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                if (myParticipationLeagues.isEmpty && myManagedLeagues.isEmpty)
                                  _buildEmptyState(textTheme)
                                else if (myParticipationLeagues.isEmpty)
                                   Center(child: Text("You are not participating in any leagues yet.", style: textTheme.bodyMedium?.copyWith(color: textGrey)))
                                else
                                  ...myParticipationLeagues.map((data) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildParticipantCard(textTheme, data),
                                  )),
                              ],
                            );
                          },
                        ),
              ],
            ),
          ),
        ),

      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: surfaceLight,
          border: Border(top: BorderSide(color: borderLight)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', 0, isActive: true),
            _buildNavItem(Icons.emoji_events_outlined, 'Leagues', 1),
            _buildNavItem(Icons.person_outline, 'Profile', 2),
            if (_isAdmin)
              _buildNavItem(Icons.admin_panel_settings_outlined, 'Admin', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildManageCard(TextTheme textTheme, LeagueDashboardData data) {
    return Container(
      // ... (decoration same)
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     data.league.name,
                     style: textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: textCharcoal,
                     ),
                   ),
                   const SizedBox(height: 4),
                   Row(
                     children: [
                       const Icon(Icons.people, size: 14, color: textGrey),
                       const SizedBox(width: 4),
                       Text(
                         'Manage', // Simplified
                         style: textTheme.bodySmall?.copyWith(
                           color: textGrey,
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                       const SizedBox(width: 8),
                       if (data.activeSession != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ACTIVE SESSION',
                            style: textTheme.labelSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                     ],
                   ),
                 ],
               ),
               Container(
                 width: 48,
                 height: 48,
                 decoration: BoxDecoration(
                   color: primaryColor.withValues(alpha: 0.2), 
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Icon(Icons.shield, color: primaryColor), 
               ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LeagueDetailsPage(
                      leagueId: data.league.id,
                      leagueName: data.league.name,
                      userRole: data.userRole,
                    )),
                  );
                setState(() {});
              }, 
              icon: const Icon(Icons.settings, size: 20),
              label: const Text('Manage League'),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundLight,
                foregroundColor: textCharcoal,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          )
        ],
      ),
    );
  }

    Widget _buildSectionHeader(TextTheme textTheme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: textGrey),
        const SizedBox(width: 8),
        Text(title.toUpperCase(), style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textGrey)),
      ],
    );
  }

  Widget _buildCreateLeagueButton(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to Create League
        },
        icon: const Icon(Icons.add),
        label: const Text('Create New League'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.dashboard_customize, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No Leagues Yet', style: textTheme.bodyLarge?.copyWith(color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildUpcomingMatchCard(TextTheme textTheme, LeagueMatch match, String leagueName) {
    // Format Date: "TOMORROW, 6:00 PM"
    // For MVP using simple string, ideally use intl package
    final dateStr = "${match.date.month}/${match.date.day} ${match.date.hour}:${match.date.minute.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'UPCOMING MATCH',
                style: textTheme.labelSmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  leagueName.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dateStr,
            style: textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'vs. ',
                style: textTheme.bodyLarge?.copyWith(color: textGrey),
              ),
              Text(
                'Opponent', // Need to fetch opponent name in data model refactor or use placeholder
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(TextTheme textTheme, LeagueDashboardData data) {
    return GestureDetector(
      onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LeagueDetailsPage(
                      leagueId: data.league.id,
                      leagueName: data.league.name,
                      userRole: data.userRole,
                    )),
                  );
                  setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderLight),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        data.league.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textCharcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: textGrey),
                          const SizedBox(width: 4),
                          Text(
                            data.league.location ?? 'No Location',
                            style: textTheme.bodySmall?.copyWith(color: textGrey),
                          ),
                        ],
                      ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: textGrey),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool isActive = false}) {
    final color = isActive || _selectedIndex == index ? primaryColor : textGrey;
    return GestureDetector(
      onTap: () {
        if (index == 2) {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) => const ProfilePage()));
        } else if (index == 3) {
          Navigator.of(context).push(MaterialPageRoute(builder: (c) => const AdminDashboardPage()));
        } else {
           setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.lexend(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationBanner(TextTheme textTheme, NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: textTheme.bodySmall?.copyWith(color: textCharcoal),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _markAsRead(notification.id),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(Icons.close, size: 18, color: textGrey),
            ),
          ),
        ],
      ),
    );
  }
}
