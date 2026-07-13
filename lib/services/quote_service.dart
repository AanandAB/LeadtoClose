
import 'package:uuid/uuid.dart';
import '../models/project_profile.dart';
import '../models/compliance_item.dart';
import '../models/quote.dart';
import 'rules_engine.dart';
import 'storage_service.dart';

class QuoteService {
  final StorageService _storage;
  QuoteService(this._storage);

  Quote generateQuote({
    required String leadId,
    required ProjectProfile profile,
    required List<ComplianceItem> complianceItems,
    required bool isGstRegistered,
  }) {
    final rateCard = RulesEngine.getDefaultRateCard(profile.projectTier);
    final lineItems = <QuoteLineItem>[];

    // Base build
    lineItems.add(QuoteLineItem(
      description: '${profile.projectType} — ${profile.projectTier}',
      amount: rateCard['Base Build'] ?? 45000,
      category: 'Build',
    ));

    // Add compliance line items from compliance checklist
    for (final item in complianceItems) {
      if (item.category == ComplianceCategory.build) {
        double price = 0;
        if (item.title.contains('DPDPA')) price = rateCard['DPDPA consent/privacy flow'] ?? 8000;
        else if (item.title.contains('GDPR')) price = 5000;
        else if (item.title.contains('CCPA')) price = 4000;
        else if (item.title.contains('E-Commerce Consumer')) price = rateCard['E-commerce compliance module'] ?? 12000;
        else if (item.title.contains('Legal Metrology')) price = rateCard['Legal Metrology fields'] ?? 5000;
        else if (item.title.contains('CERT-In Incident')) price = rateCard['CERT-In logging + escalation setup'] ?? 10000;
        else if (item.title.contains('Children Data')) price = 6000;
        else if (item.title.contains('CERT-In Logging')) price = 0; // bundled with above

        if (price > 0) {
          lineItems.add(QuoteLineItem(description: item.title, amount: price, category: 'Compliance'));
        }
      }
    }

    // IP assignment premium
    if (profile.wantsFullOwnership) {
      final premium = rateCard['Full IP Assignment premium'] ?? 18000;
      lineItems.add(QuoteLineItem(
        description: 'Full IP Assignment Premium',
        amount: premium, category: 'IP',
      ));
    }

    final subtotal = lineItems.fold(0.0, (sum, item) => sum + item.amount);
    final gstAmount = RulesEngine.calculateGst(profile, isGstRegistered, subtotal);
    final gstTreatment = RulesEngine.getGstTreatment(profile, isGstRegistered);
    final sacCode = RulesEngine.getSacCode(profile.projectType);

    return Quote(
      id: const Uuid().v4(),
      leadId: leadId,
      version: 1,
      lineItems: lineItems,
      subtotal: subtotal,
      gstAmount: gstAmount,
      total: subtotal + gstAmount,
      gstTreatment: gstTreatment,
      status: 'Draft',
      createdAt: DateTime.now(),
      sacCode: sacCode,
    );
  }

  Quote createRevision(Quote previous) {
    final newVersion = previous.version + 1;
    return previous.copyWith(version: newVersion, status: 'Draft');
  }

  Future<void> saveQuote(Quote quote) async {
    await _storage.saveQuote(quote);
  }

  List<Quote> getQuotesForLead(String leadId) {
    return _storage.getQuotesForLead(leadId);
  }
}
