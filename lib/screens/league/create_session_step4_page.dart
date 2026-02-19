import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/session_creation_data.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:intl/intl.dart';

class CreateSessionStep4Page extends StatefulWidget {
  final SessionCreationData sessionData;
  const CreateSessionStep4Page({super.key, required this.sessionData});

  @override
  State<CreateSessionStep4Page> createState() => _CreateSessionStep4PageState();
}

class _CreateSessionStep4PageState extends State<CreateSessionStep4Page> {
  static const primaryColor = Color(0xFF32D411);
  static const backgroundLight = Color(0xFFF6F8F6);
  bool _isSubmitting = false;

  Future<void> _launchSession() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final sessionData = widget.sessionData;
      // Use mock league ID if none provided (e.g. testing)
      final leagueId = sessionData.leagueId ?? 'mock-league-id'; 

      await LeagueService.instance.createSession(
        leagueId: leagueId,
        name: sessionData.name ?? 'New Session',
        startDate: sessionData.startDate ?? DateTime.now(),
        endDate: sessionData.endDate,
        format: sessionData.format,
        gameType: sessionData.gameType,
        rules: sessionData.rules,
        courtPromotion: sessionData.courtPromotion,
        participantIds: sessionData.selectedMemberIds,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session Launched Successfully!'),
            backgroundColor: primaryColor,
          ),
        );
        // Return to Dashboard (pop until first)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error launching session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: 0,
            right: -128,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),

            ),
          ),
           Positioned(
            bottom: 0,
            left: -128,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            children: [
              // Sticky Header
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          'Review Session',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 20), // Spacer
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    children: [
                      // Progress Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'FINAL STEP',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '4 of 4',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Hero Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[100]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: -10,
                              right: -10,
                              child: Icon(
                                Icons.sports_tennis,
                                size: 80,
                                color: primaryColor.withValues(alpha: 0.1),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.sessionData.name ?? 'New Session',
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.sessionData.location ?? 'TBD',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Schedule Section
                      _buildSummarySection(
                        textTheme,
                        icon: Icons.calendar_today,
                        title: 'Schedule',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(textTheme, 'Starts', 
                                    widget.sessionData.startDate != null 
                                      ? dateFormat.format(widget.sessionData.startDate!) 
                                      : 'TBD'),
                                ),
                                Expanded(
                                  child: _buildInfoItem(textTheme, 'Ends', 
                                    widget.sessionData.endDate != null 
                                      ? dateFormat.format(widget.sessionData.endDate!) 
                                      : 'TBD'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Format Section
                      _buildSummarySection(
                        textTheme,
                        icon: Icons.emoji_events,
                        title: 'League Format',
                        child: Column(
                          children: [
                            _buildRowItem(textTheme, 'Competition Type', widget.sessionData.format ?? 'Round Robin'),
                            const SizedBox(height: 8),
                            _buildRowItem(textTheme, 'Match Format', widget.sessionData.gameType ?? 'Singles'),
                            const SizedBox(height: 8),
                            _buildRowItem(textTheme, 'Court Promotion', widget.sessionData.courtPromotion ? 'Enabled' : 'Disabled'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Participants Section
                      _buildSummarySection(
                        textTheme,
                        icon: Icons.group,
                        title: 'Participants',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${widget.sessionData.selectedMemberIds.length} Selected',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        child: const SizedBox.shrink(), // Can expand to show list preview if needed
                      ),
                      
                      // Rules Preview (Only if rules exist)
                      if (widget.sessionData.rules != null && widget.sessionData.rules!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid, 
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.description, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rules & Terms',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.sessionData.rules!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      Text(
                        'BY LAUNCHING, YOU AGREE TO THE AUTOMATED SCHEDULING AND RANKING ALGORITHMS.',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: Colors.grey[400],
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _launchSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withValues(alpha: 0.2),
                        minimumSize: const Size(double.infinity, 56), 
                      ),
                      child: _isSubmitting 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.rocket_launch, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Launch Session',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {}, // TODO: Implement Draft Save
                      child: Text(
                        'Save as Draft',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(TextTheme textTheme, {
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(TextTheme textTheme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: Colors.grey[400],
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRowItem(TextTheme textTheme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
