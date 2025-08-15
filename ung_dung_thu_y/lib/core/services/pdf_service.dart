import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';

class PdfService {
  static pw.Font? _vietnameseFont;
  static pw.Font? _vietnameseFontBold;

  static Future<void> _loadFonts() async {
    if (_vietnameseFont == null) {
      try {
        // Try to load system fonts that support Vietnamese
        _vietnameseFont = await PdfGoogleFonts.notoSansRegular();
        _vietnameseFontBold = await PdfGoogleFonts.notoSansBold();
      } catch (e) {
        // Fallback to basic fonts
        _vietnameseFont = pw.Font.helvetica();
        _vietnameseFontBold = pw.Font.helveticaBold();
      }
    }
  }

  static String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  static String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String _formatDateOnly(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy', 'vi_VN').format(date);
    } catch (e) {
      return dateString;
    }
  }

  static int _calculateDays(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      return end.difference(start).inDays +
          1; // +1 to include both start and end day
    } catch (e) {
      return 1;
    }
  }

  static String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'CHƯA THANH TOÁN';
      case 1:
        return 'ĐÃ THANH TOÁN';
      case 2:
        return 'ĐÃ HỦY';
      default:
        return 'KHÔNG XÁC ĐỊNH';
    }
  }

  static Future<Uint8List> generateInvoicePdf(InvoiceResponse invoice) async {
    await _loadFonts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Company Info
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PHÒNG KHÁM THÚ Y PETCARE',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Địa chỉ: 123 Đường ABC, Quận XYZ, TP. Hồ Chí Minh',
                      style: pw.TextStyle(
                        font: _vietnameseFont,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Email: info@petcare.vn',
                      style: pw.TextStyle(
                        font: _vietnameseFont,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 2,
                      width: double.infinity,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'HÓA ĐƠN DỊCH VỤ THÚ Y',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice Info Section
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Ma hoa don: ${invoice.invoiceCode}',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Ngay lap: ${_formatDate(invoice.createdAt)}',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color:
                            invoice.status == 1
                                ? PdfColors.green100
                                : invoice.status == 2
                                ? PdfColors.red100
                                : PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(
                          color:
                              invoice.status == 1
                                  ? PdfColors.green300
                                  : invoice.status == 2
                                  ? PdfColors.red300
                                  : PdfColors.orange300,
                        ),
                      ),
                      child: pw.Text(
                        _getStatusText(invoice.status),
                        style: pw.TextStyle(
                          font: _vietnameseFontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color:
                              invoice.status == 1
                                  ? PdfColors.green800
                                  : invoice.status == 2
                                  ? PdfColors.red800
                                  : PdfColors.orange800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Customer and Doctor Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'THONG TIN KHACH HANG',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.blue300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ho ten: ${invoice.user.fullname ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'So dien thoai: ${invoice.user.phoneNumber}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Dia chi: ${invoice.user.address ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Doctor Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.green300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'BAC SI DIEU TRI',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.green300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ho ten: ${invoice.doctor.fullname ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'So dien thoai: ${invoice.doctor.phoneNumber}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Services Section
              if (invoice.services.isNotEmpty) ...[
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    'CHI TIET DICH VU',
                    style: pw.TextStyle(
                      font: _vietnameseFontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 1,
                  ),
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    1: pw.FlexColumnWidth(4),
                    2: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.blue100),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'STT',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Ten dich vu',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Gia tien (VND)',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...invoice.services.asMap().entries.map(
                      (entry) => pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color:
                              entry.key % 2 == 0
                                  ? PdfColors.white
                                  : PdfColors.grey50,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${entry.key + 1}',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              entry.value.name,
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _formatCurrency(entry.value.price),
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // Medications Section
              if (invoice.prescriptionDetail.isNotEmpty) ...[
                pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    'CHI TIET THUOC DIEU TRI',
                    style: pw.TextStyle(
                      font: _vietnameseFontBold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                    width: 1,
                  ),
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    1: pw.FlexColumnWidth(3),
                    2: pw.FixedColumnWidth(60),
                    3: pw.FlexColumnWidth(2),
                    4: pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.green100),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'STT',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Ten thuoc',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'So luong',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Don gia (VND)',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Thanh tien (VND)',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    ...invoice.prescriptionDetail.asMap().entries.map(
                      (entry) => pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color:
                              entry.key % 2 == 0
                                  ? PdfColors.white
                                  : PdfColors.grey50,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${entry.key + 1}',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              entry.value.medication.name,
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${entry.value.quantity}',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _formatCurrency(entry.value.medication.price),
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _formatCurrency(
                                entry.value.medication.price *
                                    entry.value.quantity,
                              ),
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 9,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // Total Section
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue300, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TONG TIEN THANH TOAN:',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      _formatCurrency(invoice.totalAmount),
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer with signatures
              pw.Container(
                padding: pw.EdgeInsets.only(top: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'KHACH HANG',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey400,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(Ky va ghi ro ho ten)',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'BAC SI DIEU TRI',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey400,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(Ky va ghi ro ho ten)',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer note
              pw.Container(
                padding: pw.EdgeInsets.only(top: 16),
                child: pw.Center(
                  child: pw.Text(
                    'Cam on quy khach da su dung dich vu cua chung toi!',
                    style: pw.TextStyle(
                      font: _vietnameseFont,
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateKennelInvoicePdf(
    InvoiceKennelDto invoice,
  ) async {
    await _loadFonts();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header - Company Info
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'PHONG KHAM THU Y PETCARE',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Dia chi: 123 Duong ABC, Quan XYZ, TP. Ho Chi Minh',
                      style: pw.TextStyle(
                        font: _vietnameseFont,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Dien thoai: (028) 1234 5678 | Email: info@petcare.vn',
                      style: pw.TextStyle(
                        font: _vietnameseFont,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      height: 2,
                      width: double.infinity,
                      color: PdfColors.blue800,
                    ),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      'HOA DON DICH VU LUU CHUONG',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice Info Section
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Ma hoa don: ${invoice.invoiceCode}',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Ngay lap: ${_formatDate(invoice.createdAt)}',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color:
                            invoice.status == 1
                                ? PdfColors.green100
                                : invoice.status == 2
                                ? PdfColors.red100
                                : PdfColors.orange100,
                        borderRadius: pw.BorderRadius.circular(12),
                        border: pw.Border.all(
                          color:
                              invoice.status == 1
                                  ? PdfColors.green300
                                  : invoice.status == 2
                                  ? PdfColors.red300
                                  : PdfColors.orange300,
                        ),
                      ),
                      child: pw.Text(
                        _getStatusText(invoice.status),
                        style: pw.TextStyle(
                          font: _vietnameseFontBold,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color:
                              invoice.status == 1
                                  ? PdfColors.green800
                                  : invoice.status == 2
                                  ? PdfColors.red800
                                  : PdfColors.orange800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Customer and Doctor Info Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.blue300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'THONG TIN KHACH HANG',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.blue300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ho ten: ${invoice.user.fullname ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'So dien thoai: ${invoice.user.phoneNumber}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Doctor Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.green300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'BAC SI PHU TRACH',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.green300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ho ten: ${invoice.doctor.fullname ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'So dien thoai: ${invoice.doctor.phoneNumber}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Pet and Kennel Info Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Pet Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.purple300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'THONG TIN THU CUNG',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.purple800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.purple300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ten: ${invoice.kennelDetail.pet.name}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Giong: ${invoice.kennelDetail.pet.breed ?? "Chua cap nhat"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Gioi tinh: ${invoice.kennelDetail.pet.gender == 0 ? "Cai" : "Duc"}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Can nang: ${invoice.kennelDetail.pet.weight} kg',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Kennel Info
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.orange300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(vertical: 4),
                            child: pw.Text(
                              'THONG TIN CHUONG',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange800,
                              ),
                            ),
                          ),
                          pw.Divider(color: PdfColors.orange300),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Ten chuong: ${invoice.kennelDetail.kennel.name}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Ngay bat dau: ${_formatDateOnly(invoice.kennelDetail.actualCheckin ?? invoice.kennelDetail.inTime!)}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Ngay ket thuc: ${_formatDateOnly(invoice.kennelDetail.actualCheckout ?? invoice.kennelDetail.outTime!)}',
                            style: pw.TextStyle(
                              font: _vietnameseFont,
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'So ngay: ${_calculateDays(invoice.kennelDetail.actualCheckin ?? invoice.kennelDetail.inTime!, invoice.kennelDetail.actualCheckout ?? invoice.kennelDetail.outTime!)} ngay',
                            style: pw.TextStyle(
                              font: _vietnameseFontBold,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.orange800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Service Details Section
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Text(
                  'CHI TIET DICH VU LUU CHUONG',
                  style: pw.TextStyle(
                    font: _vietnameseFontBold,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                columnWidths: {
                  0: pw.FixedColumnWidth(40),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blue100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'STT',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Mo ta dich vu',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Gia tien (VND)',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '1',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Dich vu luu chuong cho thu cung',
                              style: pw.TextStyle(
                                font: _vietnameseFontBold,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Thu cung: ${invoice.kennelDetail.pet.name}',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              'Chuong: ${invoice.kennelDetail.kennel.name}',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.Text(
                              'Thoi gian: ${_calculateDays(invoice.kennelDetail.actualCheckin ?? invoice.kennelDetail.inTime!, invoice.kennelDetail.actualCheckout ?? invoice.kennelDetail.outTime!)} ngay',
                              style: pw.TextStyle(
                                font: _vietnameseFont,
                                fontSize: 8,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _formatCurrency(invoice.totalAmount),
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Total Section
              pw.Container(
                padding: pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue300, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TONG TIEN THANH TOAN:',
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      _formatCurrency(invoice.totalAmount),
                      style: pw.TextStyle(
                        font: _vietnameseFontBold,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red800,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer with signatures
              pw.Container(
                padding: pw.EdgeInsets.only(top: 20),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'KHACH HANG',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey400,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(Ky va ghi ro ho ten)',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'BAC SI PHU TRACH',
                          style: pw.TextStyle(
                            font: _vietnameseFontBold,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Container(
                          width: 120,
                          height: 1,
                          color: PdfColors.grey400,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          '(Ky va ghi ro ho ten)',
                          style: pw.TextStyle(
                            font: _vietnameseFont,
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer note
              pw.Container(
                padding: pw.EdgeInsets.only(top: 16),
                child: pw.Center(
                  child: pw.Text(
                    'Cam on quy khach da su dung dich vu cua chung toi!',
                    style: pw.TextStyle(
                      font: _vietnameseFont,
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printInvoice(InvoiceResponse invoice) async {
    final pdfData = await generateInvoicePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Hoa_don_${invoice.invoiceCode}.pdf',
    );
  }

  static Future<void> printKennelInvoice(InvoiceKennelDto invoice) async {
    final pdfData = await generateKennelInvoicePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Hoa_don_chuong_${invoice.invoiceCode}.pdf',
    );
  }
}
