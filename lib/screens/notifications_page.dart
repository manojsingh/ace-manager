
import 'package:ace_manager/services/league_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Theme Colors (from provided design/HTML)
  static const primaryColor = Color(0xFF3DC322); // Tennis Green
  static const backgroundLight = Color(0xFFFFFFFF);
  static const charcoal = Color(0xFF313336);
  static const dividerColor = Color(0xFFF1F5F9); // approximates hsl(210, 10%, 95%)

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await LeagueService.instance.getNotifications();
      setState(() => _notifications = notifications);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Optimistic update
      final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
      if (unreadIds.isEmpty) return;

      setState(() {
        _notifications = _notifications.map((n) {
          if (!n.isRead) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
      });

      await LeagueService.instance.markAllNotificationsAsRead();
    } catch (e) {
      // Revert if needed, but for 'mark read' silent failure is often acceptable
      debugPrint('Error marking all as read: $e');
      _loadNotifications(); // Reload to sync
    }
  }

  Future<void> _markSingleAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic update
    setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notification.id) {
             return NotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              message: n.message,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
           return n;
        }).toList();
    });

    try {
      await LeagueService.instance.markNotificationAsRead(notification.id);
    } catch (e) {
       debugPrint('Error marking notification: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Use Lexend to match the rest of the app, though design asked for Epilogue.
    // Sticking to app theme for consistency unless strictly overridden.
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    // Group notifications
    final today = DateTime.now();
    final groupings = <String, List<NotificationModel>>{};

    for (var n in _notifications) {
      final date = n.createdAt.toLocal();
      String key;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        key = 'Today';
      } else if (date.year == today.year && date.month == today.month && date.day == today.day - 1) {
        key = 'Yesterday';
      } else {
        key = 'Earlier';
      }
      groupings.putIfAbsent(key, () => []).add(n);
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: charcoal),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      hoverColor: dividerColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  Text(
                    'Notifications',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all, size: 22, color: charcoal),
                    tooltip: 'Mark all as read',
                     style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      hoverColor: dividerColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: dividerColor),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('No notifications yet', style: textTheme.bodyLarge?.copyWith(color: charcoal)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            if (groupings.containsKey('Today')) 
                              _buildSection('Today', groupings['Today']!, textTheme),
                            if (groupings.containsKey('Yesterday'))
                              _buildSection('Yesterday', groupings['Yesterday']!, textTheme),
                            if (groupings.containsKey('Earlier'))
                              _buildSection('Earlier', groupings['Earlier']!, textTheme),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<NotificationModel> sectionNotifications, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...sectionNotifications.map((n) => _buildNotificationCard(n, textTheme)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, TextTheme textTheme) {
    // Determine icon based on type/content
    IconData icon;
    Color iconColor;
    Color iconBg;

    // Mapping based on "type" or inferring from title for demo purposes
    // Ideally use notification.type enum
    final titleLower = notification.title.toLowerCase();
    if (titleLower.contains('promotion') || titleLower.contains('rank')) {
      icon = Icons.workspace_premium;
      iconColor = primaryColor;
      iconBg = primaryColor.withValues(alpha: 0.2);
    } else if (titleLower.contains('invite') || titleLower.contains('session')) {
      icon = Icons.event_available;
      iconColor = primaryColor;
      iconBg = primaryColor.withValues(alpha: 0.2);
    } else if (titleLower.contains('schedule') || titleLower.contains('matchup')) {
      icon = Icons.calendar_today;
      iconColor = const Color(0xFF64748B); // Slate 500
      iconBg = const Color(0xFFF1F5F9); // Slate 100
    } else if (titleLower.contains('result')) {
      icon = Icons.sports_tennis;
      iconColor = const Color(0xFF64748B);
      iconBg = const Color(0xFFF1F5F9);
    } else {
      icon = Icons.notifications;
      iconColor = const Color(0xFF64748B);
      iconBg = const Color(0xFFF1F5F9);
    }
    
    // TimeAgo string
    final now = DateTime.now();
    final diff = now.difference(notification.createdAt.toLocal());
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = 'Yesterday'; // Simplified for "Yesterday" grouping, else DateFormat
      if (diff.inDays > 1) timeAgo = DateFormat('MMM d').format(notification.createdAt.toLocal());
    }

    return GestureDetector(
      onTap: () {
          _markSingleAsRead(notification);
          // Handle navigation based on data if needed
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? dividerColor : primaryColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
             BoxShadow(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.5), // shadow-gray
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
             )
          ]
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: notification.isRead ? const Color(0xFF1E293B) : charcoal, // slate-800 vs charcoal
                                height: 1.2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 2), // Adjust alignment
                            child: Text(
                              timeAgo,
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF94A3B8), // slate-400
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0), // Space for dot if present
                        child: Text(
                          notification.message,
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF475569), // slate-600
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Action Button (Mockup logic based on type)
                      if (!notification.isRead && (notification.title.contains('Promotion') || notification.title.contains('Rank')))
                        _buildActionButton('View Rankings', isPrimary: false),
                      if (!notification.isRead && (notification.title.contains('Invite')))
                        _buildActionButton('Register Now', isPrimary: true),
                      if (notification.isRead && notification.title.contains('Schedule'))
                         _buildLinkButton('View Matchup'),

                    ],
                  ),
                ),
              ],
            ),
            
            // Unread Dot
            if (!notification.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, {bool isPrimary = true}) {
    if (isPrimary) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
             BoxShadow(
               color: primaryColor.withValues(alpha: 0.2),
               blurRadius: 2,
               offset: const Offset(0, 1),
             )
          ]
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
         decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.05),
               blurRadius: 2,
               offset: const Offset(0, 1),
             )
          ]
        ),
        child: Text(
          label,
          style: GoogleFonts.lexend(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
  }

  Widget _buildLinkButton(String label) {
     return Text(
       label,
       style: GoogleFonts.lexend(
         color: primaryColor,
         fontWeight: FontWeight.bold,
         fontSize: 12,
       ),
     );
  }
}
