import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/models/session_creation_data.dart';
import 'package:intl/intl.dart';
import 'package:ace_manager/screens/league/create_session_step2_page.dart';

class CreateSessionPage extends StatefulWidget {
  final String leagueId;
  const CreateSessionPage({super.key, required this.leagueId});

  @override
  State<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends State<CreateSessionPage> {
  static const primaryColor = Color(0xFF5BEE2B);
  static const backgroundLight = Color(0xFFF6F8F6);

  final _sessionNameController = TextEditingController();
  final _clubSearchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Mock Club Data
  final List<Map<String, dynamic>> _allClubs = [
    {
      'name': 'Greenwood Tennis Center',
      'location': '12 Courts • Main Campus',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCsrOjx5ve6DNlUA5t56S3P4wuNUOF0eNyir1x7Tws7gIpTdbK_CqSSaYpxwv6ySt8SZSeQHhOk5CowSIdEqVmK9ufJD2-ch5nLnnG6nZ8DNkFTvNlGF4P-F99frZnv7rousRHX_kUIxk92BWvwYXbgQiwsvKE-DoJrwkagU8qdYgSdtxlZ_rV-5s7S9zuPneW_f-3COWvZITHB-f_VxoN20d3M0Iy3aldSeD9h18i8Yf-ajlupDHuas-A-3sFJR8cDpQyeNGEllQ',
    },
    {
      'name': 'Oakridge Sports Club',
      'location': '8 Courts • West Side',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAofcuK45zYp4WWS8HhJRKjy39OkWEIwNJwy766Db23Oh90v6Mzci265965Y3ltY7E5TkhVOps3YOD5RsFGeTueQFv-WV8U8HerPKT_asoKYwBWPPYIN4mQpdF9-PSPC4PWso-k-d07unGHIlIa8fryOci5eWB5KIIt7p7KTU3Vlxa78Zyf00fD44-tkavN_r25u-fK9422FXIsNL8175ho0xl6X6OAOpmSXAW3ZbYHcgyvKcBE6R9D9BR8DVJeWnK3v002J73fag',
    },
  ];

  Map<String, dynamic>? _selectedClub;
  bool _isClubDropdownOpen = false;

  @override
  void dispose() {
    _sessionNameController.dispose();
    _clubSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF39C91D), // Darker green for readability in picker
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lexend font requested
    final textTheme = GoogleFonts.lexendTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5BEE2B), size: 20),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120), // Padding for sticky footer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'STEP 1 OF 4',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '25% Complete',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor, // Use the neon green
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
                    widthFactor: 0.25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Section Header
                Text(
                  'Basic Information',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set up the core details for your upcoming tennis league session.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Session Name
                _buildLabel('Session Name', textTheme),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _sessionNameController,
                  hintText: 'e.g. Winter Doubles 2024',
                ),
                const SizedBox(height: 24),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date', textTheme),
                          const SizedBox(height: 8),
                          _buildDatePicker(
                            context,
                            _startDate,
                            () => _selectDate(context, true),
                            textTheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Date', textTheme),
                          const SizedBox(height: 8),
                          _buildDatePicker(
                            context,
                            _endDate,
                            () => _selectDate(context, false),
                            textTheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Club Selector
                 _buildLabel('Tennis Club', textTheme),
                 const SizedBox(height: 8),
                 _buildClubSelector(textTheme),

                  // Mock Search Results (Visible if we were implementing real search logic, 
                  // but for now statically shown or toggled)
                  if (_isClubDropdownOpen || _selectedClub != null) ...[
                     const SizedBox(height: 8),
                     Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                             ..._allClubs.map((club) => _buildClubItem(club, textTheme)),
                             Divider(height: 1, color: primaryColor.withValues(alpha: 0.1)),
                             Padding(
                               padding: const EdgeInsets.all(12.0),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   const Icon(Icons.add, color: Color(0xFF39C91D), size: 16), // Use slightly darker green for text/icon visibility
                                   const SizedBox(width: 4),
                                   Text(
                                     'Add New Club',
                                     style: textTheme.labelLarge?.copyWith(
                                       color: const Color(0xFF39C91D),
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                     ),
                  ],

              ],
            ),
          ),
          
          // Sticky Footer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                border: Border(top: BorderSide(color: primaryColor.withValues(alpha: 0.1))),
              ),
              child: SafeArea(
                top: false,
                  child: ElevatedButton(
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Step 2',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    // Basic Validation
    if (_sessionNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a session name')),
      );
      return;
    }
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final sessionData = SessionCreationData(
      leagueId: widget.leagueId,
      name: _sessionNameController.text,
      startDate: _startDate,
      endDate: _endDate,
      location: _selectedClub?['name'],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateSessionStep2Page(sessionData: sessionData),
      ),
    );
  }

  Widget _buildLabel(String text, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.1), width: 2),
        ),
         enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.1), width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context, 
    DateTime? date, 
    VoidCallback onTap,
    TextTheme textTheme,
  ) {
    final dateFormat = DateFormat('MM/dd/yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
         decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.1), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? dateFormat.format(date) : 'mm/dd/yyyy',
              style: textTheme.bodyMedium?.copyWith(
                color: date != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildClubSelector(TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isClubDropdownOpen = !_isClubDropdownOpen;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.1), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedClub != null ? _selectedClub!['name'] : 'Search and select club...',
                style: textTheme.bodyMedium?.copyWith(
                  color: _selectedClub != null ? Colors.black : Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.expand_more, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildClubItem(Map<String, dynamic> club, TextTheme textTheme) {
    bool isSelected = _selectedClub == club;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedClub = club;
          _isClubDropdownOpen = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
           color: isSelected ? primaryColor.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(club['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club['name'],
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    club['location'],
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF39C91D)), // Darker green check
          ],
        ),
      ),
    );
  }
}
