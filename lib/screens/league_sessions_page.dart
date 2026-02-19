import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:intl/intl.dart';
import 'package:ace_manager/l10n/app_localizations.dart';
import 'package:ace_manager/screens/league/create_session_page.dart';

class LeagueSessionsPage extends StatefulWidget {
  final String leagueId;
  final String leagueName;
  final bool isOwner;

  const LeagueSessionsPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.isOwner,
  });

  @override
  State<LeagueSessionsPage> createState() => _LeagueSessionsPageState();
}

class _LeagueSessionsPageState extends State<LeagueSessionsPage> {
  static const primaryColor = Color(0xFF00DB6E);
  late Future<List<LeagueSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = LeagueService.instance.getLeagueSessions(widget.leagueId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.leagueName} ${AppLocalizations.of(context)!.labelSessions}', style: textTheme.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<LeagueSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sessions = snapshot.data ?? [];

          if (sessions.isEmpty && !widget.isOwner) {
            return const Center(child: Text('No active sessions.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(context, textTheme, session);
            },
          );
        },
      ),
      floatingActionButton: widget.isOwner
          ? FloatingActionButton.extended(
              onPressed: _showCreateSessionDialog,
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppLocalizations.of(context)!.actionCreateSession,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildSessionCard(BuildContext context, TextTheme textTheme, LeagueSession session) {
    final dateFormat = DateFormat.yMMMd();
    final dateRange = '${dateFormat.format(session.startDate)} - ${session.endDate != null ? dateFormat.format(session.endDate!) : 'Ongoing'}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          session.name ?? 'Session',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateRange,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (session.status?.toLowerCase() == 'active')
                    ? primaryColor.withValues(alpha: 0.1)
                    : ((session.status?.toLowerCase() == 'upcoming') ? Colors.blue[50] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                (session.status?.toUpperCase() ?? 'UPCOMING'),
                style: textTheme.labelSmall?.copyWith(
                  color: (session.status?.toLowerCase() == 'active') ? primaryColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // TODO: Navigate to session details (standings, matches, etc.)
        },
      ),
    );
  }

  void _showCreateSessionDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSessionPage(leagueId: widget.leagueId),
      ),
    ).then((_) => _loadSessions());
  }
}
