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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _currency = 'INR';
  String _paymentTerms = 'Net 30';

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgDeep, Color(0xFF0D0D1A)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),                     child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/freelancehub_logo.png', width: 32, height: 32, fit: BoxFit.cover),
                      ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to FreelanceHub',
                    style: AppTypography.displayLarge(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s set up your workspace in under a minute.',
                    style: AppTypography.body(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Step indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => Container(
                      width: i <= _step ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.primary : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 40),

                  // Step content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStep(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  Widget _buildStep1() {
    return Column(
      key: const ValueKey(1),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.business_center, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Tell us about your business so we can personalize your experience.', style: AppTypography.body(context))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _businessNameCtrl,
          onChanged: (_) => setState(() {}),
          style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Business Name *',
            prefixIcon: const Icon(Icons.business_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _ownerNameCtrl,
          onChanged: (_) => setState(() {}),
          style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Your Name *',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          onChanged: (_) => setState(() {}),
          style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _businessNameCtrl.text.trim().isEmpty && _ownerNameCtrl.text.trim().isEmpty
                ? null
                : () => setState(() => _step = 1),
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey(2),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: AppColors.success, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('Set your default currency and payment terms.', style: AppTypography.body(context))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _currency,
          decoration: InputDecoration(
            labelText: 'Currency',
            prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          dropdownColor: AppColors.bgCard,
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
            DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
            DropdownMenuItem(value: 'CAD', child: Text('CAD (\$)')),
          ],
          onChanged: (v) => setState(() => _currency = v!),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _paymentTerms,
          decoration: InputDecoration(
            labelText: 'Default Payment Terms',
            prefixIcon: const Icon(Icons.schedule, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          dropdownColor: AppColors.bgCard,
          items: const [
            DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
            DropdownMenuItem(value: 'Net 15', child: Text('Net 15')),
            DropdownMenuItem(value: 'Net 30', child: Text('Net 30')),
            DropdownMenuItem(value: 'Net 45', child: Text('Net 45')),
            DropdownMenuItem(value: 'Net 60', child: Text('Net 60')),
          ],
          onChanged: (v) => setState(() => _paymentTerms = v!),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 0),
                  child: const Text('Back'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      key: const ValueKey(3),
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 24),
        Text('You\'re all set!', style: AppTypography.displayMedium(context), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Your workspace is ready. Start by adding your first client or creating a project.',
          style: AppTypography.body(context),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: _completeOnboarding,
            child: const Text('Get Started'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _completeOnboarding(skip: true),
          child: Text('Skip for now', style: AppTypography.body(context)),
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
