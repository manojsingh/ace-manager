import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/models/session_participant.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SessionSchedulePage extends StatefulWidget {
  final String leagueId;
  final String sessionId;
  final String sessionName;

  const SessionSchedulePage({
    super.key,
    required this.leagueId,
    required this.sessionId,
    required this.sessionName,
  });

  @override
  State<SessionSchedulePage> createState() => _SessionSchedulePageState();
}

class _SessionSchedulePageState extends State<SessionSchedulePage> {
  static const primaryColor = Color(0xFF00DB6E);
  static const textDark = Color(0xFF141712);
  static const textGrey = Color(0xFF738367);
  static const hoverTint = Color(0xFFF0F8EE);

  bool _isLoading = true;
  LeagueSession? _session;
  SessionParticipant? _participant;
  Map<String, String> _availability = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // 1. Fetch Session for dates
      final sessions = await LeagueService.instance.getLeagueSessions(widget.leagueId);
      _session = sessions.firstWhere((s) => s.id == widget.sessionId, orElse: () => sessions.first);

      // 2. Fetch Participant for existing availability
      _participant = await LeagueService.instance.getUserSessionStats(widget.sessionId, userId);
      
      if (_participant != null) {
        _availability = Map.from(_participant!.availability);
      } else {
        // User not part of session? Should handle gracefully
         _availability = {};
      }

    } catch (e) {
      debugPrint('Error loading schedule: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateAvailability(DateTime date, String status) async {
    if (_participant == null) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    
    // Optimistic update
    setState(() {
      _availability[dateKey] = status;
    });

    try {
      setState(() => _isSaving = true);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await LeagueService.instance.updateParticipantAvailability(
          widget.sessionId, 
          userId, 
          _availability
        );
      }
    } catch (e) {
      // Revert on error? Or just show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save availability')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Availability',
          style: textTheme.titleLarge?.copyWith(
            color: textDark, 
            fontWeight: FontWeight.bold
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: _isSaving 
              ? const LinearProgressIndicator(color: primaryColor, minHeight: 2) 
              : const Divider(height: 1),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _session == null 
              ? const Center(child: Text('Session not found'))
              : _buildScheduleList(textTheme),
    );
  }

  Widget _buildScheduleList(TextTheme textTheme) {
    if (_session!.roundDates.isEmpty) {
      return Center(
        child: Text(
          'No scheduled dates for this session yet.',
          style: textTheme.bodyMedium?.copyWith(color: textGrey),
        ),
      );
    }

    final sortedDates = List<DateTime>.from(_session!.roundDates)..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final status = _availability[dateKey] ?? 'unknown';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: hoverTint),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE6F0E6),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              // Date
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: hoverTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(date).toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('d').format(date),
                      style: textTheme.headlineSmall?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Status & Toggle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(date),
                      style: textTheme.bodyMedium?.copyWith(
                        color: textDark, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(
                          textTheme, 
                          label: 'Available', 
                          isSelected: status == 'available',
                          color: primaryColor,
                          onTap: () => _updateAvailability(date, 'available'),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          textTheme, 
                          label: 'Unavailable', 
                          isSelected: status == 'unavailable',
                          color: Colors.redAccent,
                          onTap: () => _updateAvailability(date, 'unavailable'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(
    TextTheme textTheme, {
    required String label, 
    required bool isSelected, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: isSelected ? color : textGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
