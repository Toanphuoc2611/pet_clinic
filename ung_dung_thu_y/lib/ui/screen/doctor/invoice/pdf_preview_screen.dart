import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:ung_dung_thu_y/core/services/pdf_service.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class PdfPreviewScreen extends StatefulWidget {
  final InvoiceResponse invoice;

  const PdfPreviewScreen({super.key, required this.invoice});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isLoading = true;
  Uint8List? _pdfData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final pdfData = await PdfService.generateInvoicePdf(widget.invoice);

      setState(() {
        _pdfData = pdfData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_pdfData != null) {
      try {
        await Printing.layoutPdf(
          onLayout: (format) async => _pdfData!,
          name: 'Hoa_don_${widget.invoice.invoiceCode}.pdf',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF đã được tải xuống thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfData != null) {
      try {
        await Printing.sharePdf(
          bytes: _pdfData!,
          filename: 'Hoa_don_${widget.invoice.invoiceCode}.pdf',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chia sẻ PDF: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xem trước PDF',
          style: TextStyle(fontWeight: FontWeight.bold, color: TColor.white),
        ),
        backgroundColor: TColor.primary,
        foregroundColor: TColor.white,
        elevation: 0,
        actions: [
          if (_pdfData != null) ...[
            IconButton(
              onPressed: _sharePdf,
              icon: Icon(Icons.share),
              tooltip: 'Chia sẻ PDF',
            ),
            IconButton(
              onPressed: _downloadPdf,
              icon: Icon(Icons.download),
              tooltip: 'Tải xuống PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _pdfData != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(TColor.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tạo PDF...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Lỗi khi tạo PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_pdfData != null) {
      return PdfPreview(
        build: (format) => _pdfData!,
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: 'Hoa_don_${widget.invoice.invoiceCode}.pdf',
      );
    }

    return Center(
      child: Text(
        'Không có dữ liệu PDF',
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _sharePdf,
              icon: Icon(Icons.share),
              label: Text('Chia sẻ'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TColor.primary,
                side: BorderSide(color: TColor.primary),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _downloadPdf,
              icon: Icon(Icons.download),
              label: Text('Tải xuống'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
