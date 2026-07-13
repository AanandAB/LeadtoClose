
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';
import '../models/business_profile.dart';
import '../models/lead.dart';
import '../models/project_profile.dart';
import '../models/quote.dart';
import '../models/contract.dart';
import '../models/compliance_item.dart';
import 'rules_engine.dart';

class ContractService {
  Contract generateContract({
    required String leadId,
    required Quote quote,
    required ProjectProfile profile,
    required BusinessProfile businessProfile,
    required Lead lead,
  }) {
    final clauses = <ContractClause>[];

    // 1. Scope of Work
    final scopeItems = quote.lineItems.map((i) => '  - ${i.description} (${i.category})').join('\n');
    clauses.add(ContractClause(
      title: '1. Scope of Work',
      body: 'The Developer agrees to provide the following services to the Client:\n$scopeItems\n\n'
          'Any work beyond the scope defined above shall be treated as a Change Request and billed separately.',
      category: 'standard', trigger: 'Always',
    ));

    // 2. Payment Terms
    clauses.add(ContractClause(
      title: '2. Payment Terms',
      body: 'Total Project Fee: \u{20B9}${quote.total.toStringAsFixed(0)}\n'
          'Payment Schedule:\n'
          '  - 40% advance on signing this Agreement\n'
          '  - 30% on mid-project milestone completion\n'
          '  - 30% on final delivery and sign-off\n\n'
          'All payments shall be made within 15 days of invoice date. '
          'Late payments shall attract interest at ${businessProfile.lateFeePercent}% per annum from the due date.',
      category: 'standard', trigger: 'Always',
    ));

    // 3. Deadlines
    clauses.add(ContractClause(
      title: '3. Project Timeline',
      body: 'The project shall commence on the date of advance payment receipt. '
          'Estimated delivery timeline shall be communicated in the project workspace. '
          'Delays caused by the Client (delayed feedback, content, or approvals) shall extend the timeline accordingly.',
      category: 'standard', trigger: 'Always',
    ));

    // 4. Revisions
    clauses.add(ContractClause(
      title: '4. Revisions & Change Requests',
      body: 'The project includes up to 3 rounds of revisions. '
          'Additional revision rounds beyond the included limit shall be billed at the Developer\'s standard hourly rate. '
          'Any change that materially alters the scope defined in Clause 1 shall be treated as a Change Request and quoted separately.',
      category: 'standard', trigger: 'Always',
    ));

    // 5. IP Clause
    if (profile.wantsFullOwnership) {
      clauses.add(ContractClause(
        title: '5. Intellectual Property — Full Assignment',
        body: 'Upon receipt of full and final payment, the Developer hereby assigns all right, title, and interest '
            'in the Deliverables to the Client. This includes all source code, design files, documentation, and associated materials. '
            'Until full payment is received, all IP remains with the Developer.\n\n'
            'The Developer retains the right to: (a) display the work in their portfolio; '
            '(b) reuse non-project-specific frameworks, libraries, and components developed independently.',
        category: 'conditional', trigger: 'Q9: Full Ownership',
      ));
    } else {
      clauses.add(ContractClause(
        title: '5. Intellectual Property — License',
        body: 'The Developer grants the Client a perpetual, non-exclusive, non-transferable license '
            'to use the Deliverables for their business purposes. The Developer retains all intellectual property rights, '
            'including the right to reuse core frameworks, components, and libraries in other projects.\n\n'
            'The Client may not resell, sublicense, or distribute the Deliverables (or any derivative works) without written permission.',
        category: 'conditional', trigger: 'Q9: License',
      ));
    }

    // 6. Confidentiality
    clauses.add(ContractClause(
      title: '6. Confidentiality',
      body: 'Both parties agree to keep confidential all proprietary information disclosed during the engagement. '
          'This obligation survives termination of this Agreement for a period of 3 years.',
      category: 'standard', trigger: 'Always',
    ));

    // 7. Termination
    clauses.add(ContractClause(
      title: '7. Termination',
      body: 'Either party may terminate this Agreement with 15 days written notice. '
          'Upon termination, the Client shall pay for all work completed up to the termination date. '
          'The Developer shall deliver all completed work upon receipt of such payment.',
      category: 'standard', trigger: 'Always',
    ));

    // 8. Data Handling (DPDPA)
    if (profile.collectsPersonalData) {
      clauses.add(ContractClause(
        title: '8. Data Protection & Privacy',
        body: 'The Client is the Data Fiduciary under the Digital Personal Data Protection Act, 2023. '
            'The Developer acts as a Data Processor and shall:\n'
            '  (a) Process personal data only on documented instructions from the Client\n'
            '  (b) Implement reasonable security safeguards to protect personal data\n'
            '  (c) Notify the Client of any personal data breach within 24 hours\n'
            '  (d) Delete or return all personal data upon completion of services\n\n'
            'The Client is responsible for obtaining valid consent from data principals and maintaining a privacy notice.',
        category: 'conditional', trigger: 'Q2: Personal Data',
      ));
    }

    // 9. Hosting/CERT-In
    if (profile.requiresHosting) {
      clauses.add(ContractClause(
        title: '9. Hosting, Maintenance & Security',
        body: 'The Developer shall provide hosting and/or maintenance services as specified in the Scope of Work. '
            'Service Level: The Developer shall maintain 99.5% uptime (excluding scheduled maintenance).\n'
            'Incident Reporting: In compliance with CERT-In directions, the Developer shall report '
            'any cybersecurity incident within 6 hours of detection and maintain security logs for 180 days.\n'
            'Data Processing: The Developer acts as a Data Processor and shall process data only as instructed by the Client, '
            'with appropriate technical and organisational security measures.',
        category: 'conditional', trigger: 'Q6: Hosting',
      ));
    }

    // 10. Jurisdiction
    if (profile.isExport) {
      clauses.add(ContractClause(
        title: '10. Governing Law & Jurisdiction',
        body: 'This Agreement shall be governed by and construed in accordance with the laws of India. '
            'Any dispute arising out of or in connection with this Agreement shall be subject to the exclusive jurisdiction '
            'of the courts at [Freelancer\'s Location], India.',
        category: 'conditional', trigger: 'Q5: Export',
      ));
    } else {
      clauses.add(ContractClause(
        title: '10. Governing Law & Jurisdiction',
        body: 'This Agreement shall be governed by and construed in accordance with the laws of India. '
            'Any dispute arising out of or in connection with this Agreement shall be subject to the exclusive jurisdiction '
            'of the courts at [Freelancer\'s Location].',
        category: 'standard', trigger: 'Always',
      ));
    }

    // 11. Indemnification
    clauses.add(ContractClause(
      title: '11. Indemnification',
      body: 'Each party agrees to indemnify and hold harmless the other from claims arising out of '
          'the indemnifying party\'s breach of this Agreement or violation of applicable law.',
      category: 'standard', trigger: 'Always',
    ));

    // 12. Electronic Execution
    clauses.add(ContractClause(
      title: '12. Electronic Execution',
      body: 'This Agreement may be executed electronically and in counterparts. '
          'Electronic signatures and communications (including email and WhatsApp approvals) '
          'shall be valid and binding under Section 10-A of the Information Technology Act, 2000.',
      category: 'standard', trigger: 'Always',
    ));

    // E-Commerce clause
    if (profile.acceptsPayments) {
      clauses.add(ContractClause(
        title: '13. E-Commerce Compliance',
        body: 'The Client acknowledges responsibility for ongoing accuracy of e-commerce content, '
            'including product descriptions, pricing, return/refund policies, and Grievance Officer contact details '
            'as required under the Consumer Protection (E-Commerce) Rules, 2020.',
        category: 'conditional', trigger: 'Q3: Payments',
      ));
    }

    // Disclaimer (last, non-removable)
    clauses.add(ContractClause(
      title: 'DISCLAIMER',
      body: 'This Agreement has been generated based on the project parameters provided. '
          'It is NOT a substitute for review by a qualified lawyer. '
          'The Developer recommends legal review before signing, especially for enterprise-tier or first-of-kind engagements.',
      category: 'disclaimer', trigger: 'Always',
    ));

    return Contract(
      id: const Uuid().v4(), leadId: leadId, quoteId: quote.id,
      clauses: clauses, createdAt: DateTime.now(),
    );
  }

