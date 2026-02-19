import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/session_creation_data.dart';
import 'package:ace_manager/screens/league/create_session_step3_page.dart';

class CreateSessionStep2Page extends StatefulWidget {
  final SessionCreationData sessionData;
  const CreateSessionStep2Page({super.key, required this.sessionData});

  @override
  State<CreateSessionStep2Page> createState() => _CreateSessionStep2PageState();
}

class _CreateSessionStep2PageState extends State<CreateSessionStep2Page> {
  final primaryColor = const Color(0xFF32D411);
  final backgroundLight = const Color(0xFFF6F8F6);

  late String _selectedGameType;
  late String _selectedFormat;
  late bool _courtPromotionEnabled;
  final _rulesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedGameType = widget.sessionData.gameType ?? 'Singles';
    _selectedFormat = widget.sessionData.format ?? 'Round Robin';
    _courtPromotionEnabled = widget.sessionData.courtPromotion;
    _rulesController.text = widget.sessionData.rules ?? '';
  }

  void _onNext() {
    // Update data object
    widget.sessionData.gameType = _selectedGameType;
    widget.sessionData.format = _selectedFormat;
    widget.sessionData.courtPromotion = _courtPromotionEnabled;
    widget.sessionData.rules = _rulesController.text;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSessionStep3Page(sessionData: widget.sessionData),
      ),
    );
  }

  @override
  void dispose() {
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chevron_left, color: primaryColor, size: 24),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'New Session',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'STEP 2 OF 4',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '50% Complete',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Format & Rules',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Game Type
                _buildSectionLabel('GAME TYPE', textTheme),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildGameTypeButton('Singles', textTheme),
                      ),
                      Expanded(
                        child: _buildGameTypeButton('Doubles', textTheme),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Session Format
                _buildSectionLabel('SESSION FORMAT', textTheme),
                const SizedBox(height: 12),
                _buildFormatCard(
                  'Round Robin',
                  'Every player plays against every other player once.',
                  textTheme,
                ),
                const SizedBox(height: 12),
                _buildFormatCard(
                  'Ladder',
                  'Players move up/down ranks based on match outcomes.',
                  textTheme,
                ),
                const SizedBox(height: 12),
                _buildFormatCard(
                  'Rotating Partner',
                  'Change partners after every set or round.',
                  textTheme,
                ),
                const SizedBox(height: 24),

                // Rules & Regulations
                _buildSectionLabel('RULES & REGULATIONS', textTheme),
                const SizedBox(height: 12),
                TextField(
                  controller: _rulesController,
                  maxLines: 5,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter league rules, court etiquette, and scoring details...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.1), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.1), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'These rules will be shared with all participants via the league dashboard.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 24),

                // Advanced Toggle (Court Promotion)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                              Text(
                                'Court Promotion',
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.info, size: 16, color: Colors.grey[400]),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Winners move to court above, losers move down.',
                              style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _courtPromotionEnabled,
                        onChanged: (value) {
                          setState(() {
                            _courtPromotionEnabled = value;
                          });
                        },
                        activeTrackColor: primaryColor.withValues(alpha: 0.5),
                        activeThumbColor: primaryColor,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: primaryColor.withValues(alpha: 0.1))),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.2), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'BACK',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: primaryColor.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          'NEXT STEP',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
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

  Widget _buildSectionLabel(String text, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGameTypeButton(String type, TextTheme textTheme) {
    bool isSelected = _selectedGameType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGameType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ] : null,
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? primaryColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatCard(String title, String subtitle, TextTheme textTheme) {
    bool isSelected = _selectedFormat == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1),
            width: 2
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ) : null,
            ),
          ],
        ),
      ),
    );
  }
}
