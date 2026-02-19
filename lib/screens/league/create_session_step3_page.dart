import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/session_creation_data.dart';
import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/screens/league/create_session_step4_page.dart';

class CreateSessionStep3Page extends StatefulWidget {
  final SessionCreationData sessionData;
  const CreateSessionStep3Page({super.key, required this.sessionData});

  @override
  State<CreateSessionStep3Page> createState() => _CreateSessionStep3PageState();
}

class _CreateSessionStep3PageState extends State<CreateSessionStep3Page> {
  static const primaryColor = Color(0xFF32D411);
  static const backgroundLight = Color(0xFFF6F8F6);

  List<LeagueMember> _members = [];
  bool _isLoading = true;
  final Set<String> _selectedMemberIds = {};

  final List<Map<String, dynamic>> _recommendedPlayers = [
    {'image': 'https://i.pravatar.cc/150?u=1'},
    {'image': 'https://i.pravatar.cc/150?u=2'},
    {'image': 'https://i.pravatar.cc/150?u=3'},
  ];

  Widget _buildAvatarStackItem(String? imageUrl) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null ? const Icon(Icons.person, size: 16, color: Colors.grey) : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final leagueId = widget.sessionData.leagueId;
     if (leagueId == null) {
      // Mock data if no league ID (e.g. testing)
      setState(() {
        _isLoading = false;
        // Keep existing mock logic or clear it? 
        // For now, let's just use empty or mock if testing
      });
      return;
    }

    try {
      final members = await LeagueService.instance.getLeagueMembers(leagueId);
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  void _toggleSelection(String memberId) {
    setState(() {
      if (_selectedMemberIds.contains(memberId)) {
        _selectedMemberIds.remove(memberId);
      } else {
        _selectedMemberIds.add(memberId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedMemberIds.length == _members.length) {
        _selectedMemberIds.clear();
      } else {
        _selectedMemberIds.addAll(_members.map((m) => m.userId));
      }
    });
  }

  int get _selectedCount => _selectedMemberIds.length;

  void _onNext() {
    widget.sessionData.selectedMemberIds = _selectedMemberIds.toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSessionStep4Page(sessionData: widget.sessionData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          Column(
            children: [
              // Sticky Header & Progress
              Container(
                color: Colors.white.withValues(alpha: 0.8),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                       Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                         child: Row(
                           children: [
                             IconButton(
                               icon: const Icon(Icons.arrow_back_ios, color: primaryColor, size: 20),
                               onPressed: () => Navigator.of(context).pop(),
                               padding: EdgeInsets.zero,
                               constraints: const BoxConstraints(),
                             ),
                             Expanded(
                               child: Column(
                                 children: [
                                   Text(
                                    'Add Members',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      letterSpacing: -0.5,
                                    ),
                                   ),
                                   Text(
                                    'STEP 3 OF 4',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.0,
                                      fontSize: 11,
                                    ),
                                   ),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 20), // Spacer
                           ],
                         ),
                       ),
                       // Progress Bar
                       Container(
                         height: 4,
                         width: double.infinity,
                         color: Colors.grey[100],
                         child: FractionallySizedBox(
                           alignment: Alignment.centerLeft,
                           widthFactor: 0.75,
                           child: Container(
                             decoration: const BoxDecoration(
                               color: primaryColor,
                               borderRadius: BorderRadius.only(
                                 topRight: Radius.circular(999),
                                 bottomRight: Radius.circular(999),
                               ),
                             ),
                           ),
                         ),
                       ),
                       // Search Bar
                       Padding(
                         padding: const EdgeInsets.all(20),
                         child: Container(
                           decoration: BoxDecoration(
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withValues(alpha: 0.05),
                                 blurRadius: 10,
                                 offset: const Offset(0, 4),
                               ),
                             ],
                           ),
                           child: TextField(
                             decoration: InputDecoration(
                               hintText: 'Search by name or email...',
                               hintStyle: TextStyle(color: Colors.grey[400]),
                               prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                               filled: true,
                               fillColor: Colors.white,
                               contentPadding: const EdgeInsets.symmetric(vertical: 16),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide.none,
                               ),
                               enabledBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: BorderSide.none,
                               ),
                               focusedBorder: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(12),
                                 borderSide: const BorderSide(color: primaryColor, width: 2),
                               ),
                             ),
                           ),
                         ),
                       ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 140), // Bottom padding for footer
                  children: [
                    // Member List Section
                    Text(
                      'ALL MEMBERS',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _selectAll,
                          child: Text(
                            'Select All',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_members.isEmpty)
                      const Center(child: Text("No members found in this league."))
                    else
                      ..._members.map((member) => _buildPlayerItem(member, textTheme)),

                  ],
                ),
              ),
            ],
          ),

          // Sticky Bottom Footer
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL SELECTION',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                                children: [
                                  TextSpan(text: '$_selectedCount '),
                                  TextSpan(
                                    text: 'Players',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Avatars Stack
                        SizedBox(
                          width: 100,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: _buildAvatarStackItem(_recommendedPlayers[0]['image']),
                              ),
                              Positioned(
                                left: 20,
                                child: _buildAvatarStackItem(_recommendedPlayers[1]['image']),
                              ),
                              Positioned(
                                left: 40,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+10',
                                      style: textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onNext,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next Step',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
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

  Widget _buildPlayerItem(LeagueMember member, TextTheme textTheme) {
    bool isSelected = _selectedMemberIds.contains(member.userId);
    String displayName = member.profile?.fullName ?? 'Unknown Member';
    String? imageUrl = member.profile?.avatarUrl;
    String initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : '?';

    return InkWell(
      onTap: () => _toggleSelection(member.userId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            if (imageUrl != null && imageUrl.isNotEmpty)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor.withValues(alpha: 0.1), width: 2),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
               Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Text(
                        member.role.toUpperCase(), // Display Role instead of Rank for now
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

