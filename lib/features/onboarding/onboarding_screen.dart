import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/app_settings.dart';
import '../../providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _currency = 'INR';
  String _paymentTerms = 'Net 30';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _fadeController.reset();
    _slideController.reset();
    setState(() => _step++);
    _fadeController.forward();
    _slideController.forward();
  }

  void _prevStep() {
    _fadeController.reset();
    _slideController.reset();
    setState(() => _step--);
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Scaffold(
      body: Container(
        color: AppColors.bgDeep,
        child: isCompact ? _buildCompactLayout() : _buildSplitLayout(),
      ),
    );
  }

  /// ─── Split layout for wide screens ───
  Widget _buildSplitLayout() {
    return Row(
      children: [
        // Left branding panel
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.95),
                  const Color(0xFF3B2FC9),
                  const Color(0xFF2A1FA0),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -80,
                  right: -80,
                  width: 300,
                  height: 300,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -60,
                  width: 400,
                  height: 400,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.04),
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  right: 100,
                  width: 150,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/freelancehub_logo.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                    Text(
                      'FreelanceHub',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Manage · Connect · Grow',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 2,
                      ),
                    ),
                        const SizedBox(height: 48),
                        // Feature highlights
                        _featureRow(Icons.speed_rounded, 'Streamline your workflow'),
                        const SizedBox(height: 16),
                        _featureRow(Icons.receipt_long_rounded, 'Professional invoices & proposals'),
                        const SizedBox(height: 16),
                        _featureRow(Icons.analytics_rounded, 'Real-time business insights'),
                        const SizedBox(height: 16),
                        _featureRow(Icons.devices_rounded, 'Works on all your devices'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right form panel
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.bgDeep,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _buildFormContent(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ─── Compact layout for narrow screens ───
  Widget _buildCompactLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.bgDeep,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & branding
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/freelancehub_logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'FreelanceHub',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage · Connect · Grow',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                _buildFormContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ─── Shared form content ───
  Widget _buildFormContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header
            Text(
              _stepTitle(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _stepSubtitle(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Step indicator
            Row(
              children: List.generate(3, (i) {
                final active = i <= _step;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 4,
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Step body
            _buildStep(),

            const SizedBox(height: 32),

            // Footer
            Center(              child: Text(
                    'By continuing, you agree to our Terms of Service',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.6)),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Set up your business';
      case 1:
        return 'Configure payments';
      case 2:
        return 'All done!';
      default:
        return '';
    }
  }

  String _stepSubtitle() {
    switch (_step) {
      case 0:
        return 'Tell us about yourself so we can personalize your workspace.';
      case 1:
        return 'Choose your default currency and payment preferences.';
      case 2:
        return 'Your workspace is ready. Let\'s get started!';
      default:
        return '';
    }
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  /// ─── Step 1: Business info ───
  Widget _buildStep1() {
    return Column(
      key: const ValueKey(1),
      children: [
        _buildInput(
          controller: _businessNameCtrl,
          label: 'Business Name',
          hint: 'e.g. Acme Studios',
          icon: Icons.business_outlined,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        _buildInput(
          controller: _ownerNameCtrl,
          label: 'Your Name',
          hint: 'e.g. John Smith',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        _buildInput(
          controller: _emailCtrl,
          label: 'Email Address',
          hint: 'you@company.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        _buildPrimaryButton(
          label: 'Continue',
          onPressed: (_businessNameCtrl.text.trim().isNotEmpty && _ownerNameCtrl.text.trim().isNotEmpty)
              ? _nextStep
              : null,
        ),
      ],
    );
  }

  /// ─── Step 2: Currency & payment ───
  Widget _buildStep2() {
    return Column(
      key: const ValueKey(2),
      children: [
        _buildDropdown(
          value: _currency,
          label: 'Currency',
          icon: Icons.monetization_on_outlined,
          items: const [
            ('INR', 'INR (₹)'),
            ('USD', 'USD (\$)'),
            ('EUR', 'EUR (€)'),
            ('GBP', 'GBP (£)'),
            ('AED', 'AED (د.إ)'),
            ('SAR', 'SAR (﷼)'),
            ('CAD', 'CAD (\$)'),
            ('AUD', 'AUD (\$)'),
            ('JPY', 'JPY (¥)'),
          ],
          onChanged: (v) => setState(() => _currency = v!),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          value: _paymentTerms,
          label: 'Default Payment Terms',
          icon: Icons.schedule_outlined,
          items: const [
            ('Due on Receipt', 'Due on Receipt'),
            ('Net 15', 'Net 15'),
            ('Net 30', 'Net 30'),
            ('Net 45', 'Net 45'),
            ('Net 60', 'Net 60'),
          ],
          onChanged: (v) => setState(() => _paymentTerms = v!),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryButton(label: 'Back', onPressed: _prevStep),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPrimaryButton(label: 'Continue', onPressed: _nextStep),
            ),
          ],
        ),
      ],
    );
  }

  /// ─── Step 3: Done ───
  Widget _buildStep3() {
    return Column(
      key: const ValueKey(3),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withOpacity(0.2), width: 2),
            ),
            child: Icon(Icons.check_rounded, color: AppColors.success, size: 44),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome aboard!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your workspace is ready.\nStart by adding your first client or creating a project.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPrimaryButton(
          label: 'Get Started',
          onPressed: _completeOnboarding,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _completeOnboarding(skip: true),
          child: Text(
            'Skip for now',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }

  // ─── Reusable widgets ───

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool autofocus = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<(String, String)> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted, size: 20),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
      ),
      dropdownColor: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      items: items.map((item) => DropdownMenuItem(
        value: item.$1,
        child: Text(item.$2, style: const TextStyle(fontSize: 14)),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
          disabledForegroundColor: Colors.white.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _completeOnboarding({bool skip = false}) {
    final settings = AppSettings(
      businessName: skip ? '' : _businessNameCtrl.text.trim(),
      ownerName: skip ? '' : _ownerNameCtrl.text.trim(),
      email: skip ? '' : _emailCtrl.text.trim(),
      currency: _currency,
      defaultPaymentTerms: _paymentTerms,
    );
    ref.read(settingsProvider.notifier).save(settings);
    context.go('/');
  }
}
