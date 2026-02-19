import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Tennis League'**
  String get appTitle;

  /// Main hero text on landing page
  ///
  /// In en, this message translates to:
  /// **'Your Local Tennis Community, Managed.'**
  String get heroTitle;

  /// Subtitle below hero text
  ///
  /// In en, this message translates to:
  /// **'Join leagues, track scores, and find your perfect partner.'**
  String get heroSubtitle;

  /// Button text to join a league
  ///
  /// In en, this message translates to:
  /// **'Join a League'**
  String get joinLeagueButton;

  /// Button text to sign in
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// Title for features section
  ///
  /// In en, this message translates to:
  /// **'WHY JOIN US?'**
  String get whyJoinUsTitle;

  /// Subtitle for features section
  ///
  /// In en, this message translates to:
  /// **'Built for the Love of the Game'**
  String get whyJoinUsSubtitle;

  /// No description provided for @featureLeagueManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'League Management'**
  String get featureLeagueManagementTitle;

  /// No description provided for @featureLeagueManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatic brackets, real-time standings, and seasonal play-offs made easy.'**
  String get featureLeagueManagementDesc;

  /// No description provided for @featureSmartSchedulingTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Scheduling'**
  String get featureSmartSchedulingTitle;

  /// No description provided for @featureSmartSchedulingDesc.
  ///
  /// In en, this message translates to:
  /// **'Coordinate matches and find available courts with our intelligent booking system.'**
  String get featureSmartSchedulingDesc;

  /// No description provided for @featureDetailedStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed Stats'**
  String get featureDetailedStatsTitle;

  /// No description provided for @featureDetailedStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze your serve accuracy, win rates, and track your climb up the rankings.'**
  String get featureDetailedStatsDesc;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLeagues.
  ///
  /// In en, this message translates to:
  /// **'Leagues'**
  String get navLeagues;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navFind.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get navFind;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @labelWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get labelWinRate;

  /// No description provided for @labelMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get labelMatches;

  /// No description provided for @labelRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get labelRank;

  /// No description provided for @sectionMyLeagues.
  ///
  /// In en, this message translates to:
  /// **'My Leagues'**
  String get sectionMyLeagues;

  /// No description provided for @actionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get actionViewAll;

  /// No description provided for @tagCompetitive.
  ///
  /// In en, this message translates to:
  /// **'Competitive'**
  String get tagCompetitive;

  /// No description provided for @tagTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament'**
  String get tagTournament;

  /// No description provided for @tagSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get tagSocial;

  /// No description provided for @labelNextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next Match'**
  String get labelNextMatch;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @labelLastMatch.
  ///
  /// In en, this message translates to:
  /// **'Last Match'**
  String get labelLastMatch;

  /// Title for Join Us page
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get joinUsTitle;

  /// Subtitle for Join Us page
  ///
  /// In en, this message translates to:
  /// **'Register to start your league journey.'**
  String get joinUsSubtitle;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get hintFullName;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get hintEmail;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get labelPhone;

  /// No description provided for @hintPhone.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get hintPhone;

  /// No description provided for @labelSkillLevel.
  ///
  /// In en, this message translates to:
  /// **'Skill Level'**
  String get labelSkillLevel;

  /// No description provided for @skillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skillBeginner;

  /// No description provided for @skillBeginnerDesc.
  ///
  /// In en, this message translates to:
  /// **'NTRP 1.0-2.5'**
  String get skillBeginnerDesc;

  /// No description provided for @skillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get skillIntermediate;

  /// No description provided for @skillIntermediateDesc.
  ///
  /// In en, this message translates to:
  /// **'NTRP 3.0-4.0'**
  String get skillIntermediateDesc;

  /// No description provided for @skillAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get skillAdvanced;

  /// No description provided for @skillAdvancedDesc.
  ///
  /// In en, this message translates to:
  /// **'NTRP 4.5+'**
  String get skillAdvancedDesc;

  /// No description provided for @labelPreferredHand.
  ///
  /// In en, this message translates to:
  /// **'Preferred Hand'**
  String get labelPreferredHand;

  /// No description provided for @handRight.
  ///
  /// In en, this message translates to:
  /// **'Right-handed'**
  String get handRight;

  /// No description provided for @handLeft.
  ///
  /// In en, this message translates to:
  /// **'Left-handed'**
  String get handLeft;

  /// No description provided for @welcomeBackLabel.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackLabel;

  /// No description provided for @hiUser.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String hiUser(String name);

  /// No description provided for @labelUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get labelUpcoming;

  /// No description provided for @labelOpponent.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get labelOpponent;

  /// No description provided for @actionGetDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get actionGetDirections;

  /// No description provided for @sectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get sectionQuickActions;

  /// No description provided for @actionMarkAvailability.
  ///
  /// In en, this message translates to:
  /// **'Mark\nAvailability'**
  String get actionMarkAvailability;

  /// No description provided for @actionLogScore.
  ///
  /// In en, this message translates to:
  /// **'Log Score'**
  String get actionLogScore;

  /// No description provided for @actionViewStandings.
  ///
  /// In en, this message translates to:
  /// **'View\nStandings'**
  String get actionViewStandings;

  /// No description provided for @sectionRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get sectionRecentActivity;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get actionSeeAll;

  /// No description provided for @tagAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get tagAnnouncement;

  /// No description provided for @tagMatchResult.
  ///
  /// In en, this message translates to:
  /// **'Match Result'**
  String get tagMatchResult;

  /// No description provided for @tagRankingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Ranking Update'**
  String get tagRankingUpdate;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sign up successful! Please check your email to confirm your account.'**
  String get signUpSuccess;

  /// No description provided for @passwordError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordError;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our '**
  String get termsText;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsLink;

  /// No description provided for @andText.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get andText;

  /// No description provided for @privacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logInLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logInLink;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step onto the court and manage your league'**
  String get welcomeSubtitle;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @joinUsLink.
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get joinUsLink;

  /// No description provided for @signInError.
  ///
  /// In en, this message translates to:
  /// **'Error signing in. Please check your credentials.'**
  String get signInError;

  /// No description provided for @emailNotConfirmedError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address before logging in.'**
  String get emailNotConfirmedError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @labelSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get labelSessions;

  /// No description provided for @actionCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create Session'**
  String get actionCreateSession;

  /// No description provided for @titleCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create New Session'**
  String get titleCreateSession;

  /// No description provided for @labelStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get labelStartDate;

  /// No description provided for @labelEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get labelEndDate;

  /// No description provided for @labelSessionName.
  ///
  /// In en, this message translates to:
  /// **'Session Name (Optional)'**
  String get labelSessionName;

  /// No description provided for @sessionNoActiveFound.
  ///
  /// In en, this message translates to:
  /// **'No active sessions found'**
  String get sessionNoActiveFound;

  /// No description provided for @labelCurrentSession.
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get labelCurrentSession;

  /// No description provided for @msgGoodLuck.
  ///
  /// In en, this message translates to:
  /// **'Good luck in the matches!'**
  String get msgGoodLuck;

  /// No description provided for @msgWelcomeSession.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}!'**
  String msgWelcomeSession(String name);

  /// No description provided for @actionAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get actionAvailability;

  /// No description provided for @titleStandings.
  ///
  /// In en, this message translates to:
  /// **'Standings'**
  String get titleStandings;

  /// No description provided for @actionMessageGroup.
  ///
  /// In en, this message translates to:
  /// **'Message Group'**
  String get actionMessageGroup;

  /// No description provided for @actionManagePlayers.
  ///
  /// In en, this message translates to:
  /// **'Manage Players'**
  String get actionManagePlayers;

  /// No description provided for @msgNoStandings.
  ///
  /// In en, this message translates to:
  /// **'No standings yet'**
  String get msgNoStandings;

  /// No description provided for @labelUnknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Player'**
  String get labelUnknownPlayer;

  /// No description provided for @labelYou.
  ///
  /// In en, this message translates to:
  /// **'YOU'**
  String get labelYou;

  /// No description provided for @sectionRecentResults.
  ///
  /// In en, this message translates to:
  /// **'Recent Results'**
  String get sectionRecentResults;

  /// No description provided for @msgNoCompletedMatches.
  ///
  /// In en, this message translates to:
  /// **'No completed matches yet'**
  String get msgNoCompletedMatches;

  /// No description provided for @labelWinAbbr.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get labelWinAbbr;

  /// No description provided for @labelLossAbbr.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get labelLossAbbr;

  /// No description provided for @labelMatchWon.
  ///
  /// In en, this message translates to:
  /// **'MATCH WON'**
  String get labelMatchWon;

  /// No description provided for @labelMatchLost.
  ///
  /// In en, this message translates to:
  /// **'MATCH LOST'**
  String get labelMatchLost;

  /// No description provided for @msgMatchesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Matches Tab - Coming Soon'**
  String get msgMatchesComingSoon;

  /// No description provided for @titlePlayerStats.
  ///
  /// In en, this message translates to:
  /// **'Player Stats'**
  String get titlePlayerStats;

  /// No description provided for @labelWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get labelWins;

  /// No description provided for @labelLosses.
  ///
  /// In en, this message translates to:
  /// **'Losses'**
  String get labelLosses;

  /// No description provided for @titleClubDetails.
  ///
  /// In en, this message translates to:
  /// **'Club Details'**
  String get titleClubDetails;

  /// No description provided for @labelPrimaryAdminView.
  ///
  /// In en, this message translates to:
  /// **'Primary Administrative View'**
  String get labelPrimaryAdminView;

  /// No description provided for @sectionLocation.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get sectionLocation;

  /// No description provided for @labelFullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get labelFullAddress;

  /// No description provided for @sectionCourtsInventory.
  ///
  /// In en, this message translates to:
  /// **'COURTS INVENTORY'**
  String get sectionCourtsInventory;

  /// No description provided for @labelCourtsTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} Courts Total'**
  String labelCourtsTotal(int count);

  /// No description provided for @actionAddNewCourt.
  ///
  /// In en, this message translates to:
  /// **'Add New Court'**
  String get actionAddNewCourt;

  /// No description provided for @hintCourtName.
  ///
  /// In en, this message translates to:
  /// **'Court Name (e.g., Court 1)'**
  String get hintCourtName;

  /// No description provided for @hintSurfaceType.
  ///
  /// In en, this message translates to:
  /// **'Surface Type (e.g., Red Clay)'**
  String get hintSurfaceType;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEditClubDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Club Details'**
  String get actionEditClubDetails;

  /// No description provided for @labelClubNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Club Name *'**
  String get labelClubNameRequired;

  /// No description provided for @labelLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Location *'**
  String get labelLocationRequired;

  /// No description provided for @labelCourtCount.
  ///
  /// In en, this message translates to:
  /// **'Court Count'**
  String get labelCourtCount;

  /// No description provided for @labelImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get labelImageUrl;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @msgClubUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Club updated successfully'**
  String get msgClubUpdatedSuccess;

  /// No description provided for @msgJoinedSession.
  ///
  /// In en, this message translates to:
  /// **'You have joined the session!'**
  String get msgJoinedSession;

  /// No description provided for @msgJoinSessionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join session.'**
  String get msgJoinSessionFailed;

  /// No description provided for @titleInviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get titleInviteMembers;

  /// No description provided for @labelLeagueAccessLink.
  ///
  /// In en, this message translates to:
  /// **'LEAGUE ACCESS LINK'**
  String get labelLeagueAccessLink;

  /// No description provided for @actionCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get actionCopyLink;

  /// No description provided for @msgLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get msgLinkCopied;

  /// No description provided for @labelQuickShareVia.
  ///
  /// In en, this message translates to:
  /// **'QUICK SHARE VIA...'**
  String get labelQuickShareVia;

  /// No description provided for @shareWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get shareWhatsApp;

  /// No description provided for @shareIMessage.
  ///
  /// In en, this message translates to:
  /// **'iMessage'**
  String get shareIMessage;

  /// No description provided for @shareFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get shareFacebook;

  /// No description provided for @shareMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get shareMore;

  /// No description provided for @labelAddExistingMembers.
  ///
  /// In en, this message translates to:
  /// **'ADD EXISTING MEMBERS'**
  String get labelAddExistingMembers;

  /// No description provided for @hintSearchMembers.
  ///
  /// In en, this message translates to:
  /// **'Search by name or username'**
  String get hintSearchMembers;

  /// No description provided for @labelSuggestedPlayers.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED PLAYERS'**
  String get labelSuggestedPlayers;

  /// No description provided for @msgNoUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get msgNoUsersFound;

  /// No description provided for @labelInviteViaEmail.
  ///
  /// In en, this message translates to:
  /// **'INVITE VIA EMAIL'**
  String get labelInviteViaEmail;

  /// No description provided for @hintEnterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get hintEnterEmailAddress;

  /// No description provided for @actionSendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get actionSendInvitation;

  /// No description provided for @msgInvitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get msgInvitationSent;

  /// No description provided for @labelPendingInvites.
  ///
  /// In en, this message translates to:
  /// **'PENDING INVITES ({count})'**
  String labelPendingInvites(int count);

  /// No description provided for @msgResentInvite.
  ///
  /// In en, this message translates to:
  /// **'Resent invite to {email}'**
  String msgResentInvite(String email);

  /// No description provided for @actionResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get actionResend;

  /// No description provided for @msgUserAdded.
  ///
  /// In en, this message translates to:
  /// **'{user} added to league'**
  String msgUserAdded(String user);

  /// No description provided for @msgErrorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String msgErrorLoadingUsers(String error);

  /// No description provided for @msgFailedToAddUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to add user: {error}'**
  String msgFailedToAddUser(String error);

  /// No description provided for @msgNoParticipants.
  ///
  /// In en, this message translates to:
  /// **'No participants found for this session'**
  String get msgNoParticipants;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
