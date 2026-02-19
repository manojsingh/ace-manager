import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/user_profile.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/l10n/app_localizations.dart';

class InviteMemberPage extends StatefulWidget {
  final String leagueId;
  final List<String>? existingMemberIds;

  const InviteMemberPage({
    super.key,
    required this.leagueId,
    this.existingMemberIds,
  });

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  static const primaryColor = Color(0xFF00DB6E);
  static const backgroundColor = Color(0xFFF6F8F6);
  static const textColor = Color(0xFF121811);
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  List<UserProfile> _allUsers = [];
  List<UserProfile> _filteredUsers = []; // Suggested players
  bool _isLoading = true;
  final Set<String> _pendingAdditions = {}; // IDs being added via API

  // Mock data for Pending Invites display
  final List<Map<String, String>> _mockPendingInvites = [
    {'email': 'mike.smith@gmail.com', 'time': 'Sent 2 hours ago'},
    {'email': 'sarah.j@outlook.com', 'time': 'Sent yesterday'},
    {'email': 'tennis.pro@yahoo.com', 'time': 'Sent 3 days ago'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
         _filteredUsers = _allUsers.take(3).toList(); // Show first 3 as suggestions
      } else {
        _filteredUsers = _allUsers.where((user) {
          final matchesName = user.fullName.toLowerCase().contains(query);
          final matchesEmail = user.email.toLowerCase().contains(query);
          return matchesName || matchesEmail;
        }).toList();
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    try {
      final users = await LeagueService.instance.getAllProfiles();
      List<String>? currentMemberIds = widget.existingMemberIds;
      if (currentMemberIds == null) {
        final members = await LeagueService.instance.getLeagueMembers(widget.leagueId);
        currentMemberIds = members.map((u) => u.id).toList();
      }

      if (mounted) {
        setState(() {
          // Filter out users who are already members
          _allUsers = users.where((u) => !currentMemberIds!.contains(u.id)).toList();
          // Initially show just a few "suggested" users
          _filteredUsers = _allUsers.take(3).toList(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.msgErrorLoadingUsers(e.toString()))),
        );
      }
    }
  }

  Future<void> _addMember(UserProfile user) async {
    setState(() {
      _pendingAdditions.add(user.id);
    });

    try {
      await LeagueService.instance.addMember(widget.leagueId, user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.msgUserAdded(user.displayName))),
        );
        setState(() {
          _allUsers.removeWhere((u) => u.id == user.id);
          _filteredUsers.removeWhere((u) => u.id == user.id);
          _pendingAdditions.remove(user.id);
        });
      }
    } catch (e) {
      if (mounted) {
         setState(() {
          _pendingAdditions.remove(user.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.msgFailedToAddUser(e.toString()))),
        );
      }
    }
  }

  void _copyLink() {
    Clipboard.setData(const ClipboardData(text: 'tennis.app/league/spring-2024'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.msgLinkCopied)),
    );
  }

  void _sendEmailInvite() {
    if (_emailController.text.isEmpty) return;
    // Mock functionality
    setState(() {
      _mockPendingInvites.insert(0, {
        'email': _emailController.text,
        'time': 'Sent just now',
      });
      _emailController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.msgInvitationSent)),
    );
     FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.1))),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: const Icon(Icons.arrow_back, color: textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.titleInviteMembers,
                    style: textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshUsers,
                color: primaryColor,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                  // Share Link Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.link, color: primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.labelLeagueAccessLink,
                              style: textTheme.labelSmall?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'tennis.app/league/spring-2024',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _copyLink,
                            icon: const Icon(Icons.content_copy, size: 18),
                            label: Text(AppLocalizations.of(context)!.actionCopyLink),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: primaryColor.withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Share Section
                  Text(
                    AppLocalizations.of(context)!.labelQuickShareVia,
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickShareSortscut(textTheme, AppLocalizations.of(context)!.shareWhatsApp, Icons.chat, const Color(0xFF25D366)),
                      _buildQuickShareSortscut(textTheme, AppLocalizations.of(context)!.shareIMessage, Icons.chat_bubble, const Color(0xFF121811)),
                      _buildQuickShareSortscut(textTheme, AppLocalizations.of(context)!.shareFacebook, Icons.facebook, const Color(0xFF1877F2)),
                      _buildQuickShareSortscut(textTheme, AppLocalizations.of(context)!.shareMore, Icons.more_horiz, primaryColor.withValues(alpha: 0.2), iconColor: primaryColor),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Add Existing Members Section
                  Text(
                    AppLocalizations.of(context)!.labelAddExistingMembers,
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.hintSearchMembers,
                        hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.4)),
                        prefixIcon: Icon(Icons.search, color: primaryColor.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Suggested Players List
                  Text(
                    AppLocalizations.of(context)!.labelSuggestedPlayers,
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else if (_filteredUsers.isEmpty)
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(AppLocalizations.of(context)!.msgNoUsersFound, style: textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                    )
                  else
                    ..._filteredUsers.map((user) => _buildPlayerItem(textTheme, user)),


                  const SizedBox(height: 32),

                  // Invite via Email Section
                  Text(
                    AppLocalizations.of(context)!.labelInviteViaEmail,
                    style: textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Updated to match white bg for input
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.hintEnterEmailAddress,
                         hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.4)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                   SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendEmailInvite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withValues(alpha: 0.2),
                        foregroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(AppLocalizations.of(context)!.actionSendInvitation, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pending Invites Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.labelPendingInvites(_mockPendingInvites.length),
                        style: textTheme.labelSmall?.copyWith(
                          color: textColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ..._mockPendingInvites.map((invite) => _buildPendingInviteItem(textTheme, invite)),
                  
                  const SizedBox(height: 40),
                ],
              ),
             ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickShareSortscut(TextTheme textTheme, String label, IconData icon, Color bgColor, {Color iconColor = Colors.white}) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerItem(TextTheme textTheme, UserProfile user) {
    // Mock data for NTRP and distance since UserProfile doesn't have it all
    final ntrp = user.ntrpRating ?? '3.5';
    final distance = '2 miles away'; 
    final isAdding = _pendingAdditions.contains(user.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: user.avatarUrl != null
                    ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(user.avatarUrl!))
                    : Icon(Icons.person, color: primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      style: textTheme.bodySmall?.copyWith(
                        color: textColor.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'NTRP $ntrp • $distance',
                    style: textTheme.labelSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isAdding
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _addMember(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(AppLocalizations.of(context)!.actionAdd, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPendingInviteItem(TextTheme textTheme, Map<String, String> invite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invite['email']!,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    invite['time']!,
                    style: textTheme.labelSmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.msgResentInvite(invite['email']!))),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(AppLocalizations.of(context)!.actionResend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
