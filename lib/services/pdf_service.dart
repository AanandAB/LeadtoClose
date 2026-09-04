import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/quote.dart';

class PdfService {
  static Future<void> printInvoice(Invoice invoice, {String businessName = 'Naro', String currency = '₹'}) async {
    final doc = pw.Document();
    final symbol = currency;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Invoice', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(invoice.number, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.                  Text('Date: ${_formatDate(invoice.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Due: ${_formatDate(invoice.dueDate)}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Terms: ${invoice.paymentTerms}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // Status badge
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: invoice.status == 'paid' ? PdfColors.green50 : PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(invoice.status.toUpperCase(), style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold,
              color: invoice.status == 'paid' ? PdfColors.green800 : PdfColors.orange800,
            )),
          ),
          pw.SizedBox(height: 20),

          // Line items table
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            headerAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headerHeight: 35,
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            headerPadding: const pw.EdgeInsets.all(8),
            cellPadding: const pw.EdgeInsets.all(8),
            headers: ['Description', 'Qty', 'Rate', 'Amount'],
            data: invoice.lineItems.map((item) => [
              item.description,
              item.quantity.toStringAsFixed(0),
              '$symbol${item.rate.toStringAsFixed(2)}',
              '$symbol${(item.quantity * item.rate).toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 16),

          // Totals
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                width: 250,
                child: pw.Column(
                  children: [
                    _totalRow('Subtotal', '$symbol${invoice.subtotal.toStringAsFixed(2)}'),
                    if (invoice.taxRate > 0)
                      _totalRow('Tax (${invoice.taxRate.toStringAsFixed(1)}%)', '$symbol${invoice.taxAmount.toStringAsFixed(2)}'),
                    if (invoice.discount > 0)
                      _totalRow('Discount', '-$symbol${invoice.discount.toStringAsFixed(2)}'),
                    pw.Divider(),
                    _totalRow('Total', '$symbol${invoice.total.toStringAsFixed(2)}', bold: true),
                    if (invoice.amountPaid > 0)
                      _totalRow('Paid', '-$symbol${invoice.amountPaid.toStringAsFixed(2)}'),
                    _totalRow('Balance Due', '$symbol${invoice.balanceDue.toStringAsFixed(2)}', bold: true, color: PdfColors.red800),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // Notes
          if (invoice.notes.isNotEmpty) ...[
            pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Text(invoice.notes, style: const pw.TextStyle(fontSize: 10)),
          ],
          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Generated by Naro CRM', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '${invoice.number}.pdf',
    );
  }

  static Future<void> printProposal(Quote quote, {String businessName = 'Naro', String currency = '₹'}) async {
    final doc = pw.Document();
    final symbol = currency;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Proposal', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(quote.number, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Date: ${_formatDate(quote.createdAt)}', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Valid: ${quote.validUntil}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          if (quote.title.isNotEmpty)
            pw.Text(quote.title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 30),

          // Status
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: pw.BoxDecoration(
              color: quote.status == 'accepted' ? PdfColors.green50 : PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(quote.status.toUpperCase(), style: pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold,
              color: quote.status == 'accepted' ? PdfColors.green800 : PdfColors.blue800,
            )),
          ),
          pw.SizedBox(height: 20),

          // Line items
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            headerAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
            cellHeight: 30,
            headerHeight: 35,
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            headerPadding: const pw.EdgeInsets.all(8),
            cellPadding: const pw.EdgeInsets.all(8),
            headers: ['Description', 'Qty', 'Rate', 'Amount'],
            data: quote.lineItems.map((item) => [
              item.description,
              item.quantity.toStringAsFixed(0),
              '$symbol${item.rate.toStringAsFixed(2)}',
              '$symbol${(item.quantity * item.rate).toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 16),

          // Totals
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                width: 250,
                child: pw.Column(
                  children: [
                    _totalRow('Subtotal', '$symbol${quote.subtotal.toStringAsFixed(2)}'),
                    if (quote.taxRate > 0)
                      _totalRow('Tax (${quote.taxRate.toStringAsFixed(1)}%)', '$symbol${quote.taxAmount.toStringAsFixed(2)}'),
                    _totalRow('Total', '$symbol${quote.total.toStringAsFixed(2)}', bold: true),
                  ],
                ),
              ),
            ],
          ),

          // Notes
          if (quote.notes.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            pw.SizedBox(height: 4),
            pw.Text(quote.notes, style: const pw.TextStyle(fontSize: 10)),
          ],
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Text('Generated by Naro CRM', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '${quote.number}.pdf',
    );
  }

  static pw.Widget _totalRow(String label, String value, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? PdfColors.black,
          )),
          pw.Text(value, style: pw.TextStyle(
            fontSize: 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? PdfColors.black,
          )),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
