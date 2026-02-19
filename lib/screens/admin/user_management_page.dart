import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/user_profile.dart';
import 'package:ace_manager/services/league_service.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  static const primaryColor = Color(0xFF32D411);
  static const backgroundLight = Color(0xFFF6F8F6);

  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  List<UserProfile> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    await _refreshMembers();
  }

  Future<void> _refreshMembers() async {
    final members = await LeagueService.instance.getAllProfiles();
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // "lexend" is requested in HTML, mapping to GoogleFonts.lexend
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white, // backdrop-blur in HTML, solid white here for simplicity or use efficient blur
        elevation: 0,
         bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Members', 
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5,
              )
            ),
            Text(
              'Total Members: ${_members.length}', 
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                fontSize: 14,
              )
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: primaryColor,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: primaryColor.withValues(alpha: 0.2),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  // Todo: Add Member
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person_add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
             decoration: BoxDecoration(
              color: Colors.white, // Continuation of sticky header bg
              border: Border(bottom: BorderSide(color: primaryColor.withValues(alpha: 0.1))),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email...',
                    hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9), // slate-100
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                       borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                       const SizedBox(width: 8),
                      _buildFilterChip('Pending'),
                       const SizedBox(width: 8),
                      _buildFilterChip('Blocked'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : _members.isEmpty 
                  ? Center(child: Text('No members found', style: textTheme.bodyLarge?.copyWith(color: Colors.grey)))
                  : RefreshIndicator(
                        onRefresh: _refreshMembers,
                        color: primaryColor,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _members.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            // Simple client-side filtering
                            if (_selectedFilter != 'All' && 
                                member.status.toLowerCase() != _selectedFilter.toLowerCase()) {
                              return const SizedBox.shrink(); 
                            }
                            
                            // Search filtering
                            if (_searchController.text.isNotEmpty) {
                              final query = _searchController.text.toLowerCase();
                              if (!member.fullName.toLowerCase().contains(query) && 
                                  !member.email.toLowerCase().contains(query)) {
                                return const SizedBox.shrink();
                              }
                            }
    
                            return _buildMemberCard(member, textTheme);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : (label == 'Active' ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(999),
          border: label == 'Active' && !isSelected ? Border.all(color: primaryColor.withValues(alpha: 0.2)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (label == 'Active' ? primaryColor : Colors.grey[600]),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(UserProfile member, TextTheme textTheme) {
    bool isBlocked = member.status.toLowerCase() == 'blocked';
    bool isPending = member.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // dark:bg-white/5
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent), // hover:border-primary/20
        boxShadow: const [
             BoxShadow(
              color: Color(0x05000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
        ],
      ),
      child: Opacity(
        opacity: isBlocked ? 0.75 : 1.0,
        child: Row(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isBlocked ? Colors.redAccent.withValues(alpha: 0.3) : (isPending ? Colors.orangeAccent.withValues(alpha: 0.3) : primaryColor.withValues(alpha: 0.3)),
                      width: 2,
                    ),
                    image: member.avatarUrl != null 
                      ? DecorationImage(
                          image: NetworkImage(member.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                    color: member.avatarUrl == null ? Colors.grey[200] : null,
                  ),
                  child: member.avatarUrl == null 
                    ? Icon(Icons.person, color: Colors.grey[400])
                    : null,
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isBlocked ? Colors.red : (isPending ? Colors.orange : primaryColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isBlocked ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isBlocked 
                              ? Colors.red[50] 
                              : (isPending ? Colors.grey[100] : primaryColor.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.status.toLowerCase() == 'blocked' ? 'BLOCKED' : 'NTRP ${member.ntrpRating ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isBlocked
                                ? Colors.red
                                : (isPending ? Colors.grey[500] : primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          member.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: isPending ? Colors.orange : Colors.grey[400],
                            fontWeight: isPending ? FontWeight.w500 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {
                _showActionSheet(context, member);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, UserProfile member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(bottom: 24),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                  child: member.avatarUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage ${member.displayName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Role: ${member.role}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionItem(Icons.edit, 'Edit Profile', primaryColor),
            _buildActionItem(Icons.chat, 'Send Message', primaryColor),
            _buildActionItem(
              Icons.person_remove, 
              'Remove Member', 
              Colors.red, 
              isDestructive: true,
              onTap: () {
                Navigator.pop(context); // Close sheet
                _confirmDelete(context, member);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserProfile member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to permanently delete ${member.displayName}? This action cannot be undone and will remove them from all leagues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final messenger = ScaffoldMessenger.of(context);
              try {
                setState(() => _isLoading = true);
                await LeagueService.instance.deleteUser(member.id);
                // Refresh list
                await _fetchMembers();
                if (mounted) {
                   messenger.showSnackBar(
                    const SnackBar(content: Text('User deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, {bool isDestructive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: $label')));
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDestructive ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
