import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/league_session.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:intl/intl.dart';

class ConfigureSessionPage extends StatefulWidget {
  final String leagueId;
  final String sessionId;
  final String sessionName;

  const ConfigureSessionPage({
    super.key,
    required this.leagueId,
    required this.sessionId,
    required this.sessionName,
  });

  @override
  State<ConfigureSessionPage> createState() => _ConfigureSessionPageState();
}

class _ConfigureSessionPageState extends State<ConfigureSessionPage> {
  // Theme Colors
  static const primaryColor = Color(0xFF3CDD57); // #3cdd57
  static const backgroundLight = Colors.white; // #ffffff
  static const textDark = Color(0xFF141712); // #141712
  static const surfaceLight = Color(0xFFF7F7F7);
  static const courtTint = Color(0xFFF0F8EE);

  int _numberOfRounds = 6;
  List<DateTime> _roundDates = [];
  bool _isLoading = true;
  LeagueSession? _session;
  bool _autoSpacing = true;

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    // In a real app, might want a specific getSession(id) or re-fetch list
    // For now, fetching all league sessions and finding ours
    final sessions = await LeagueService.instance.getLeagueSessions(widget.leagueId);
    try {
      final session = sessions.firstWhere((s) => s.id == widget.sessionId);
      if (mounted) {
        setState(() {
          _session = session;
          if (session.roundDates.isNotEmpty) {
            _roundDates = List.from(session.roundDates);
            _numberOfRounds = _roundDates.length;
          } else {
            // Default initialization
            _numberOfRounds = 6;
            _generateDefaultDates(session.startDate, 6);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading session: $e')),
        );
      }
    }
  }

  void _generateDefaultDates(DateTime startDate, int rounds) {
    _roundDates = [];
    // Assume weekly on Saturdays? Or just start from startDate + 7 days each
    // Adjust logic to find next Saturday if startDate is not a Saturday?
    // Using simple weekly intervals for now starting from startDate
    for (int i = 0; i < rounds; i++) {
      _roundDates.add(startDate.add(Duration(days: i * 7)));
    }
  }

  void _updateRounds(int rounds) {
    setState(() {
      _numberOfRounds = rounds;
      if (_roundDates.length < rounds) {
        // Add more dates
        final lastDate = _roundDates.isNotEmpty ? _roundDates.last : (_session?.startDate ?? DateTime.now());
        for (int i = 0; i < rounds - _roundDates.length; i++) {
          _roundDates.add(lastDate.add(Duration(days: (i + 1) * 7))); // Add weekly
        }
      } else if (_roundDates.length > rounds) {
        // specific length
        _roundDates = _roundDates.sublist(0, rounds);
      }
    });
  }
  
  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _roundDates[index],
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _roundDates[index]) {
      setState(() {
        _roundDates[index] = picked;
        _autoSpacing = false; // Manually edited, disable auto flag visual
      });
    }
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);
    try {
      await LeagueService.instance.updateSessionSchedule(widget.sessionId, _roundDates);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule saved successfully and visible to users!')),
      );
      // Optional: Pop or just confirm save
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving schedule: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    if (_isLoading && _session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: textDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configure Session',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
            
            // Sub-header (Session Name)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F8EE), // court-tint/50
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    widget.sessionName,
                    style: textTheme.labelMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Scale Section
                    Text(
                      'Session Scale',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: courtTint),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE6F0E6).withValues(alpha: 0.8),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
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
                                    'Number of Rounds',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total rounds for this session',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF738367),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: courtTint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    _buildQuantityButton(
                                      icon: Icons.remove, 
                                      onPressed: _numberOfRounds > 1 ? () => _updateRounds(_numberOfRounds - 1) : null,
                                      isActive: false
                                    ),
                                    SizedBox(
                                      width: 40, 
                                      child: Text(
                                        '$_numberOfRounds',
                                        textAlign: TextAlign.center,
                                        style: textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      )
                                    ),
                                    _buildQuantityButton(
                                      icon: Icons.add, 
                                      onPressed: _numberOfRounds < 20 ? () => _updateRounds(_numberOfRounds + 1) : null,
                                      isActive: true
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Slider
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: Colors.grey[200],
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                                  overlayColor: primaryColor.withValues(alpha: 0.1),
                                  trackHeight: 6,
                                ),
                                child: Slider(
                                  value: _numberOfRounds.toDouble(),
                                  min: 1,
                                  max: 12, // UI example shows 12 max text
                                  divisions: 11,
                                  onChanged: (val) => _updateRounds(val.round()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('1 ROUND', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF738367), fontWeight: FontWeight.bold)),
                                    Text('12 ROUNDS', style: textTheme.labelSmall?.copyWith(color: const Color(0xFF738367), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Round Dates Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Round Dates',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (_autoSpacing)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: courtTint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'AUTOMATIC SPACING ON',
                              style: textTheme.labelSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ...List.generate(_roundDates.length, (index) {
                      final date = _roundDates[index];
                      // Highlight every 3rd or specific ones? The design has highlighting (e.g. index 2).
                      // We'll mimic selection if tapped, but for now just standard list
                      // Design shows Round 3 highlighted as green. 
                      // Let's make Selection logic: clicking one highlights it.
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRoundItem(context, textTheme, index + 1, date, () => _selectDate(context, index)),
                      );
                    })
                  ],
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveSchedule,
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Save Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tab Bar (Mock for visuals as per image, though usually this is global nav)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(Icons.home, 'Home', false),
                      _buildBottomNavItem(Icons.emoji_events, 'Leagues', false),
                      _buildBottomNavItem(Icons.calendar_today, 'Schedules', true),
                      _buildBottomNavItem(Icons.group, 'Players', false),
                      _buildBottomNavItem(Icons.settings, 'Settings', false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback? onPressed, required bool isActive}) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: isActive ? Colors.white : primaryColor),
        style: IconButton.styleFrom(
          backgroundColor: isActive ? primaryColor : Colors.white,
          side: isActive ? null : const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildRoundItem(BuildContext context, TextTheme textTheme, int roundNum, DateTime date, VoidCallback onTap) {
    // Check if it's the current "simulated hover" state or just standard?
    // We will stick to standard style unless we track selected state.
    // The design shows index 3 (Round 3) highlighted.
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: courtTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$roundNum',
                style: textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUND $roundNum',
                    style: textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF738367),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('EEEE, MMM d, y').format(date),
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_month, color: const Color(0xFFE0E0E0)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? primaryColor : const Color(0xFF738367)),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? primaryColor : const Color(0xFF738367),
          ),
        ),
      ],
    );
  }
}
