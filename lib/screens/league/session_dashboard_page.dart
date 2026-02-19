import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/models/session_participant.dart';
import 'package:ace_manager/models/match.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ace_manager/screens/league/session_participants_page.dart';
import 'package:ace_manager/l10n/app_localizations.dart';
import 'package:ace_manager/screens/league/configure_session_page.dart';
import 'package:ace_manager/screens/league/session_schedule_page.dart';
import 'package:ace_manager/screens/league/session_availability_view_page.dart';
import 'package:ace_manager/screens/league/automatic_scheduler_page.dart';
import 'package:ace_manager/screens/notifications_page.dart';

class SessionDashboardPage extends StatefulWidget {
  final String leagueId;
  final String leagueName;
  final String userRole;
  final String? sessionId;

  const SessionDashboardPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.userRole,
    this.sessionId,
  });

  @override
  State<SessionDashboardPage> createState() => _SessionDashboardPageState();
}

class _SessionDashboardPageState extends State<SessionDashboardPage> {
  // Theme Colors from HTML design
  static const primaryColor = Color(0xFF00DB6E);
  static const textDark = Color(0xFF141712);
  static const textGrey = Color(0xFF738367);
  static const courtShadow = Color(0xFFE6F0E6);
  static const hoverTint = Color(0xFFF0F8EE);
  static const dividerColor = Color(0xFFE0E0E0);

  bool _isLoading = true;
  LeagueSession? _currentSession;
  SessionParticipant? _userStats;
  List<SessionParticipant> _standings = [];
  LeagueMatch? _nextMatch;
  List<LeagueMatch> _recentResults = [];
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      
      // 1. Fetch latest session for the league
      final sessions = await LeagueService.instance.getLeagueSessions(widget.leagueId);
      if (sessions.isNotEmpty) {
        if (widget.sessionId != null) {
          _currentSession = sessions.firstWhere((s) => s.id == widget.sessionId, orElse: () => sessions.first);
        } else {
          _currentSession = sessions.first; // Assume first is latest/active
        }
        
        // 2. Fetch User Stats
        _userStats = await LeagueService.instance.getUserSessionStats(_currentSession!.id, userId);

        // 3. Fetch Standings
        _standings = await LeagueService.instance.getSessionStandings(_currentSession!.id);

        // 4. Fetch Matches
        final allMatches = await LeagueService.instance.getSessionMatches(_currentSession!.id);
        
        // Filter for Next Match (first scheduled match in future/today) and Recent Results
        final now = DateTime.now();
        
        // Find next match involving user
        try {
           _nextMatch = allMatches.firstWhere(
            (m) => m.status == 'scheduled' && 
                   m.participants.any((p) => p.userId == userId) &&
                   m.date.isAfter(now.subtract(const Duration(hours: 2))),
            orElse: () => allMatches.firstWhere((m) => m.status == 'scheduled', orElse: () => allMatches.first) // Fallback to any scheduled
          );
           // If we fell back to a match we aren't in, clear it if we want strict "My Next Match"
           if (_nextMatch != null && !_nextMatch!.participants.any((p) => p.userId == userId)) {
             _nextMatch = null;
           }
        } catch (e) {
          _nextMatch = null;
        }

        _recentResults = allMatches
            .where((m) => m.status == 'completed')
            .take(5)
            .toList();
            
        // Fetch notifications
        _notifications = await LeagueService.instance.getUnreadNotifications();
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  Future<void> _joinSession() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null || _currentSession == null) return;

