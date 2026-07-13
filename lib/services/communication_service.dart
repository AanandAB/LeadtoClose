
import '../models/business_profile.dart';
import '../models/lead.dart';
import '../models/project_profile.dart';
import '../models/quote.dart';
import '../models/invoice.dart';
import '../models/compliance_item.dart';

class MessageTemplate {
  final String stageLabel;
  final String emailSubject;
  final String emailBody;
  final String whatsappBody;

  const MessageTemplate({
    required this.stageLabel, required this.emailSubject,
    required this.emailBody, required this.whatsappBody,
  });
}

class CommunicationService {
  String _fmt(double amt) {
    if (amt >= 100000) return '\u{20B9}${(amt / 100000).toStringAsFixed(2)} Lakh';
    if (amt >= 1000) return '\u{20B9}${(amt / 1000).toStringAsFixed(1)}K';
    return '\u{20B9}${amt.toStringAsFixed(0)}';
  }

  List<MessageTemplate> generateAll({
    required Lead lead, required BusinessProfile profile,
    ProjectProfile? projectProfile, Quote? quote, Invoice? invoice,
    List<ComplianceItem>? complianceItems,
  }) {
    final messages = <MessageTemplate>[];

    // 1. New Lead / Introduction
    messages.add(MessageTemplate(
      stageLabel: 'New Lead — Introduction',
      emailSubject: 'Re: ${lead.name} — Web Development Discussion',
      emailBody: '''Hi ${lead.name.split(' ').first},

Thank you for reaching out${lead.company.isNotEmpty ? ' from ${lead.company}' : ''}. I'd love to learn more about your project and how I can help.

Would you be available for a quick call this week to discuss your requirements? I'm free on [DAY] at [TIME] — or let me know what works for you.

In the meantime, feel free to share any details about what you're looking to build, your timeline, and budget expectations.

Looking forward to it!

Best regards,
${profile.ownerName}
${profile.businessName}
${profile.email} | ${profile.phone}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}! Thanks for reaching out${lead.company.isNotEmpty ? ' from ${lead.company}' : ''}. Would you be free for a quick call this week to discuss your project? Let me know what time works for you. — ${profile.ownerName}''',
    ));

    // 2. Qualified — Let's proceed
    messages.add(MessageTemplate(
      stageLabel: 'Qualified — Let\'s Discuss',
      emailSubject: 'Next Steps for Your Project — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

Great speaking with you! Based on our discussion, I'll put together a detailed discovery document to nail down the exact requirements.

Here's what happens next:
1. I'll send you a short questionnaire to clarify project specifics
2. Based on that, I'll prepare a compliance checklist and quote
3. Once we agree on scope and pricing, I'll draft the agreement

This usually takes 2-3 business days.

If you have any questions in the meantime, just reply here or WhatsApp me at ${profile.phone}.

Best,
${profile.ownerName}
${profile.businessName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, great chat! I'll send you a short questionnaire to lock in the requirements, then prepare a quote. Should have everything ready in 2-3 days. Talk soon!''',
    ));

    // 3. Discovery Done — Compliance Summary
    if (projectProfile != null && complianceItems != null) {
      final buildCount = complianceItems.where((c) => c.category == ComplianceCategory.build).length;
      final contractCount = complianceItems.where((c) => c.category == ComplianceCategory.contract).length;
      final advisoryCount = complianceItems.where((c) => c.category == ComplianceCategory.advisory).length;

      messages.add(MessageTemplate(
        stageLabel: 'Discovery Done — Compliance Summary',
        emailSubject: 'Project Analysis — ${projectProfile.projectType}',
        emailBody: '''Hi ${lead.name.split(' ').first},

I've completed the project analysis for your ${projectProfile.projectType}. Here's a summary:

Project Type: ${projectProfile.projectType}
Category: ${projectProfile.projectCategory}
Tier: ${projectProfile.projectTier}
Client Location: ${projectProfile.clientLocation}

Compliance Requirements Identified:
- $buildCount build items (features to implement)
- $contractCount contract clauses needed
- $advisoryCount advisory items (things to be aware of)

${projectProfile.collectsPersonalData ? 'Since the project collects user data, DPDPA compliance features (consent flow, privacy policy) are required.' : ''}
${projectProfile.requiresHosting ? 'Since hosting/maintenance is involved, CERT-In incident reporting and logging obligations apply.' : ''}
${projectProfile.isExport ? 'As this is an export project, zero-rated GST with LUT applies. I\'ll handle the invoicing accordingly.' : ''}

I'm now preparing the quote based on these requirements. You'll receive it shortly.

Best,
${profile.ownerName}''',
        whatsappBody: '''Hi ${lead.name.split(' ').first}, I've completed the project analysis for your ${projectProfile.projectType}. Found $buildCount compliance items to handle. Preparing the quote now — you'll have it shortly.''',
      ));
    }

    // 4. Quote Sent
    if (quote != null) {
      messages.add(MessageTemplate(
        stageLabel: 'Quote Sent',
        emailSubject: 'Quote for ${projectProfile?.projectType ?? "Your Project"} — ${profile.businessName}',
        emailBody: '''Hi ${lead.name.split(' ').first},

Please find attached the quote for your ${projectProfile?.projectType ?? 'project'}.

Summary:
${quote.lineItems.map((li) => '  - ${li.description}: ${_fmt(li.amount)}').join('\n')}

Total: ${_fmt(quote.total)} (${quote.gstTreatment})

The quote covers:
- All build items listed above
- Compliance features (DPDPA, CERT-In, etc. as applicable)
- ${projectProfile?.wantsFullOwnership == true ? 'Full IP assignment' : 'IP license for usage'}

This quote is valid for 30 days. Happy to hop on a call to walk through any items — just let me know.

Best,
${profile.ownerName}''',
        whatsappBody: '''Hi ${lead.name.split(' ').first}, just sent the quote for your ${projectProfile?.projectType ?? 'project'}. Total: ${_fmt(quote.total)}. Covers everything we discussed including compliance features. Let me know if you'd like to go through it on a call!''',
      ));
    }

    // 5. Negotiating — Follow-up
    messages.add(MessageTemplate(
      stageLabel: 'Negotiating — Follow-up',
      emailSubject: 'Quick Follow-up — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

Just checking in on the quote I sent. Happy to adjust any line items or discuss alternative approaches if the scope needs tweaking.

A few options we could explore:
- Phased delivery: split the project into milestones
- Reduced scope for MVP first, then add features later
- Adjusted payment schedule

Let me know what you're thinking — no pressure, just want to make sure we find the right fit.

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, just checking in on the quote. Happy to adjust scope or payment terms if needed — let me know your thoughts!''',
    ));

    // 6. Won — Congratulations + Next Steps
    messages.add(MessageTemplate(
      stageLabel: 'Won — Onboarding',
      emailSubject: 'Welcome Aboard! Next Steps — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

Fantastic — I'm excited to get started on your ${projectProfile?.projectType ?? 'project'}!

Here's what happens now:

1. SIGN: I'll send the service agreement for e-signature shortly
2. INVOICE: I'll send the advance payment invoice (${lead.name.split(' ').first == 'A' ? '' : 'per our agreed terms'})
3. KICKOFF: Once the advance is received, we'll schedule a kickoff call
4. ACCESS: I'll set up the project repo and share access

Expected timeline: we'll start within [X] days of receiving the signed agreement and advance payment.

If you have any questions at all, I'm just a message away.

Thanks for trusting me with this!

Best,
${profile.ownerName}
${profile.businessName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, thrilled to have you on board! 🎉 I'll send the agreement for signature and the advance invoice shortly. Once done, we kick off! Any questions, just WhatsApp me.''',
    ));

    // 7. Lost — Graceful exit
    messages.add(MessageTemplate(
      stageLabel: 'Lost — Thank You',
      emailSubject: 'Thank You — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

Thank you for considering me for your project. While we couldn't make it work this time, I appreciate the conversation and your time.

If anything changes down the road, or if you have a different project in the future, I'd be happy to chat again. No hard feelings at all — these things happen.

Wishing you the best with your project!

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, no worries at all — thanks for considering me! If anything changes or you have another project down the road, I'd be happy to chat. All the best!''',
    ));

    // 8. Contract Ready
    messages.add(MessageTemplate(
      stageLabel: 'Contract Ready for Review',
      emailSubject: 'Service Agreement Ready for Review — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

The service agreement is ready for your review. It covers:

- Scope of work as discussed
- Payment terms and schedule
- IP ownership (${projectProfile?.wantsFullOwnership == true ? 'full assignment on payment' : 'license for usage'})
- ${projectProfile?.requiresHosting == true ? 'Hosting, SLA, and CERT-In compliance terms' : 'Handover and warranty terms'}
- Standard confidentiality, termination, and dispute resolution clauses

Please review at your convenience. A couple of things to note:
- The agreement includes an electronic execution clause — email/WhatsApp approval counts
- I recommend having your lawyer review it, especially if this is a first-of-kind engagement
- Let me know if anything needs clarification

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, the service agreement is in your inbox. Covers scope, payment, IP (${projectProfile?.wantsFullOwnership == true ? 'full assignment' : 'license'}), and standard terms. Take your time reviewing — happy to clarify anything.''',
    ));

    // 9. Invoice Sent
    if (invoice != null) {
      final daysUntilDue = invoice.dueDate.difference(DateTime.now()).inDays;
      messages.add(MessageTemplate(
        stageLabel: 'Invoice Sent',
        emailSubject: 'Invoice ${invoice.number} — ${profile.businessName}',
        emailBody: '''Hi ${lead.name.split(' ').first},

Please find attached Invoice ${invoice.number} for the ${projectProfile?.projectType ?? 'project'}.

Amount: ${_fmt(invoice.total)}
GST: ${invoice.gstTreatment}
Due Date: ${invoice.dueDate.day}/${invoice.dueDate.month}/${invoice.dueDate.year} (${daysUntilDue} days)

${invoice.expectedTdsAmount > 0 ? 'Note: TDS of 10% (u/s 194J) is applicable — the expected net receipt after TDS is ${_fmt(invoice.total - invoice.expectedTdsAmount)}.' : ''}

Payment can be made via bank transfer to:
${profile.bankDetails}

Please let me know once the payment is processed.

Thank you!

Best,
${profile.ownerName}''',
        whatsappBody: '''Hi ${lead.name.split(' ').first}, Invoice ${invoice.number} sent — ${_fmt(invoice.total)} due by ${invoice.dueDate.day}/${invoice.dueDate.month}. Bank details in the email. Let me know once paid. Thanks!''',
      ));
    }

    // 10. Payment Overdue — Friendly
    messages.add(MessageTemplate(
      stageLabel: 'Payment Overdue — Friendly Reminder (Day 1+)',
      emailSubject: 'Gentle Reminder: Invoice Payment — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

Just a gentle reminder that the invoice for your ${projectProfile?.projectType ?? 'project'} is now past its due date. I understand these things can slip through — if it's already been processed, please ignore this message.

If there's anything preventing payment or if you need to discuss the timeline, please let me know — I'm happy to work something out.

Amount due: ${invoice != null ? _fmt(invoice.total) : '[amount]'}

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, just a gentle reminder about the invoice — it's a few days past due. No worries if already processed! Let me know if anything's up.''',
    ));

    // 11. Payment Overdue — Firm (Day 15+)
    messages.add(MessageTemplate(
      stageLabel: 'Payment Overdue — Firm Reminder (Day 15+)',
      emailSubject: 'Important: Outstanding Invoice — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

I'm writing about the outstanding invoice which is now 15+ days past due.

As per our agreement, late payments attract interest at ${profile.lateFeePercent}% per annum. The revised amount including late fees is now: ${invoice != null ? _fmt(invoice.total * (1 + (profile.lateFeePercent / 100) * (15 / 365))) : '[amount + fees]'}.

I value our working relationship and want to resolve this amicably. Could you please let me know when we can expect payment? If there are any issues, I'm open to discussing a payment plan.

I'd appreciate your response by [DATE].

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, the invoice is now 15+ days overdue. As per our contract, late fees of ${profile.lateFeePercent}% p.a. now apply. Can we sort this out this week? Happy to discuss if there's an issue.''',
    ));

    // 12. Payment — Thank You
    messages.add(MessageTemplate(
      stageLabel: 'Payment Received — Thank You',
      emailSubject: 'Payment Received — Thank You! — ${profile.businessName}',
      emailBody: '''Hi ${lead.name.split(' ').first},

I've received your payment — thank you!

${projectProfile != null && projectProfile.requiresHosting ? 'I\'ll continue with the hosting/maintenance as agreed. The next scheduled milestone is [MILESTONE].' : 'The project deliverables have been handed over. If you need any post-handover support, I\'m available.'}

For your records, a receipt has been attached.

It's been a pleasure working with you${lead.company.isNotEmpty ? ' and ${lead.company}' : ''}. If you ever need anything else, don't hesitate to reach out.

Best,
${profile.ownerName}''',
      whatsappBody: '''Hi ${lead.name.split(' ').first}, payment received — thank you! 🙏 ${projectProfile != null && projectProfile.requiresHosting ? 'Continuing with hosting/maintenance as agreed.' : 'All deliverables handed over.'} Great working with you!''',
    ));

    return messages;
  }
}
