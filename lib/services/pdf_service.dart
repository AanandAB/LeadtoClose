import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../models/quote.dart';

class PdfService {
  static const _brandColor = PdfColor(0.36, 0.31, 0.91); // #5B4FE9
  static const _accentColor = PdfColor(0.55, 0.50, 1.0);  // #8B7FFF

  // ======================== INVOICE PDF ========================

  static Future<void> printInvoice(Invoice invoice, {String businessName = 'FreelanceHub', String currency = '₹'}) async {
    final doc = pw.Document();
    final symbol = currency;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 50),
        build: (context) => [
          _invoiceHeader(invoice, businessName, symbol),
          pw.SizedBox(height: 30),
          _invoiceStatusBadge(invoice.status),
          pw.SizedBox(height: 25),
          _invoiceLineItemsTable(invoice, symbol),
          pw.SizedBox(height: 20),
          _invoiceTotals(invoice, symbol),
          pw.SizedBox(height: 30),
          if (invoice.notes.isNotEmpty) ...[
            _sectionTitle('Notes'),
            pw.SizedBox(height: 6),
            pw.Text(invoice.notes, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 20),
          ],
          _paymentInfo(invoice, symbol),
          pw.SizedBox(height: 40),
          _footer(businessName),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '${invoice.number}.pdf',
    );
  }

  static pw.Widget _invoiceHeader(Invoice invoice, String businessName, String symbol) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(businessName, style: pw.TextStyle(
              fontSize: 28, fontWeight: pw.FontWeight.bold, color: _brandColor,
            )),
            pw.SizedBox(height: 4),
            pw.Text('INVOICE', style: pw.TextStyle(
              fontSize: 12, color: PdfColors.grey500, letterSpacing: 2,
            )),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _infoLabel('Invoice No.'),
            pw.Text(invoice.number, style: pw.TextStyle(
              fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800,
            )),
            pw.SizedBox(height: 8),
            _infoLabel('Issue Date'),
            pw.Text(_formatDate(invoice.createdAt), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            _infoLabel('Due Date'),
            pw.Text(_formatDate(invoice.dueDate), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            _infoLabel('Payment Terms'),
            pw.Text(invoice.paymentTerms, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _invoiceStatusBadge(String status) {
    final color = status == 'paid' ? PdfColors.green800
        : status == 'overdue' ? PdfColors.red800
        : status == 'sent' ? PdfColors.blue800
        : PdfColors.grey700;
    final bgColor = status == 'paid' ? PdfColors.green50
        : status == 'overdue' ? PdfColors.red50
        : status == 'sent' ? PdfColors.blue50
        : PdfColors.grey100;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(status.toUpperCase(), style: pw.TextStyle(
        fontSize: 10, fontWeight: pw.FontWeight.bold, color: color, letterSpacing: 1,
      )),
    );
  }

  static pw.Widget _invoiceLineItemsTable(Invoice invoice, String symbol) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _brandColor),
      headerAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellHeight: 32,
      headerHeight: 36,
      columnWidths: {
        0: const pw.FlexColumnWidth(4.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2.5),
      },
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellAlignments: {
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: ['Description', 'Qty', 'Rate', 'Amount'],
      data: invoice.lineItems.map((item) => [
        item.description,
        item.quantity.toStringAsFixed(0),
        '$symbol${item.rate.toStringAsFixed(2)}',
        '$symbol${(item.quantity * item.rate).toStringAsFixed(2)}',
      ]).toList(),
    );
  }

  static pw.Widget _invoiceTotals(Invoice invoice, String symbol) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 260,
          child: pw.Column(
            children: [
              _totalRow('Subtotal', '$symbol${invoice.subtotal.toStringAsFixed(2)}'),
              if (invoice.taxRate > 0) ...[
                pw.SizedBox(height: 4),
                _totalRow('Tax (${invoice.taxRate.toStringAsFixed(1)}%)', '$symbol${invoice.taxAmount.toStringAsFixed(2)}'),
              ],
              if (invoice.discount > 0) ...[
                pw.SizedBox(height: 4),
                _totalRow('Discount', '-$symbol${invoice.discount.toStringAsFixed(2)}'),
              ],
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              _totalRow('Total', '$symbol${invoice.total.toStringAsFixed(2)}', bold: true),
              if (invoice.amountPaid > 0) ...[
                pw.SizedBox(height: 4),
                _totalRow('Amount Paid', '-$symbol${invoice.amountPaid.toStringAsFixed(2)}', color: PdfColors.green800),
              ],
              pw.SizedBox(height: 4),
              _totalRow('Balance Due', '$symbol${invoice.balanceDue.toStringAsFixed(2)}', bold: true, color: PdfColors.red800),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _paymentInfo(Invoice invoice, String symbol) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(0.95, 0.95, 1.0),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor(0.9, 0.9, 1.0)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Information', style: pw.TextStyle(
            fontSize: 12, fontWeight: pw.FontWeight.bold, color: _brandColor,
          )),
          pw.SizedBox(height: 8),
          pw.Text('Please make payment by ${_formatDate(invoice.dueDate)}.', style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text('Payment terms: ${invoice.paymentTerms}', style: pw.TextStyle(fontSize: 10)),
          if (invoice.isOverdue) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'This invoice is ${invoice.daysOverdue} day(s) overdue. Please pay immediately.',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.red800, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  // ======================== PROPOSAL PDF ========================

  static Future<void> printProposal(Quote quote, {String businessName = 'FreelanceHub', String currency = '₹'}) async {
    final doc = pw.Document();
    final symbol = currency;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 50),
        build: (context) => [
          _proposalHeader(quote, businessName, symbol),
          pw.SizedBox(height: 30),
          if (quote.title.isNotEmpty) ...[
            pw.Text(quote.title, style: pw.TextStyle(
              fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900,
            )),
            pw.SizedBox(height: 20),
          ],
          _proposalStatusBadge(quote.status),
          pw.SizedBox(height: 25),
          _proposalLineItemsTable(quote, symbol),
          pw.SizedBox(height: 20),
          _proposalTotals(quote, symbol),
          pw.SizedBox(height: 30),
          if (quote.notes.isNotEmpty) ...[
            _sectionTitle('Notes & Terms'),
            pw.SizedBox(height: 6),
            pw.Text(quote.notes, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 20),
          ],
          _proposalValidity(quote),
          pw.SizedBox(height: 40),
          _footer(businessName),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '${quote.number}.pdf',
    );
  }

  static pw.Widget _proposalHeader(Quote quote, String businessName, String symbol) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(businessName, style: pw.TextStyle(
              fontSize: 28, fontWeight: pw.FontWeight.bold, color: _brandColor,
            )),
            pw.SizedBox(height: 4),
            pw.Text('PROPOSAL', style: pw.TextStyle(
              fontSize: 12, color: PdfColors.grey500, letterSpacing: 2,
            )),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _infoLabel('Proposal No.'),
            pw.Text(quote.number, style: pw.TextStyle(
              fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800,
            )),
            pw.SizedBox(height: 8),
            _infoLabel('Date'),
            pw.Text(_formatDate(quote.createdAt), style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            _infoLabel('Valid Until'),
            pw.Text(quote.validUntil, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _proposalStatusBadge(String status) {
    final color = status == 'accepted' ? PdfColors.green800
        : status == 'rejected' ? PdfColors.red800
        : status == 'sent' ? PdfColors.blue800
        : PdfColors.grey700;
    final bgColor = status == 'accepted' ? PdfColors.green50
        : status == 'rejected' ? PdfColors.red50
        : status == 'sent' ? PdfColors.blue50
        : PdfColors.grey100;

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(status.toUpperCase(), style: pw.TextStyle(
        fontSize: 10, fontWeight: pw.FontWeight.bold, color: color, letterSpacing: 1,
      )),
    );
  }

  static pw.Widget _proposalLineItemsTable(Quote quote, String symbol) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _brandColor),
      headerAlignment: pw.Alignment.centerLeft,
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
      cellHeight: 32,
      headerHeight: 36,
      columnWidths: {
        0: const pw.FlexColumnWidth(4.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2.5),
      },
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      cellAlignments: {
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: ['Description', 'Qty', 'Rate', 'Amount'],
      data: quote.lineItems.map((item) => [
        item.description,
        item.quantity.toStringAsFixed(0),
        '$symbol${item.rate.toStringAsFixed(2)}',
        '$symbol${(item.quantity * item.rate).toStringAsFixed(2)}',
      ]).toList(),
    );
  }

  static pw.Widget _proposalTotals(Quote quote, String symbol) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 260,
          child: pw.Column(
            children: [
              _totalRow('Subtotal', '$symbol${quote.subtotal.toStringAsFixed(2)}'),
              if (quote.taxRate > 0) ...[
                pw.SizedBox(height: 4),
                _totalRow('Tax (${quote.taxRate.toStringAsFixed(1)}%)', '$symbol${quote.taxAmount.toStringAsFixed(2)}'),
              ],
              pw.Container(height: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              _totalRow('Total', '$symbol${quote.total.toStringAsFixed(2)}', bold: true),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _proposalValidity(Quote quote) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor(0.95, 0.95, 1.0),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColor(0.9, 0.9, 1.0)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Proposal Validity', style: pw.TextStyle(
            fontSize: 12, fontWeight: pw.FontWeight.bold, color: _brandColor,
          )),
          pw.SizedBox(height: 8),
          pw.Text('This proposal is valid for ${quote.validUntil}.', style: pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Text('Please confirm acceptance before the expiry date to lock in the quoted rates.', style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ======================== SHARED HELPERS ========================

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(title, style: pw.TextStyle(
      fontSize: 13, fontWeight: pw.FontWeight.bold, color: _brandColor,
    ));
  }

  static pw.Widget _infoLabel(String text) {
    return pw.Text(text, style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500, letterSpacing: 0.5));
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
            color: color ?? PdfColors.grey800,
          )),
          pw.Text(value, style: pw.TextStyle(
            fontSize: bold ? 12 : 10,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? PdfColors.grey800,
          )),
        ],
      ),
    );
  }

  static pw.Widget _footer(String businessName) {
    return pw.Column(
      children: [
        pw.Container(height: 1, color: PdfColors.grey200),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Thank you for your business!', style: pw.TextStyle(
              fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic,
            )),
            pw.Text('Powered by FreelanceHub', style: pw.TextStyle(
              fontSize: 8, color: PdfColors.grey400,
            )),
          ],
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
