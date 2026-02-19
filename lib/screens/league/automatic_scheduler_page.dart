import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AutomaticSchedulerPage extends StatefulWidget {
  final String sessionId;
  final String sessionName;

  const AutomaticSchedulerPage({
    super.key,
    required this.sessionId,
    required this.sessionName,
  });

  @override
  State<AutomaticSchedulerPage> createState() => _AutomaticSchedulerPageState();
}

class _AutomaticSchedulerPageState extends State<AutomaticSchedulerPage> {
  // Theme Colors from HTML design
  static const primaryColor = Color(0xFF69ba2c);
  static const backgroundLight = Color(0xFFffffff);
  static const courtShadow = Color(0xFFE6F0E6); // shadow-tennis in tailwind config is rgba(230, 240, 230, 0.6)
  static const courtTint = Color(0xFFF0F8EE);
  static const courtGrey = Color(0xFFE0E0E0);
  static const textDark = Color(0xFF141712);
  static const textGrey = Color(0xFF738367);

  bool _balanceTeams = true;
  bool _prioritizeNewMatchups = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: courtGrey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Automatic Scheduler',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const IconButton(
                    icon: Icon(Icons.info_outline, color: primaryColor),
                    onPressed: null, // Info action
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100), // Space for fixed footer
                children: [
                  const SizedBox(height: 16),
                  
                  // Stats Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(textTheme, 'Players Available', '24', Icons.group),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(textTheme, 'Courts Needed', '6', Icons.sports_tennis),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logic Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: courtTint,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheduling Logic',
                                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: textDark),
                              ),
                              Text(
                                'Using Court Promotion & Availability data',
                                style: textTheme.bodySmall?.copyWith(color: textGrey, fontSize: 10),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {}, 
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: primaryColor,
                            ),
                            child: Row(
                              children: [
                                Text('EDIT', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
                                const Icon(Icons.chevron_right, size: 16, color: primaryColor),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Configuration Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONFIGURATION',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textGrey,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: courtGrey),
                            boxShadow: const [
                              BoxShadow(color: courtShadow, blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildToggleRow(
                                textTheme, 
                                'Balance Teams', 
                                'Ensure even skill distribution', 
                                _balanceTeams, 
                                (val) => setState(() => _balanceTeams = val),
                              ),
                              const Divider(height: 1, color: courtGrey),
                              _buildToggleRow(
                                textTheme, 
                                'Prioritize New Matchups', 
                                'Avoid repetitive pairings', 
                                _prioritizeNewMatchups, 
                                (val) => setState(() => _prioritizeNewMatchups = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Court Assignment Preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'COURT ASSIGNMENT PREVIEW',
                              style: textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textGrey,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ROUND 1',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Mock Cards for Preview
                        _buildCourtCard(textTheme, 'COURT 1 (Pro)', true, [
                          _Player('A. Murray', 'AM'),
                          _Player('R. Federer', 'RF'),
                          _Player('R. Nadal', 'RN'),
                          _Player('N. Djokovic', 'ND'),
                        ]),
                        const SizedBox(height: 12),
                        _buildCourtCard(textTheme, 'COURT 2 (Advanced)', false, [
                          _Player('J. Williams', 'JW'),
                          _Player('S. Osaka', 'SO'),
                          _Player('I. Swiatek', 'IS'),
                          _Player('C. Gauff', 'CG'),
                        ]),
                         const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: courtGrey, style: BorderStyle.solid), // Dashed border not native, solid for now or CustomPainter
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text('Pending Court 3-6...', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: textDark)),
                               const Icon(Icons.hourglass_empty, color: courtGrey, size: 20),
                            ],
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16), // Padding for the floating effect
        child: Container(
             decoration: const BoxDecoration(
               color: Colors.transparent, 
             ),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, primaryColor], // Single color for now, can add gradient
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Generate & Preview Schedule',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                   Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: courtGrey),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                         foregroundColor: textDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_calendar, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Manual Adjustments',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
               ],
             )
        ),
      )
    );
  }

  Widget _buildStatCard(TextTheme textTheme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: courtGrey),
        boxShadow: const [
           BoxShadow(color: courtShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: textGrey,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: primaryColor, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(TextTheme textTheme, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: textDark)),
              Text(subtitle, style: textTheme.bodySmall?.copyWith(color: textGrey, fontSize: 12)),
            ],
          ),
          Switch.adaptive(
            value: value, 
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCourtCard(TextTheme textTheme, String courtName, bool isPro, List<_Player> players) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: courtGrey),
        boxShadow: const [
           BoxShadow(color: courtShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(courtName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: textDark)),
              if (isPro) const Icon(Icons.stars, color: primaryColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: courtGrey),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.0,
            children: players.map((p) => Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: courtTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(p.initials, style: textTheme.labelSmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Text(p.name, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: textDark)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _Player {
  final String name;
  final String initials;
  _Player(this.name, this.initials);
}
