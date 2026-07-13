
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../features/onboarding/business_profile_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/pipeline/lead_form_screen.dart';
import '../features/pipeline/lead_detail_screen.dart';
import '../features/discovery/questionnaire_screen.dart';
import '../features/compliance/checklist_screen.dart';
import '../features/quotes/quote_screen.dart';
import '../features/quotes/contract_screen.dart';
import '../features/quotes/ip_assessment_screen.dart';
import '../features/invoices/invoice_screen.dart';
import '../features/payments/payment_tracker_screen.dart';
import '../features/tax/tax_calendar_screen.dart';
import '../features/tax/turnover_tracker_screen.dart';
import '../features/rules/rules_viewer_screen.dart';
import '../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final profileNotifier = ref.watch(businessProfileProvider.notifier);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final profile = ref.read(businessProfileProvider);
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (profile == null || !profile.isComplete) {
        if (!isOnboarding) return '/onboarding';
        return null;
      }
      if (isOnboarding) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const BusinessProfileScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/lead/new',
        builder: (context, state) => const LeadFormScreen(),
      ),
      GoRoute(
        path: '/lead/:id',
        builder: (context, state) => LeadDetailScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lead/:id/discovery',
        builder: (context, state) => QuestionnaireScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lead/:id/compliance',
        builder: (context, state) => ChecklistScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lead/:id/quote',
        builder: (context, state) => QuoteScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lead/:id/contract',
        builder: (context, state) => ContractScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ip-assessment',
        builder: (context, state) => const IpAssessmentScreen(),
      ),
      GoRoute(
        path: '/lead/:id/invoice',
        builder: (context, state) => InvoiceScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lead/:id/payment',
        builder: (context, state) => PaymentTrackerScreen(leadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tax-calendar',
        builder: (context, state) => const TaxCalendarScreen(),
      ),
      GoRoute(
        path: '/turnover-tracker',
        builder: (context, state) => const TurnoverTrackerScreen(),
      ),
      GoRoute(
        path: '/rules-engine',
        builder: (context, state) => const RulesViewerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
