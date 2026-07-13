
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/business_profile.dart';
import '../models/lead.dart';
import '../models/quote.dart';

class PdfService {
  Future<void> exportQuote({
    required Quote quote,
    required Lead lead,
    required BusinessProfile profile,
  }) async {
    final doc = pw.Document();
    final currency = quote.gstTreatment == 'Zero-Rated (Export)' ? 'USD' : 'INR';
    final symbol = currency == 'USD' ? '\$' : '\u{20B9}';

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(profile.businessName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(profile.email, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Text(profile.phone, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ]),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Text('QUOTE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              pw.SizedBox(height: 4),
              pw.Text('Date: ${_formatDate(quote.createdAt)}', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Quote #: QT-${quote.createdAt.millisecondsSinceEpoch.toString().substring(5)}', style: pw.TextStyle(fontSize: 10)),
            ]),
          ],
        ),
        pw.SizedBox(height: 30),
        pw.Divider(),
        pw.SizedBox(height: 20),

        // Client Info
        pw.Text('Prepared For:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(lead.name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        if (lead.company.isNotEmpty) pw.Text(lead.company, style: pw.TextStyle(fontSize: 11)),
        if (lead.contact.isNotEmpty) pw.Text(lead.contact, style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 30),

        // Line Items Table
        pw.Text('Services', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {0: const pw.FlexColumnWidth(5), 1: const pw.FlexColumnWidth(1.5), 2: const pw.FlexColumnWidth(1.5)},
          children: [
            pw.TableRow(decoration: const pw.BoxDecoration(color: PdfColors.grey100), children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ]),
            ...quote.lineItems.map((item) => pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.description, style: pw.TextStyle(fontSize: 10))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(item.category, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700))),
              pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('$symbol${item.amount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 10))),
            ])),
          ],
        ),
        pw.SizedBox(height: 20),

        // Totals
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 250,
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Subtotal:', style: pw.TextStyle(fontSize: 11)),
                pw.Text('$symbol${quote.subtotal.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 11)),
              ]),
              pw.SizedBox(height: 4),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('GST (${quote.gstTreatment}):', style: pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
                pw.Text('$symbol${quote.gstAmount.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 11)),
              ]),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('$symbol${quote.total.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              ]),
            ]),
          ),
        ),
        pw.SizedBox(height: 30),

        // Footer
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('SAC Code: ${quote.sacCode}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        if (profile.gstin.isNotEmpty) pw.Text('GSTIN: ${profile.gstin}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        if (profile.pan.isNotEmpty) pw.Text('PAN: ${profile.pan}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 10),
        pw.Text('This quote is valid for 30 days from the date above.', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 4),
        pw.Text('Generated by LeadToClose — Compliance-Aware Freelance Business Management', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey400)),
      ],
    ));

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: 'Quote_${lead.name}_v${quote.version}.pdf',
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month-1]} ${dt.year}';
  }
}
