
import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';
import '../models/lead.dart';
import '../models/project_profile.dart';
import '../models/quote.dart';

class StorageService {
  static const String _profileKey = 'business_profile';
  static const String _leadsBox = 'leads';
  static const String _quotesBox = 'quotes';

  late Box _profileBox;
  late Box _leads;
  late Box _quotes;

  Future<void> init() async {
    await Hive.initFlutter();
    _profileBox = await Hive.openBox('profile');
    _leads = await Hive.openBox(_leadsBox);
    _quotes = await Hive.openBox(_quotesBox);
  }

  // Business Profile
  BusinessProfile? getProfile() {
    final data = _profileBox.get(_profileKey);
    if (data == null) return null;
    return BusinessProfile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    await _profileBox.put(_profileKey, profile.toJson());
  }

  bool get hasProfile => _profileBox.containsKey(_profileKey);

  // Leads
  List<Lead> getAllLeads() {
    return _leads.values.map((v) => Lead.fromJson(Map<String, dynamic>.from(v))).toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  Lead? getLead(String id) {
    final data = _leads.get(id);
    if (data == null) return null;
    return Lead.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> saveLead(Lead lead) async {
    await _leads.put(lead.id, lead.toJson());
  }

  Future<void> deleteLead(String id) async {
    await _leads.delete(id);
  }

  // Quotes
  List<Quote> getQuotesForLead(String leadId) {
    return _quotes.values
        .map((v) => Quote.fromJson(Map<String, dynamic>.from(v)))
        .where((q) => q.leadId == leadId)
        .toList()
      ..sort((a, b) => b.version.compareTo(a.version));
  }

  Future<void> saveQuote(Quote quote) async {
    await _quotes.put('${quote.leadId}_v${quote.version}', quote.toJson());
  }

  // Pipeline stages
  static const List<String> pipelineStages = [
    'New Lead', 'Qualified', 'Discovery Done',
    'Quote Sent', 'Negotiating', 'Won', 'Lost',
  ];
}
