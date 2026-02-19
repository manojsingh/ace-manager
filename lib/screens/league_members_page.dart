import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/league.dart';
import 'package:ace_manager/services/league_service.dart';
import 'package:ace_manager/screens/league/invite_member_page.dart';


class LeagueMembersPage extends StatefulWidget {
  final String leagueId;
  final String currentUserRole;
  final String leagueName;

  const LeagueMembersPage({
    super.key,
    required this.leagueId,
    required this.leagueName,
    required this.currentUserRole,
  });

  @override
  State<LeagueMembersPage> createState() => _LeagueMembersPageState();
}

class _LeagueMembersPageState extends State<LeagueMembersPage> {
  static const primaryColor = Color(0xFF00DB6E);
  List<LeagueMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    await _refreshMembers();
  }

  Future<void> _refreshMembers() async {
    try {
      final members = await LeagueService.instance.getLeagueMembers(widget.leagueId);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
      }
    }
  }

  bool get _canEdit => ['owner', 'admin'].contains(widget.currentUserRole);

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.leagueName} Members', style: textTheme.titleMedium),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text('No members found.'))
              : RefreshIndicator(
                  onRefresh: _refreshMembers,
                  color: primaryColor,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: _members.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return _buildMemberTile(context, textTheme, member);
                    },
                  ),
                ),
      floatingActionButton: _canEdit ? FloatingActionButton(
        onPressed: () async {
          // We need to pass the list of current member IDs to filter them out
          // We need to pass the list of current member IDs to filter them out
          // Optimization: Wait for the key future to complete
          
          if (!context.mounted) return;

          await Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => InviteMemberPage(
                leagueId: widget.leagueId,
                existingMemberIds: _members.map((m) => m.userId).toList(),
              ),
            ),
          );

          if (mounted) {
            setState(() {
              _loadMembers();
            });
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildMemberTile(BuildContext context, TextTheme textTheme, LeagueMember member) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: member.profile?.avatarUrl != null 
            ? NetworkImage(member.profile!.avatarUrl!) 
            : const AssetImage("assets/images/user_avatar.png") as ImageProvider,
        backgroundColor: Colors.grey[200],
      ),
      title: Text(
        member.profile?.fullName ?? 'Unknown User',
        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        member.profile?.email ?? '',
        style: textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: member.role == 'owner' ? Colors.purple[50] : (member.role == 'admin' ? Colors.blue[50] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: member.role == 'owner' ? Colors.purple[200]! : (member.role == 'admin' ? Colors.blue[200]! : Colors.grey[300]!),
              ),
            ),
            child: Text(
              member.role.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: member.role == 'owner' ? Colors.purple : (member.role == 'admin' ? Colors.blue : Colors.grey[600]),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          if (_canEdit) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
              onPressed: () => _showEditRoleDialog(member),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditRoleDialog(LeagueMember member) {
    // Only Owners can make others Owners/Admins
    // Admins can only make others Players or Admins (logic simplified for now)
    
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Change Role for ${member.profile?.firstName}'),
          children: [
            _buildRoleOption(member, 'owner', 'Owner'),
            _buildRoleOption(member, 'admin', 'Admin'),
            _buildRoleOption(member, 'player', 'Player'),
            _buildRoleOption(member, 'spectator', 'Spectator'),
          ],
        );
      },
    );
  }

  Widget _buildRoleOption(LeagueMember member, String roleKey, String label) {
    return SimpleDialogOption(
      onPressed: () async {
        Navigator.of(context).pop();
        if (member.role == roleKey) return;

        try {
          await LeagueService.instance.updateMemberRole(member.id, roleKey);
          setState(() {
            _loadMembers();
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Role updated to $label')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              member.role == roleKey ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: member.role == roleKey ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
