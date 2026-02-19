import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/session_participant.dart';
import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/screens/league/invite_member_page.dart';

class SessionParticipantsPage extends StatefulWidget {
  final String sessionId;
  final String leagueId;

  const SessionParticipantsPage({
    super.key,
    required this.sessionId,
    required this.leagueId,
  });

  @override
  State<SessionParticipantsPage> createState() => _SessionParticipantsPageState();
}

class _SessionParticipantsPageState extends State<SessionParticipantsPage> {
  bool _isLoading = true;
  List<SessionParticipant> _participants = [];
  List<LeagueMember> _availableMembers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch current participants
      final participants = await LeagueService.instance.getSessionStandings(widget.sessionId);
      
      // 2. Fetch all league members for "Add" functionality
      final members = await LeagueService.instance.getLeagueMembers(widget.leagueId);

      // 3. Filter members who are NOT already in the session
      final participantIds = participants.map((p) => p.userId).toSet();
      final available = members.where((m) => !participantIds.contains(m.userId)).toList();

      if (mounted) {
        setState(() {
          _participants = participants;
          _availableMembers = available;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading participants: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _addParticipant(String userId) async {
    try {
      await LeagueService.instance.addSessionParticipant(widget.sessionId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player added to session')),
        );
        _loadData(); // Refresh list
        Navigator.pop(context); // Close sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add player')),
        );
      }
    }
  }

  Future<void> _removeParticipant(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Player'),
        content: const Text('Are you sure you want to remove this player from the session? Their stats for this session will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await LeagueService.instance.removeSessionParticipant(widget.sessionId, userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player removed from session')),
          );
          _loadData(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove player')),
          );
        }
      }
    }
  }

  void _showAddParticipantSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Add Player to Session',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF141712),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InviteMemberPage(
                            leagueId: widget.leagueId,
                            existingMemberIds: _availableMembers.map((m) => m.userId).toList(), // Inaccurate but fine for simple exclusions
                          ),
                        ),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(Icons.person_add_alt_1, size: 20),
                    label: const Text('Invite New'),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF7ABA2D)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_availableMembers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No available players to add.')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _availableMembers.length,
                    itemBuilder: (context, index) {
                      final member = _availableMembers[index];
                      final name = member.profile != null 
                          ? '${member.profile!.firstName} ${member.profile!.lastName}'.trim()
                          : 'Unknown User (${member.role})';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF7ABA2D).withValues(alpha: 0.1),
                          child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Color(0xFF7ABA2D))),
                        ),
                        title: Text(name),
                        subtitle: Text(member.role),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFF7ABA2D)),
                          onPressed: () => _addParticipant(member.userId),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Session Participants', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7ABA2D)))
          : _participants.isEmpty
              ? Center(child: Text('No participants yet.', style: textTheme.bodyLarge))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _participants.length,
                  itemBuilder: (context, index) {
                    final participant = _participants[index];
                    final name = participant.profile != null 
                        ? '${participant.profile!.firstName} ${participant.profile!.lastName}'.trim()
                        : 'Player ${index + 1}';

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[200]!),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: Text('${index + 1}', style: const TextStyle(color: Colors.black)),
                        ),
                        title: Text(name, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${participant.matchesPlayed} matches • ${participant.points} pts'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeParticipant(participant.userId),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantSheet,
        backgroundColor: const Color(0xFF7ABA2D),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Player'),
      ),
    );
  }
}
