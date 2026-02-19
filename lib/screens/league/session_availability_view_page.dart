import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ace_manager/models/session_participant.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/l10n/app_localizations.dart';

class SessionAvailabilityViewPage extends StatefulWidget {
  final String sessionId;
  final String sessionName;
  final List<DateTime> roundDates;

  const SessionAvailabilityViewPage({
    super.key,
    required this.sessionId,
    required this.sessionName,
    required this.roundDates,
  });

  @override
  State<SessionAvailabilityViewPage> createState() => _SessionAvailabilityViewPageState();
}

class _SessionAvailabilityViewPageState extends State<SessionAvailabilityViewPage> {
  static const primaryColor = Color(0xFF00DB6E);
  static const textDark = Color(0xFF141712);
  static const textGrey = Color(0xFF738367);
  static const availableColor = Color(0xFF00DB6E);
  static const unavailableColor = Color(0xFFFF5252);
  static const dividerColor = Color(0xFFE0E0E0);

  bool _isLoading = true;
  List<SessionParticipant> _participants = [];

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() => _isLoading = true);
    try {
      // leveraging getSessionStandings to fetch all participants with profiles
      _participants = await LeagueService.instance.getSessionStandings(widget.sessionId);
    } catch (e) {
      debugPrint('Error loading participants: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.actionAvailability, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textDark)),
            Text(widget.sessionName, style: textTheme.bodySmall?.copyWith(color: textGrey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _participants.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.msgNoParticipants, style: textTheme.bodyMedium?.copyWith(color: textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.roundDates.length,
                  itemBuilder: (context, index) {
                    final date = widget.roundDates[index];
                    return _buildDateTile(textTheme, date);
                  },
                ),
    );
  }

  Widget _buildDateTile(TextTheme textTheme, DateTime date) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(date);
    final isoDate = DateFormat('yyyy-MM-dd').format(date);

    // Filter participants
    final available = _participants.where((p) => p.availability[isoDate] == 'available').toList();
    final unavailable = _participants.where((p) => p.availability[isoDate] != 'available').toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: dividerColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(dateStr, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: textDark)),
        subtitle: Text(
          '${available.length} Available • ${unavailable.length} Unavailable',
          style: textTheme.bodySmall?.copyWith(color: textGrey),
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParticipantSection(textTheme, 'Available (${available.length})', available, true),
          const SizedBox(height: 16),
          const Divider(height: 1, color: dividerColor),
          const SizedBox(height: 16),
          _buildParticipantSection(textTheme, 'Unavailable / No Response (${unavailable.length})', unavailable, false),
        ],
      ),
    );
  }

  Widget _buildParticipantSection(TextTheme textTheme, String title, List<SessionParticipant> participants, bool isAvailable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelMedium?.copyWith(
            color: isAvailable ? availableColor : textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (participants.isEmpty)
          Text('-', style: textTheme.bodyMedium?.copyWith(color: textGrey))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: participants.map((p) {
              final name = p.profile != null 
                  ? '${p.profile!.firstName} ${p.profile!.lastName}'.trim() 
                  : AppLocalizations.of(context)!.labelUnknownPlayer;
              
              return Chip(
                avatar: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: textTheme.labelSmall?.copyWith(fontSize: 10, color: textDark)),
                ),
                label: Text(name, style: textTheme.bodySmall?.copyWith(color: textDark)),
                backgroundColor: isAvailable ? availableColor.withValues(alpha: 0.1) : Colors.grey[100],
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
      ],
    );
  }
}
