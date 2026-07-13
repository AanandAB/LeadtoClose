
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/business_profile.dart';
import '../models/lead.dart';
import '../models/project_profile.dart';
import '../models/quote.dart';
import '../models/invoice.dart';

class InvoiceService {
  int _invoiceCounter = 1;

  Invoice generateInvoice({
    required String leadId, required Quote quote,
    required ProjectProfile profile, required BusinessProfile businessProfile,
    required Lead lead,
  }) {
    final isGstRegistered = businessProfile.isGstRegistered;
    final isExport = profile.isExport;
    final isInterState = profile.isInterState;

    // Convert quote line items to invoice line items
    final lineItems = quote.lineItems.map((ql) => InvoiceLineItem(
      description: ql.description, amount: ql.amount, category: ql.category,
    )).toList();

    double cgst = 0, sgst = 0, igst = 0;
    String gstTreatment;
    double gstRate = 0;

    if (!isGstRegistered) {
      gstTreatment = 'Not Registered';
    } else if (isExport) {
      gstTreatment = 'Zero-Rated (Export) — LUT applied';
    } else if (isInterState) {
      gstTreatment = 'IGST @ 18%';
      igst = quote.subtotal * 0.18;
      gstRate = 18;
    } else {
      gstTreatment = 'CGST 9% + SGST 9%';
      cgst = quote.subtotal * 0.09;
      sgst = quote.subtotal * 0.09;
      gstRate = 18;
    }

    final gstAmount = cgst + sgst + igst;
    final total = quote.subtotal + gstAmount;

    // TDS estimation (10% under 194J for professional services)
    final tdsAmount = isExport ? 0.0 : quote.subtotal * 0.10;

    final invNum = 'INV-${DateTime.now().year}-${_invoiceCounter.toString().padLeft(4, '0')}';
    _invoiceCounter++;

    return Invoice(
      id: const Uuid().v4(), leadId: leadId, quoteId: quote.id,
      number: invNum, lineItems: lineItems,
      subtotal: quote.subtotal, gstAmount: gstAmount, total: total,
      gstTreatment: gstTreatment, cgstRate: 9, sgstRate: 9,
      igstRate: isInterState ? 18.0 : 0, sacCode: quote.sacCode,
      currency: isExport ? 'USD' : 'INR',
      createdAt: DateTime.now(),
      expectedTdsAmount: tdsAmount,
    );
  }

  Future<void> exportPdf({
    required Invoice invoice, required Lead lead,
    required BusinessProfile profile,
  }) async {
    final doc = pw.Document();
    final isExport = invoice.currency == 'USD';
    final symbol = isExport ? '\$' : '\u{20B9}';

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // Header
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(profile.businessName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(profile.email, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            if (profile.phone.isNotEmpty) pw.Text(profile.phone, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
            pw.SizedBox(height: 4),
            pw.Text('Invoice #: ${invoice.number}', style: pw.TextStyle(fontSize: 10)),
            pw.Text('Date: ${_fmt(invoice.createdAt)}', style: pw.TextStyle(fontSize: 10)),
            pw.Text('Due: ${_fmt(invoice.dueDate)}', style: pw.TextStyle(fontSize: 10, color: PdfColors.red)),
          ]),
        ]),
        pw.SizedBox(height: 16),

        // Business details
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('From:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Text('PAN: ${profile.pan}', style: pw.TextStyle(fontSize: 9)),
              if (profile.gstin.isNotEmpty) pw.Text('GSTIN: ${profile.gstin}', style: pw.TextStyle(fontSize: 9)),
            ])),
            pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Bill To:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
              pw.Text(lead.name, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              if (lead.company.isNotEmpty) pw.Text(lead.company, style: pw.TextStyle(fontSize: 9)),
            ])),
          ]),
        ),
        pw.SizedBox(height: 20),

        // Line Items
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(1.5), 2: const pw.FlexColumnWidth(1.5)},
          children: [
            pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            ]),
            ...invoice.lineItems.map((item) => pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.description, style: const pw.TextStyle(fontSize: 9))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.category, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$symbol${item.amount.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 9))),
            ])),
          ],
        ),
        pw.SizedBox(height: 16),

        // Totals
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Container(width: 250, child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('$symbol${invoice.subtotal.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
          ]),
          pw.SizedBox(height: 4),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('GST (${invoice.gstTreatment}):', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Text('$symbol${invoice.gstAmount.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 10)),
          ]),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('$symbol${invoice.total.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
          ]),
          if (invoice.expectedTdsAmount > 0) ...[
            pw.SizedBox(height: 12),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Expected TDS (10% u/s 194J):', style: pw.TextStyle(fontSize: 9, color: PdfColors.orange, fontStyle: pw.FontStyle.italic)),
              pw.Text('-$symbol${invoice.expectedTdsAmount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 9, color: PdfColors.orange, fontStyle: pw.FontStyle.italic)),
            ]),
            pw.SizedBox(height: 2),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Expected Net Receipt:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('$symbol${(invoice.total - invoice.expectedTdsAmount).toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ]),
          ],
        ]))),
        pw.SizedBox(height: 30),

        // Footer
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('SAC Code: ${invoice.sacCode}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        if (profile.gstin.isNotEmpty) pw.Text('GSTIN: ${profile.gstin}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.Text('PAN: ${profile.pan}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        if (profile.bankDetails.isNotEmpty) pw.Text('Bank: ${profile.bankDetails}', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 6),
        pw.Text('This is a computer-generated invoice. Payment due within 30 days.',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 2),
        pw.Text('Note: TDS amount is an estimate — actual deduction depends on client\'s TDS return.',
            style: pw.TextStyle(fontSize: 7, color: PdfColors.orange, fontStyle: pw.FontStyle.italic)),
      ],
    ));

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Invoice_${invoice.number}.pdf',
    );
  }

  String _fmt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month-1]} ${dt.year}';
  }
}
