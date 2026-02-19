import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/club.dart';
import 'package:ace_manager/models/court.dart';
import 'package:ace_manager/services/club_service.dart';
import 'package:ace_manager/l10n/app_localizations.dart';

class ClubDetailsPage extends StatefulWidget {
  final Club club;

  const ClubDetailsPage({super.key, required this.club});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  // Theme Colors from HTML design
  static const primaryColor = Color(0xFF00DB6E);
  static const backgroundLight = Color(0xFFF7F7F7);

  static const textMainLight = Color(0xFF222222);
  static const textSubLight = Color(0xFF65866A);

  List<Court> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    setState(() => _isLoading = true);
    await _refreshCourts();
  }

  Future<void> _refreshCourts() async {
    final courts = await ClubService.instance.getClubCourts(widget.club.id);
    if (mounted) {
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    }
  }

  Future<void> _addCourt() async {
    final nameController = TextEditingController();
    final surfaceController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.actionAddNewCourt),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hintCourtName),
            ),
            TextField(
              controller: surfaceController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hintSurfaceType),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && surfaceController.text.isNotEmpty) {
                 await ClubService.instance.addCourt(
                   widget.club.id, 
                   nameController.text, 
                   surfaceController.text
                 );
                 if (context.mounted) Navigator.pop(context);
                 _loadCourts();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.actionAdd),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditClubDialog() async {
    final nameController = TextEditingController(text: widget.club.name);
    final locationController = TextEditingController(text: widget.club.location);
    final courtCountController = TextEditingController(text: widget.club.courtCount.toString());
    final imageUrlController = TextEditingController(text: widget.club.imageUrl);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.actionEditClubDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelClubNameRequired),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelLocationRequired),
              ),
              TextField(
                controller: courtCountController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelCourtCount),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.labelImageUrl),
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
                 final courtCount = int.tryParse(courtCountController.text) ?? widget.club.courtCount;
                 final updatedClub = await ClubService.instance.updateClub(
                   widget.club.id,
                   nameController.text,
                   locationController.text,
                   courtCount,
                   imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                 );
                 
                 if (context.mounted) {
                    Navigator.pop(context);
                    if (updatedClub != null) {
                      // Using Navigator replacement might be better, or setState if we can update the parent widget.
                      // Since widget.club is final, we should probably pop back with result or handle state better.
                      // For now, let's just show a success message and maybe pop.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.msgClubUpdatedSuccess)));
                      Navigator.pop(context); // Go back to list to refresh
                    }
                 }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.actionSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.titleClubDetails,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: textMainLight,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textMainLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: textMainLight),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Content
          RefreshIndicator(
            onRefresh: _refreshCourts,
            color: primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Header Profile Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      
                      // Club Logo & Name
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))],
                              image: widget.club.imageUrl != null
                                  ? DecorationImage(image: NetworkImage(widget.club.imageUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: widget.club.imageUrl == null
                                ? const Icon(Icons.sports_tennis, size: 48, color: textSubLight)
                                : null,
                          ),
                          Positioned(
                            bottom: -8,
                            right: -8,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: backgroundLight, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: const Icon(Icons.verified, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.club.name,
                        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: textMainLight),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.security, size: 16, color: textSubLight),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!.labelPrimaryAdminView,
                            style: textTheme.bodyMedium?.copyWith(color: textSubLight, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Location Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sectionLocation,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: textSubLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1), // Corrected withValues to withOpacity
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.map, color: primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppLocalizations.of(context)!.labelFullAddress, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.club.location,
                                    style: textTheme.bodyMedium?.copyWith(color: textSubLight, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {}, 
                              icon: const Icon(Icons.open_in_new, color: primaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Map Placeholder
                      Container(
                        height: 128,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD9kNf7FM9jgTr9p-MjScPIoxBQGTLE-gTPAT374xNDH5H_h-cEgpFqSQFjQoPBxsa9H55Sj7DdCLubACYv65gQKwlPi1BqEvCOzifU8zPNo6iJYZ8ctNWaD6eBbdqXNr6WFBSOkujkW67CJ5YieqhkpyXNr6WFBSOkujkW67CJ5YieqhkpyXcpStbdzG3AgOVEknOtjh3aFmwMEy_hWG1c4wlrQfL0unGznusEXkj8Lnzp54ptcLT0s8TXFyxRB7FSWxvvNuVaxg2-e_6bcnbXVF7MIcBvAtsfzZ_ow'),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                            ),
                            child: const Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Courts Inventory Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.sectionCourtsInventory,
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: textSubLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1), // Corrected withValues to withOpacity
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.labelCourtsTotal(_courts.length),
                              style: textTheme.labelSmall?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.0, // Square cards
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: _courts.length + 1, // +1 for Add button
                              itemBuilder: (context, index) {
                                if (index == _courts.length) {
                                  // Add New Court Button
                                  return InkWell(
                                    onTap: _addCourt,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid), // Dashed borders hard in Flutter natively without package, solid for now
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.transparent,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_circle_outline, size: 32, color: textSubLight),
                                          const SizedBox(height: 8),
                                          Text(
                                            AppLocalizations.of(context)!.actionAddNewCourt,
                                            style: textTheme.labelSmall?.copyWith(color: textSubLight, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                
                                final court = _courts[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                    border: Border.all(color: Colors.grey[100]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(alpha: 0.1), // Corrected withValues to withOpacity
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(Icons.sports_tennis, size: 20, color: primaryColor),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.grey),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        court.name,
                                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.layers, size: 14, color: textSubLight),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              court.surfaceType,
                                              style: textTheme.bodySmall?.copyWith(color: textSubLight),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Footer Action Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    backgroundLight,
                    backgroundLight.withValues(alpha: 0.95),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.7, 1],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                   _showEditClubDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.edit_note),
                label: Text(AppLocalizations.of(context)!.actionEditClubDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
