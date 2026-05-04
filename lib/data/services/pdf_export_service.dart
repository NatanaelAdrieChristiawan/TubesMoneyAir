import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/transaction_model.dart' as t_model;

class PdfExportService {
  Future<void> shareExpensesPdf({
    required List<t_model.Transaction> expenses,
    String title = 'Laporan Pengeluaran',
    String? periodLabel,
  }) async {
    if (expenses.isEmpty) {
      throw Exception('Tidak ada data pengeluaran untuk diekspor');
    }

    final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    final total = sorted.fold<double>(0, (s, e) => s + e.amount);
    final formatter = NumberFormat('#,##0', 'id_ID');

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.now())),
              ],
            ),
            if (periodLabel != null) pw.SizedBox(height: 6),
            if (periodLabel != null)
              pw.Text('Periode: $periodLabel',
                  style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Jumlah Transaksi: ${sorted.length}'),
                  pw.Text('Total Pengeluaran: Rp ${formatter.format(total)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              headers: const ['Tanggal', 'Kategori', 'Catatan/Dompet', 'Jumlah'],
              data: [
                for (final e in sorted)
                  [
                    DateFormat('dd/MM/yyyy').format(e.date),
                    e.category,
                    _buildNoteWallet(e),
                    'Rp ${formatter.format(e.amount)}',
                  ]
              ],
              border: null,
              headerHeight: 28,
              cellHeight: 24,
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Dihasilkan oleh MoneyAir',
                  style:
                      pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
            )
          ];
        },
      ),
    );

    final Uint8List bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'laporan_pengeluaran_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  String _buildNoteWallet(t_model.Transaction e) {
    final note = (e.notes.trim().isNotEmpty) ? e.notes.trim() : '-';
    final wallet = e.wallet.isNotEmpty ? e.wallet : 'Dompet';
    return '$note • $wallet';
  }
}
