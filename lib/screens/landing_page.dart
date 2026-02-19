
import 'package:flutter/material.dart';
import 'package:ace_manager/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/screens/join_us_page.dart';
import 'package:ace_manager/screens/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Defined colors from tailwind config
    const primaryColor = Color(0xFF39C91D);
    const backgroundLight = Color(0xFFF6F8F6);
    // const backgroundDark = Color(0xFF142111); // For dark mode support later

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sports_tennis, color: primaryColor),
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.appTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF121711),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.015,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Spacer for centering
                      ],
                    ),
                  ),
                ),

                // Hero Section
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 520),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: const AssetImage('assets/images/tennis_hero.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.4),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.heroTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(
                            color: Colors.white,
                            fontSize: 36, // 4xl/5xl approximation
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.033,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.heroSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Buttons
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const JoinUsPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: GoogleFonts.epilogue(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.015,
                                ),
                                elevation: 4,
                                minimumSize: const Size(180, 48),
                              ),
                              child: Text(AppLocalizations.of(context)!.joinLeagueButton),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: const BorderSide(color: primaryColor, width: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                textStyle: GoogleFonts.epilogue(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.015,
                                ),
                                minimumSize: const Size(180, 48),
                              ),
                              child: Text(AppLocalizations.of(context)!.signInButton),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Features Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.whyJoinUsTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4, // 0.1em approx
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.whyJoinUsSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF121711),
                          fontSize: 20, // xl approx
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Features List
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.emoji_events,
                        title: AppLocalizations.of(context)!.featureLeagueManagementTitle,
                        description:
                            AppLocalizations.of(context)!.featureLeagueManagementDesc,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.calendar_month,
                        title: AppLocalizations.of(context)!.featureSmartSchedulingTitle,
                        description:
                            AppLocalizations.of(context)!.featureSmartSchedulingDesc,
                        primaryColor: primaryColor,
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.ssid_chart, // monitoring -> ssid_chart or similar
                        title: AppLocalizations.of(context)!.featureDetailedStatsTitle,
                        description:
                            AppLocalizations.of(context)!.featureDetailedStatsDesc,
                        primaryColor: primaryColor,
                      ),
                    ],
                  ),
                ),

                // Bottom Spacer for Nav Bar
                const SizedBox(height: 80),
              ],
            ),
          ),
          
          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white.withValues(alpha: 0.9),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), // account for safe area
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home,
                    label: AppLocalizations.of(context)!.navHome,
                    color: primaryColor,
                    isActive: true,
                  ),
                  _buildNavItem(
                    icon: Icons.sports_tennis,
                    label: AppLocalizations.of(context)!.navLeagues,
                    color: Colors.grey[400]!,
                    isActive: false,
                  ),
                  _buildNavItem(
                    icon: Icons.person,
                    label: AppLocalizations.of(context)!.navProfile,
                    color: Colors.grey[400]!,
                    isActive: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.epilogue(
                    color: const Color(0xFF121711),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.epilogue(
                    color: Colors.grey[500],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
