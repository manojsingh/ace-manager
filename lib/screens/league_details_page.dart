import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/screens/profile_page.dart';
import 'package:ace_manager/screens/league_members_page.dart';
import 'package:ace_manager/screens/league/invite_member_page.dart';
import 'package:ace_manager/screens/league/create_session_page.dart';
import 'package:ace_manager/screens/league/session_dashboard_page.dart';
import 'package:ace_manager/screens/dashboard_page.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/screens/notifications_page.dart';
import 'package:intl/intl.dart';

class LeagueDetailsPage extends StatefulWidget {
  final String leagueId;
  final String leagueName;
  final String userRole;

  const LeagueDetailsPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.userRole,
  });

  @override
  State<LeagueDetailsPage> createState() => _LeagueDetailsPageState();
}

class _LeagueDetailsPageState extends State<LeagueDetailsPage> {
  // Theme Colors
  static const primaryColor = Color(0xFF3CDD57); // #3cdd57
  static const backgroundLight = Colors.white; // #ffffff
  static const textDark = Color(0xFF141712); // #141712

  late Future<List<LeagueSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshSessions();
  }

  void _refreshSessions() {
    setState(() {
      _sessionsFuture = LeagueService.instance.getLeagueSessions(widget.leagueId);
    });
  }

  Future<void> _deleteLeague() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete League?'),
        content: const Text(
            'Are you sure you want to delete this league? This action cannot be undone and will delete all sessions and matches.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      try {
        await LeagueService.instance.deleteLeague(widget.leagueId);
        if (!mounted) return;
        Navigator.of(context).pop(); // Go back to Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('League deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting league: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);
    final isOwnerOrAdmin = widget.userRole == 'owner' || widget.userRole == 'admin';

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header
            _buildHeader(context, textTheme),

            // Scrollable Content
            Expanded(
              child: FutureBuilder<List<LeagueSession>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final sessions = snapshot.data ?? [];
                  final now = DateTime.now();

                  // Categorize Sessions
                  // Active: status == 'active' OR standard current date check
                  final activeSessions = sessions.where((s) {
                    // Start date <= now AND (End date >= now OR End date is null)
                    // Or explicit status if available (model check needed, using dates for now)
                    final started = s.startDate.isBefore(now);
                    final ended = s.endDate != null && s.endDate!.isBefore(now);
                    return started && !ended;
                  }).toList();

                  final upcomingSessions = sessions.where((s) {
                    return s.startDate.isAfter(now);
                  }).toList();

                  final pastSessions = sessions.where((s) {
                    return s.endDate != null && s.endDate!.isBefore(now);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async => _refreshSessions(),
                    color: primaryColor,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120), // Bottom padding for fixed actions
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (activeSessions.isNotEmpty)
                            _buildSection(
                                context, textTheme, 'Active Sessions', activeSessions, 'Live Now', true),
                          
                          if (upcomingSessions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: _buildSection(
                                  context, textTheme, 'Upcoming Sessions', upcomingSessions, '', false),
                            ),

                          if (pastSessions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: _buildHorizontalSection(
                                context, 
                                textTheme, 
                                'Past Sessions',
                                pastSessions, 
                                onViewAll: () {
                                  // TODO: Navigate to all past sessions page
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('View All Past Sessions')),
                                  );
                                },
                              ),
                            ),
                          
                          // Empty State Visualization
                          if (sessions.isEmpty)
                             Center(
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 60),
                                 child: Column(
                                   children: [
                                     Icon(Icons.analytics_outlined, size: 64, color: primaryColor.withValues(alpha: 0.2)),
                                     Container(width: 40, height: 1, color: primaryColor, margin: const EdgeInsets.symmetric(vertical: 16)),
                                     Text(
                                       'NO SESSIONS YET',
                                       style: textTheme.labelSmall?.copyWith(
                                         color: Colors.grey,
                                         letterSpacing: 1.5,
                                         fontWeight: FontWeight.bold,
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
                },
              ),
            ),
            
            // Fixed Bottom Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Create Session (Owner/Admin only)
                  if (isOwnerOrAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => CreateSessionPage(leagueId: widget.leagueId)),
                          );
                          _refreshSessions();
                        },
                        icon: const Icon(Icons.add_circle, size: 24),
                        label: const Text('Create New Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 4,
                          shadowColor: primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  
                  if (isOwnerOrAdmin)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _deleteLeague,
                          icon: const Icon(Icons.delete, size: 20),
                          label: const Text('Delete League'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            backgroundColor: Colors.red[50],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.red[100]!),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  
                  // Bottom Nav Mockup (Internal Navigation)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          context, 
                          textTheme, 
                          Icons.home, 
                          'HOME', 
                          false,
                          onTap: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const DashboardPage()),
                            (route) => false,
                          ),
                        ),
                        _buildNavItem(context, textTheme, Icons.calendar_month, 'SESSIONS', true),
                        _buildNavItem(
                          context, 
                          textTheme, 
                          Icons.group, 
                          'MEMBERS', 
                          false,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LeagueMembersPage(
                                leagueId: widget.leagueId,
                                leagueName: widget.leagueName,
                                currentUserRole: widget.userRole,
                              )
                            )
                          ),
                        ),
                        _buildNavItem(
                          context, 
                          textTheme, 
                          Icons.person, 
                          'PROFILE', 
                          false,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ProfilePage())
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Container(
      // Header container
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: textDark),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.sports_tennis, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.leagueName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  Text(
                    widget.userRole.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Notification Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (c) => NotificationsPage())).then((_) => _refreshSessions());
                },
                icon: const Icon(Icons.notifications_outlined, color: textDark, size: 28),
              ),
              FutureBuilder<List<NotificationModel>>(
                future: LeagueService.instance.getUnreadNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, 
    TextTheme textTheme, 
    String title, 
    List<LeagueSession> sessions, 
    String badgeText, 
    bool isActive,
    {bool isPast = false}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: -0.5,
              ),
            ),
            if (badgeText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...sessions.map((session) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSessionCard(context, textTheme, session, isActive, isPast),
        )),
      ],
    );
  }

  Widget _buildSessionCard(
    BuildContext context, 
    TextTheme textTheme, 
    LeagueSession session, 
    bool isActive, 
    bool isPast
  ) {
    return InkWell(
      onTap: () {
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => SessionDashboardPage(
             leagueId: widget.leagueId,
             leagueName: widget.leagueName,
             userRole: widget.userRole,
             sessionId: session.id,
           )),
         );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isActive ? primaryColor.withValues(alpha: 0.4) : Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE6F0E6).withValues(alpha: 0.8), // tennis-card-shadow
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Opacity(
          opacity: isPast ? 0.75 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (session.gameType ?? 'League').toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: isActive ? primaryColor : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.name ?? 'League Session',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? primaryColor : Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : (isPast ? 'COMPLETED' : 'UPCOMING'),
                      style: textTheme.labelSmall?.copyWith(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Info Row
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('MMM d').format(session.startDate)}${session.endDate != null ? ' - ${DateFormat('MMM d').format(session.endDate!)}' : ''}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  if (isActive) ...[
                    // Mock player count for now, would need join to count
                    Icon(Icons.group, size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      '-- Players', // TODO: Fetch participant count
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),

              if (isActive || isPast) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mock Avatars
                    SizedBox(
                      height: 28,
                      child: Stack(
                        children: [
                           _buildAvatar(0, "assets/images/user_avatar_2.png"),
                           _buildAvatar(20, "assets/images/opponent_avatar.png"),
                           Positioned(
                             left: 40,
                             child: Container(
                               width: 28,
                               height: 28,
                               decoration: BoxDecoration(
                                 color: const Color(0xFFF0F8EE),
                                 shape: BoxShape.circle,
                                 border: Border.all(color: Colors.white, width: 2),
                               ),
                               child: Center(
                                 child: Text(
                                   '+item',
                                   style: textTheme.labelSmall?.copyWith(
                                     color: primaryColor,
                                     fontSize: 8,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                             ),
                           ),
                        ],
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () {
                         Navigator.of(context).push(
                           MaterialPageRoute(builder: (context) => SessionDashboardPage(
                             leagueId: widget.leagueId,
                             leagueName: widget.leagueName,
                             userRole: widget.userRole,
                             sessionId: session.id,
                           )),
                         );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Text(
                            isActive ? 'Manage Session' : 'View Results',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isActive ? textDark : primaryColor,
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.chevron_right, size: 18, color: textDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(double left, String asset) {
    return Positioned(
      left: left,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.grey[200],
        ),
        child: ClipOval(
          // Placeholder usage
          child: Icon(Icons.person, size: 20, color: Colors.grey[400]), 
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(
    BuildContext context, 
    TextTheme textTheme, 
    String title, 
    List<LeagueSession> sessions, 
    {VoidCallback? onViewAll}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View all',
                    style: textTheme.bodyMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 190, // Adjusted height for the card
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildHorizontalSessionCard(context, textTheme, sessions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalSessionCard(
    BuildContext context, 
    TextTheme textTheme, 
    LeagueSession session
  ) {
    return InkWell(
      onTap: () {
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => SessionDashboardPage(
             leagueId: widget.leagueId,
             leagueName: widget.leagueName,
             userRole: widget.userRole,
             sessionId: session.id,
           )),
         );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (session.gameType ?? 'League').toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session.name ?? 'League Session',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${DateFormat('MMM d').format(session.startDate)}${session.endDate != null ? ' - ${DateFormat('MMM d').format(session.endDate!)}' : ''}',
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Bottom Action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Results',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, TextTheme textTheme, IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isActive ? primaryColor : const Color(0xFF738367)),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isActive ? primaryColor : const Color(0xFF738367),
            ),
          ),
        ],
      ),
    );
  }
}
