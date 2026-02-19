import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/club.dart';
import 'package:ace_manager/services/club_service.dart';
import 'package:ace_manager/screens/admin/club_details_page.dart';

class ClubManagementPage extends StatefulWidget {
  const ClubManagementPage({super.key});

  @override
  State<ClubManagementPage> createState() => _ClubManagementPageState();
}

class _ClubManagementPageState extends State<ClubManagementPage> {
  // Theme Colors from HTML design
  static const primaryColor = Color(0xFF3CDD57);
  static const backgroundLight = Color(0xFFF7F7F7);
  static const charcoal = Color(0xFF222222);
  static const mutedGray = Color(0xFF65866A);

  String _searchQuery = '';
  List<Club> _allClubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    setState(() => _isLoading = true);
    await _refreshClubs();
  }

  Future<void> _refreshClubs() async {
    final clubs = await ClubService.instance.getAllClubs();
    if (mounted) {
      setState(() {
        _allClubs = clubs;
        _isLoading = false;
      });
    }
  }

  List<Club> get _filteredClubs {
    if (_searchQuery.isEmpty) return _allClubs;
    return _allClubs.where((club) {
      return club.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          club.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Use Lexend font as per design
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          'Club Management',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: charcoal,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: charcoal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: charcoal),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[100],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name or location',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: mutedGray.withValues(alpha: 0.6),
                  ),
                  prefixIcon: const Icon(Icons.search, color: mutedGray),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Clubs Directory Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
            child: Row(
              children: [
                Text(
                  'REGISTERED CLUBS (${_filteredClubs.length})',
                  style: textTheme.labelSmall?.copyWith(
                    color: mutedGray,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Club Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _filteredClubs.isEmpty
                    ? Center(
                        child: Text(
                          'No clubs found',
                          style: textTheme.bodyLarge?.copyWith(color: mutedGray),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshClubs,
                        color: primaryColor,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: _filteredClubs.length,
                          itemBuilder: (context, index) {
                            final club = _filteredClubs[index];
                            return _buildClubCard(context, textTheme, club);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            _showAddClubDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            shadowColor: primaryColor.withValues(alpha: 0.3),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: Text(
            'Add New Club',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _showAddClubDialog() async {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final courtCountController = TextEditingController(text: '0');
    final imageUrlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Club'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Club Name *'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
              ),
              TextField(
                controller: courtCountController,
                decoration: const InputDecoration(labelText: 'Initial Court Count'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                 final courtCount = int.tryParse(courtCountController.text) ?? 0;
                 await ClubService.instance.createClub(
                   nameController.text,
                   locationController.text,
                   courtCount,
                   imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                 );
                 if (context.mounted) Navigator.pop(context);
                 _loadClubs();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(BuildContext context, TextTheme textTheme, Club club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Club Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[50]!),
              image: club.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(club.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: club.imageUrl == null
                ? const Icon(Icons.sports_tennis, color: mutedGray, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          // Club Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            club.name,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: charcoal,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            club.location,
                            style: textTheme.bodySmall?.copyWith(
                              color: mutedGray,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_tennis, size: 14, color: primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${club.courtCount} COURTS',
                            style: textTheme.labelSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ClubDetailsPage(club: club)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: charcoal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[100]!),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 14),
                      label: Text(
                        'Edit',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        // Confirm Delete
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Club?'),
                            content: Text('Are you sure you want to delete ${club.name}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          await ClubService.instance.deleteClub(club.id);
                          _loadClubs(); // Refresh list
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