      await LeagueService.instance.addSessionParticipant(_currentSession!.id, userId);
      await _loadData(); // Refresh to see stats
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgJoinedSession)));
      }
    } catch (e) {
      debugPrint('Error joining session: $e');
      if (mounted) {
         setState(() => _isLoading = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgJoinSessionFailed)));
      }
    }
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Use Lexend font as per design
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_currentSession == null) {
      return Scaffold(
        backgroundColor: Colors.white,
         appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: textDark), onPressed: () => Navigator.pop(context)),
         ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 64, color: textGrey),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.sessionNoActiveFound, style: textTheme.titleMedium?.copyWith(color: textDark)),
              if (widget.userRole == 'owner')
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to create session - TODO
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    child: Text(AppLocalizations.of(context)!.actionCreateSession),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final rank = userId != null ? _calculateRank(userId) : 0;
    final winRate = _calculateWinRate();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
             Column(
              children: [
                // Header Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildCircularButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.leagueName,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                _currentSession?.name ?? AppLocalizations.of(context)!.labelCurrentSession,
                                style: textTheme.bodySmall?.copyWith(color: textGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                       clipBehavior: Clip.none,
                       children: [
                         _buildCircularButton(
                           icon: Icons.notifications_none,
                           onTap: () {
                             // Navigate to notifications
                             Navigator.of(context).push(MaterialPageRoute(builder: (c) => NotificationsPage())).then((_) => _loadData(showLoading: false));
                           },
                         ),
                         FutureBuilder<List<NotificationModel>>(
                           future: LeagueService.instance.getUnreadNotifications(),
                           builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                return Positioned(
                                 top: 0,
                                 right: 0,
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
                ),
                
                // Main Content Area
                Expanded(
                  child: _buildTabContent(textTheme, rank, winRate, userId),
                ),
              ],
            ),
            
            // Fixed Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: dividerColor)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(textTheme, Icons.home, AppLocalizations.of(context)!.navHome.toUpperCase(), 0),
                    _buildNavItem(textTheme, Icons.sports_tennis, AppLocalizations.of(context)!.navMatches.toUpperCase(), 1),
                    _buildNavItem(textTheme, Icons.emoji_events, AppLocalizations.of(context)!.titleStandings.toUpperCase(), 2),
                    _buildNavItem(textTheme, Icons.person, AppLocalizations.of(context)!.navProfile.toUpperCase(), 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(TextTheme textTheme, int rank, double winRate, String? userId) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(textTheme, rank, winRate, userId);
      case 1:
        return _buildMatchesTab(textTheme, userId);
      case 2:
        return _buildStandingsTab(textTheme, userId);
      case 3:
        return _buildProfileTab(textTheme, rank, winRate, userId);
      default:
        return _buildHomeTab(textTheme, rank, winRate, userId);
    }
  }

  Widget _buildHomeTab(TextTheme textTheme, int rank, double winRate, String? userId) {
    return RefreshIndicator(
      onRefresh: () => _loadData(showLoading: false),
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Announcement Toast
            if (_currentSession?.status == 'upcoming' || _currentSession?.status == 'active')
            // Notifications / Status Box
            if (_notifications.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5), // Light orange for notifications
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _notifications.first.title.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _notifications.first.message,
                            style: textTheme.bodySmall?.copyWith(
                              color: textDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final notificationId = _notifications.first.id;
                        // Optimistic update
                        setState(() {
                          _notifications.removeAt(0);
                        });
                        try {
                          await LeagueService.instance.markNotificationAsRead(notificationId);
                        } catch (e) {
                          debugPrint('Error marking notification as read: $e');
                          // Optionally revert or show error, but silent fail is often better for UI dismissals
                        }
                      },
                      child: const Icon(Icons.close, color: textGrey, size: 18),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hoverTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.campaign, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS: ${_currentSession?.status?.toUpperCase() ?? "UNKNOWN"}',
                            style: textTheme.labelSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentSession?.name != null ? AppLocalizations.of(context)!.msgWelcomeSession(_currentSession!.name!) : AppLocalizations.of(context)!.msgGoodLuck,
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4A4A4A),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(Icons.close, color: textGrey, size: 18),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Summary Card
            _userStats == null
                ? (_currentSession != null ? _buildJoinSessionCard(textTheme) : const SizedBox())
                : _buildSummaryCard(textTheme, rank, winRate),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              AppLocalizations.of(context)!.sectionQuickActions,
              style: textTheme.titleMedium?.copyWith(
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3, // Adjust for card shape (width / height)
              children: [
                _buildQuickActionCard(textTheme, Icons.edit_note, AppLocalizations.of(context)!.actionLogScore),
                _buildQuickActionCard(
                  textTheme, 
                  Icons.calendar_today, 
                  AppLocalizations.of(context)!.actionAvailability,
                  onTap: () {
                    if (_currentSession != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SessionSchedulePage(
                            leagueId: widget.leagueId,
                            sessionId: _currentSession!.id,
                            sessionName: _currentSession!.name ?? 'Session',
                          ),
                        ),
                      );
                    }
                  },
                ),
                _buildQuickActionCard(textTheme, Icons.leaderboard, AppLocalizations.of(context)!.titleStandings, onTap: () => _onItemTapped(2)),
                _buildQuickActionCard(textTheme, Icons.chat_bubble_outline, AppLocalizations.of(context)!.actionMessageGroup, hasBadge: true),
                
                if (widget.userRole == 'owner' || widget.userRole == 'admin') ...[
                   _buildQuickActionCard(
                     textTheme, 
                     Icons.people, 
                     AppLocalizations.of(context)!.actionManagePlayers, 
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => SessionParticipantsPage(
                             sessionId: _currentSession!.id,
                             leagueId: widget.leagueId,
                           ),
                         ),
                       ).then((_) => _loadData()); // Reload dashboard on return
                     },
                   ),
                   _buildQuickActionCard(
                     textTheme, 
                     Icons.auto_awesome, 
                     'Auto Schedule', // Localize later
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => AutomaticSchedulerPage(
                             sessionId: _currentSession!.id,
                             sessionName: _currentSession!.name ?? 'Session',
                           ),
                         ),
                       );
                     },
                   ),
                   _buildQuickActionCard(
                     textTheme, 
                     Icons.calendar_month, 
                     'Configure Schedule', // Localize later
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => ConfigureSessionPage(
                             leagueId: widget.leagueId,
                             sessionId: _currentSession!.id,
                             sessionName: _currentSession!.name ?? 'Session',
                           ),
                         ),
                       ).then((_) => _loadData());
                     },
                   ),
                   _buildQuickActionCard(
                     textTheme, 
                     Icons.visibility, 
                     'View Availability', // Localize later
                     onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => SessionAvailabilityViewPage(
                             sessionId: _currentSession!.id,
                             sessionName: _currentSession!.name ?? 'Session',
                             roundDates: _currentSession!.roundDates,
                           ),
                         ),
                       );
                     },
                   ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Standings Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hoverTint),
                boxShadow: const [
                  BoxShadow(
                    color: courtShadow,
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.titleStandings,
                        style: textTheme.titleMedium?.copyWith(
                          color: textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _onItemTapped(2),
                        child: Text(
                          AppLocalizations.of(context)!.actionViewAll,
                          style: textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_standings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(AppLocalizations.of(context)!.msgNoStandings, style: textTheme.bodyMedium?.copyWith(color: textGrey)),
                    )
                  else
                    ..._standings.take(3).map((p) {
                      final pRank = _standings.indexOf(p) + 1;
                      final pName = p.profile != null 
                          ? '${p.profile!.firstName} ${p.profile!.lastName}'.trim() 
                          : AppLocalizations.of(context)!.labelUnknownPlayer;
                      return _buildStandingRow(textTheme, pRank, pName, '${p.points} pts', isHighlighted: p.userId == userId);
                    }),
                  
                  if (_standings.length > 3 && userId != null) ...[
                    const SizedBox(height: 8),
                    const Divider(color: dividerColor),
                    const SizedBox(height: 8),
                    // Show user's rank if not in top 3
                    if (_calculateRank(userId) > 3)
                      Builder(builder: (context) {
                        final myRank = _calculateRank(userId);
                        final myStat = _standings.firstWhere((p) => p.userId == userId);
                         final myName = myStat.profile != null 
                          ? '${myStat.profile!.firstName} ${myStat.profile!.lastName}'.trim() 
                          : AppLocalizations.of(context)!.labelYou;
                        return _buildStandingRow(textTheme, myRank, myName, '${myStat.points} pts', isHighlighted: true);
                      }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Results
            Text(
              AppLocalizations.of(context)!.sectionRecentResults,
              style: textTheme.titleMedium?.copyWith(
                color: textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_recentResults.isEmpty)
              Text(AppLocalizations.of(context)!.msgNoCompletedMatches, style: textTheme.bodyMedium?.copyWith(color: textGrey))
            else
              ..._recentResults.map((m) {
                 final isWin = m.winnerId == userId;
                 final dateStr = DateFormat('MMM d, yyyy').format(m.date);
                 return Padding(
                   padding: const EdgeInsets.only(bottom: 12),
                   child: _buildResultCard(textTheme, isWin, AppLocalizations.of(context)!.tagMatchResult, dateStr, m.score ?? 'N/A'),
                 );
              }),
          ],
        ),
      ),
    );
  }

  int _calculateRank(String userId) {
    if (_standings.isEmpty) return 0;
    // Standings should already be sorted by points/winrate from service, but to be sure:
    // We'll trust the order from service for now.
    int index = _standings.indexWhere((p) => p.userId == userId);
    return index != -1 ? index + 1 : 0;
  }

  double _calculateWinRate() {
    if (_userStats == null || _userStats!.matchesPlayed == 0) return 0.0;
    return (_userStats!.wins / _userStats!.matchesPlayed) * 100;
  }
  
  String _getOrdinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Widget _buildMatchesTab(TextTheme textTheme, String? userId) {
     // For now, let's use a simple placeholder or refetch if needed.
     return Center(child: Text(AppLocalizations.of(context)!.msgMatchesComingSoon, style: textTheme.titleMedium));
  }

  Widget _buildStandingsTab(TextTheme textTheme, String? userId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 100),
      itemCount: _standings.length,
      itemBuilder: (context, index) {
        final p = _standings[index];
        final pRank = index + 1;
        final pName = p.profile != null 
            ? '${p.profile!.firstName} ${p.profile!.lastName}'.trim() 
            : AppLocalizations.of(context)!.labelUnknownPlayer;
        return _buildStandingRow(textTheme, pRank, pName, '${p.points} pts', isHighlighted: p.userId == userId);
      },
    );
  }

  Widget _buildProfileTab(TextTheme textTheme, int rank, double winRate, String? userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
            CircleAvatar(radius: 50, backgroundColor: primaryColor.withValues(alpha: 0.1), child: Text(userId != null ? 'User' : '?', style: textTheme.headlineMedium)),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.titlePlayerStats, style: textTheme.headlineSmall),
            const SizedBox(height: 16),
             _buildStatRow(textTheme, AppLocalizations.of(context)!.labelRank, '#$rank'),
             _buildStatRow(textTheme, 'Points', '${_userStats?.points ?? 0}'), // Assuming Points is generic enough or add key
             _buildStatRow(textTheme, AppLocalizations.of(context)!.labelWins, '${_userStats?.wins ?? 0}'),
             _buildStatRow(textTheme, AppLocalizations.of(context)!.labelLosses, '${_userStats?.losses ?? 0}'),
             _buildStatRow(textTheme, AppLocalizations.of(context)!.labelWinRate, '${winRate.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(TextTheme textTheme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge?.copyWith(color: textGrey)),
          Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: textDark)),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          // hover color handling is built into InkWell
        ),
        child: Icon(icon, color: textDark, size: 24),
      ),
    );
  }

  Widget _buildQuickActionCard(TextTheme textTheme, IconData icon, String label, {bool hasBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hoverTint),
          boxShadow: const [
            BoxShadow(
              color: courtShadow,
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (hasBadge)
              Positioned(
                top: 0,
                right: 30, // Adjusted based on design
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: hoverTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: primaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
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

  Widget _buildStandingRow(TextTheme textTheme, int rank, String teamName, String points, {required bool isHighlighted}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: rank == 1 ? hoverTint.withValues(alpha: 0.5) : (isHighlighted ? primaryColor.withValues(alpha: 0.05) : null)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$rank',
                  style: textTheme.bodyMedium?.copyWith(
                    color: isHighlighted ? primaryColor : textGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isHighlighted)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.labelYou,
                    style: textTheme.labelSmall?.copyWith(
                      color: primaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                 CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 20, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              Text(
                teamName,
                style: textTheme.bodyMedium?.copyWith(
                  color: isHighlighted ? primaryColor : textDark,
                  fontWeight: FontWeight.bold, // Design uses medium/bold
                ),
              ),
            ],
          ),
          Text(
            points,
            style: textTheme.bodyMedium?.copyWith(
              color: isHighlighted ? primaryColor : textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(TextTheme textTheme, bool isWin, String opponent, String date, String score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hoverTint),
        boxShadow: const [
          BoxShadow(
            color: courtShadow,
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isWin ? primaryColor : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  isWin ? AppLocalizations.of(context)!.labelWinAbbr : AppLocalizations.of(context)!.labelLossAbbr,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponent,
                    style: textTheme.bodyMedium?.copyWith(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: textTheme.labelSmall?.copyWith(
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: textTheme.bodyMedium?.copyWith(
                  color: isWin ? primaryColor : textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isWin ? AppLocalizations.of(context)!.labelMatchWon : AppLocalizations.of(context)!.labelMatchLost,
                style: textTheme.labelSmall?.copyWith(
                  color: textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(TextTheme textTheme, IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? primaryColor : textGrey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: isActive ? primaryColor : textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildJoinSessionCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and Title
           Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: Colors.white,
               shape: BoxShape.circle,
               border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
             ),
             child: const Icon(Icons.sports_tennis, size: 32, color: primaryColor),
           ),
          const SizedBox(height: 16),
          Text(
            'Join this Session!',
            style: textTheme.headlineSmall?.copyWith(
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Participate in league matches, track your stats, and climb the leaderboard.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: textGrey, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _joinSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: primaryColor.withValues(alpha: 0.3),
              ),
              child: const Text('JOIN SESSION NOW', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(TextTheme textTheme, int rank, double winRate) {
    return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: hoverTint),
              boxShadow: const [
                BoxShadow(
                  color: courtShadow,
                  offset: Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Rank Section with Background
                    Container(
                      height: 128,
                      width: double.infinity,
                      color: const Color(0xFFE6F0E6),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Decorative pattern
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DotPatternPainter(color: primaryColor.withValues(alpha: 0.2)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getOrdinal(rank),
                                style: textTheme.displayMedium?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 42,
                                ),
                              ),
                              Text(
                                'CURRENT LEAGUE RANK',
                                style: textTheme.labelSmall?.copyWith(
                                  color: textGrey,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PLAYER STATS',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: textGrey,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${_userStats?.points ?? 0} Points',
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: textDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'WIN RATE',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: textGrey,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    '${winRate.toStringAsFixed(0)}%',
                                    style: textTheme.titleLarge?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                      
                      // Next Match Card
                      if (_nextMatch != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: hoverTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.calendar_today, color: primaryColor, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'NEXT MATCH',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM d, h:mm a').format(_nextMatch!.date),
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: textDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'View details', // TODO: Show opponent
                                      style: textTheme.bodySmall?.copyWith(
                                        color: textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: primaryColor),
                            ],
                          ),
                        )
                      else
                         Container(
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Center(
                            child: Text(
                              'No upcoming matches scheduled',
                              style: textTheme.bodyMedium?.copyWith(color: textGrey),
                            ),
                          ),
                         ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

// Custom Painter for the background dots
class DotPatternPainter extends CustomPainter {
  final Color color;
  
  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotSize = 2.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        // Offset rows for hex-like pattern if desired, but grid is fine
        canvas.drawCircle(Offset(x, y), dotSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