  Future<void> exportPdf({
    required Contract contract, required Lead lead,
    required BusinessProfile profile,
  }) async {
    final doc = pw.Document();

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // Header
        pw.Center(child: pw.Text('SERVICE AGREEMENT', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo))),
        pw.SizedBox(height: 8),
        pw.Center(child: pw.Text('Generated by LeadToClose', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500))),
        pw.SizedBox(height: 20),

        // Parties
        pw.Text('BETWEEN:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('${profile.businessName} ("Developer")', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text(profile.email, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        if (profile.gstin.isNotEmpty) pw.Text('GSTIN: ${profile.gstin}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.SizedBox(height: 10),
        pw.Text('AND:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('${lead.name}${lead.company.isNotEmpty ? " (${lead.company})" : ""} ("Client")', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 20),
        pw.Divider(),
        pw.SizedBox(height: 12),

        // Clauses
        ...contract.clauses.where((c) => c.category != 'disclaimer').map((clause) => pw.Column(children: [
          pw.SizedBox(height: 14),
          pw.Text(clause.title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(clause.body, style: pw.TextStyle(fontSize: 10, lineSpacing: 1.4)),
          if (clause.trigger.isNotEmpty && clause.trigger != 'Always')
            pw.Text('  [Trigger: ${clause.trigger}]', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic)),
        ])),

        // Disclaimer
        pw.SizedBox(height: 30),
        pw.Divider(),
        pw.SizedBox(height: 8),
        ...contract.clauses.where((c) => c.category == 'disclaimer').map((clause) => pw.Column(children: [
          pw.Text(clause.title, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
          pw.SizedBox(height: 4),
          pw.Text(clause.body, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
        ])),
      ],
    ));

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Agreement_${lead.name}.pdf',
    );
  }
}
