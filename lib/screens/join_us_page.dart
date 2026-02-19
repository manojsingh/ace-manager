
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ace_manager/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ace_manager/screens/login_page.dart';

class JoinUsPage extends StatefulWidget {
  const JoinUsPage({super.key});

  @override
  State<JoinUsPage> createState() => _JoinUsPageState();
}

class _JoinUsPageState extends State<JoinUsPage> {
  // Defined to maintain consistency with Landing Page
  static const primaryColor = Color(0xFF39C91D);
  static const backgroundLight = Color(0xFFF6F8F6);

  final _formKey = GlobalKey<FormState>();
  String? _skillLevel = 'Beginner';
  String? _preferredHand = 'Right-handed';
  
  // Controllers
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'email@example.com');
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(text: '+1 (555) 000-0000');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Join Us',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  AppLocalizations.of(context)!.joinUsTitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.joinUsSubtitle,
                  style: GoogleFonts.epilogue(
                    fontSize: 16,
                    color: const Color(0xFF688961), // Muted green from previous designs
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildLabel(AppLocalizations.of(context)!.labelFullName),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: AppLocalizations.of(context)!.hintFullName,
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context)!.labelEmail),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _emailController,
                  hintText: AppLocalizations.of(context)!.hintEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                _buildLabel(AppLocalizations.of(context)!.password),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: AppLocalizations.of(context)!.enterPassword,
                  obscureText: _obscurePassword,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return AppLocalizations.of(context)!.passwordError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context)!.labelPhone),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _phoneController,
                  hintText: AppLocalizations.of(context)!.hintPhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // Skill Level
                _buildLabel(AppLocalizations.of(context)!.labelSkillLevel),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSkillCard('Beginner', AppLocalizations.of(context)!.skillBeginner, AppLocalizations.of(context)!.skillBeginnerDesc)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSkillCard('Intermediate', AppLocalizations.of(context)!.skillIntermediate, AppLocalizations.of(context)!.skillIntermediateDesc)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSkillCard('Advanced', AppLocalizations.of(context)!.skillAdvanced, AppLocalizations.of(context)!.skillAdvancedDesc)),
                  ],
                ),
                const SizedBox(height: 24),

                // Preferred Hand
                _buildLabel(AppLocalizations.of(context)!.labelPreferredHand),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildHandOption('Right-handed', AppLocalizations.of(context)!.handRight),
                      ),
                      Expanded(
                        child: _buildHandOption('Left-handed', AppLocalizations.of(context)!.handLeft),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // TODO: Implement loading state
                        await Supabase.instance.client.auth.signUp(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          data: {
                            'full_name': _nameController.text,
                            'phone': _phoneController.text,
                            'skill_level': _skillLevel,
                            'preferred_hand': _preferredHand,
                          },
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(AppLocalizations.of(context)!.signUpSuccess)),
                          );
                        }
                      } on AuthException catch (error) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
                          );
                        }
                      } catch (error) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unexpected error occurred'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.epilogue(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.createAccountButton),
                ),

                const SizedBox(height: 24),

                // Disclaimer
                Text.rich(
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsText,
                    style: GoogleFonts.epilogue(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.termsLink,
                        style: GoogleFonts.epilogue(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: AppLocalizations.of(context)!.andText),
                      TextSpan(
                        text: AppLocalizations.of(context)!.privacyLink,
                        style: GoogleFonts.epilogue(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.alreadyHaveAccount,
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                         Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.logInLink,
                        style: GoogleFonts.epilogue(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.epilogue(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.epilogue(
        fontSize: 16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        hintStyle: GoogleFonts.epilogue(
          color: Colors.grey[400],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF39C91D), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSkillCard(String id, String label, String subtext) {
    bool isSelected = _skillLevel == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _skillLevel = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF39C91D).withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF39C91D) : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.epilogue(
                fontWeight: FontWeight.bold,
                fontSize: 12, // Adjusted for space
                color: isSelected ? const Color(0xFF39C91D) : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: GoogleFonts.epilogue(
                fontSize: 10,
                color: isSelected ? const Color(0xFF39C91D).withValues(alpha: 0.8) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandOption(String id, String label) {
    bool isSelected = _preferredHand == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _preferredHand = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.epilogue(
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF39C91D) : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
