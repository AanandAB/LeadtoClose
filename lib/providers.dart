
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/business_profile.dart';
import 'models/lead.dart';
import 'models/project_profile.dart';
import 'models/compliance_item.dart';
import 'models/quote.dart';
import 'services/storage_service.dart';
import 'services/rules_engine.dart';
import 'services/quote_service.dart';
import 'services/pdf_service.dart';

// Storage
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized before use');
});

// Business Profile
final businessProfileProvider = StateNotifierProvider<BusinessProfileNotifier, BusinessProfile?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BusinessProfileNotifier(storage);
});

class BusinessProfileNotifier extends StateNotifier<BusinessProfile?> {
  final StorageService _storage;
  BusinessProfileNotifier(this._storage) : super(_storage.getProfile());

  Future<void> save(BusinessProfile profile) async {
    await _storage.saveProfile(profile);
    state = profile;
  }
}

// Leads
final leadsProvider = StateNotifierProvider<LeadsNotifier, List<Lead>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LeadsNotifier(storage);
});

class LeadsNotifier extends StateNotifier<List<Lead>> {
  final StorageService _storage;
  LeadsNotifier(this._storage) : super(_storage.getAllLeads());

  void refresh() {
    state = _storage.getAllLeads();
  }

  Future<void> addLead(Lead lead) async {
    await _storage.saveLead(lead);
    refresh();
  }

  Future<void> updateLead(Lead lead) async {
    await _storage.saveLead(lead);
    refresh();
  }

  Future<void> deleteLead(String id) async {
    await _storage.deleteLead(id);
    refresh();
  }

  List<Lead> getLeadsByStage(String stage) {
    return state.where((l) => l.stage == stage).toList();
  }
}

// Project Profile for current lead
final currentProjectProfileProvider = StateProvider<ProjectProfile?>((ref) => null);

// Compliance Checklist
final complianceChecklistProvider = StateProvider<List<ComplianceItem>>((ref) {
  final profile = ref.watch(currentProjectProfileProvider);
  if (profile == null) return [];
  return RulesEngine.evaluate(profile);
});

// Quotes
final quotesProvider = StateNotifierProvider.family<QuotesNotifier, List<Quote>, String>((ref, leadId) {
  final storage = ref.watch(storageServiceProvider);
  return QuotesNotifier(storage, leadId);
});

class QuotesNotifier extends StateNotifier<List<Quote>> {
  final StorageService _storage;
  final String leadId;
  QuotesNotifier(this._storage, this.leadId) : super([]) {
    state = _storage.getQuotesForLead(leadId);
  }

  void refresh() {
    state = _storage.getQuotesForLead(leadId);
  }

  Future<void> saveQuote(Quote quote) async {
    await _storage.saveQuote(quote);
    refresh();
  }
}

// PDF Service
final pdfServiceProvider = Provider<PdfService>((ref) => PdfService());

// Quote Service
final quoteServiceProvider = Provider<QuoteService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return QuoteService(storage);
});

// Current Lead (for detail screens)
final currentLeadProvider = StateProvider<Lead?>((ref) => null);
