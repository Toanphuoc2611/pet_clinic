import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_state.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_bloc.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_event.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/invoice/pdf_preview_screen.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceResponse invoice;
  bool isFromUser = false;
  InvoiceDetailScreen({
    super.key,
    required this.invoice,
    this.isFromUser = false,
  });

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chưa thanh toán';
      case 1:
        return 'Đã thanh toán';
      case 2:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RedirectVnpayBloc, RedirectVnpayState>(
      listener: (context, state) async {
        if (state is RedirectVnpaySuccess) {
          // Navigate to VNPay webview with the payment URL
          final result = await context.push(
            RouteName.vnpayWebview,
            extra: {
              'paymentUrl': state.url,
              'invoiceCode': widget.invoice.invoiceCode,
            },
          );

          // Handle the result from webview
          if (result == true) {
            // Payment successful, trigger payment confirmation
            context.read<InvoiceBloc>().add(
              PaymentInvoiceStarted(widget.invoice.id),
            );
          }
        } else if (state is RedirectVnpayFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi chuyển hướng: ${state.message}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocListener<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is PaymentInvoiceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            if (widget.isFromUser) {
              context.go(RouteName.main);
            } else {
              context.go(RouteName.doctorMain);
            }
          } else if (state is PaymentInvoiceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán thất bại: ${state.message}'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              'Chi tiết hóa đơn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColor.white,
              ),
            ),
            backgroundColor: TColor.primary,
            foregroundColor: TColor.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                context.read<DoctorAppointmentBloc>().add(
                  DoctorAppointmentGetStarted(
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                );
                context.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceHeader(),
                SizedBox(height: 16),
                _buildCustomerInfo(),
                SizedBox(height: 16),
                _buildDoctorInfo(),
                SizedBox(height: 16),
                _buildServicesSection(),
                SizedBox(height: 16),
                _buildMedicationsSection(),
                SizedBox(height: 16),
                _buildTotalSection(),
                SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HÓA ĐƠN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    widget.invoice.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(widget.invoice.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(widget.invoice.status),
                  style: TextStyle(
                    color: _getStatusColor(widget.invoice.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.receipt_long, color: TColor.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Mã hóa đơn: ',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                widget.invoice.invoiceCode,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, color: TColor.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Ngày tạo: ',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(
                _formatDate(widget.invoice.createdAt),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: TColor.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            'Họ tên',
            widget.invoice.user.fullname ?? 'Chưa cập nhật',
          ),
          _buildInfoRow('Số điện thoại', widget.invoice.user.phoneNumber),
          _buildInfoRow(
            'Địa chỉ',
            widget.invoice.user.address ?? 'Chưa cập nhật',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: TColor.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Bác sĩ điều trị',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            'Họ tên',
            widget.invoice.doctor.fullname ?? 'Chưa cập nhật',
          ),
          _buildInfoRow('Số điện thoại', widget.invoice.doctor.phoneNumber),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    if (widget.invoice.services.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_information, color: TColor.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Dịch vụ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.invoice.services.map(
            (service) => _buildServiceItem(service),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(service) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              service.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _formatCurrency(service.price),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColor.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection() {
    if (widget.invoice.prescriptionDetail.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication, color: TColor.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Thuốc điều trị',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.invoice.prescriptionDetail.map(
            (medication) => _buildMedicationItem(medication),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(medication) {
    final totalPrice = medication.medication.price * medication.quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  medication.medication.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Liều dùng: ${medication.dosage}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            'Số lượng: ${medication.quantity} ${medication.medication.unit}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            'Đơn giá: ${_formatCurrency(medication.medication.price)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG TIỀN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
              Text(
                _formatCurrency(widget.invoice.totalAmount),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PdfPreviewScreen(invoice: widget.invoice),
                ),
              );
            },
            icon: Icon(Icons.picture_as_pdf),
            label: Text('Xem PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // Only show payment button if status is 0 (unpaid)
        if (widget.invoice.status == 0) ...[
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final ipClient = await getPublicIpAddress();
                if (ipClient == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chuyển hướng thất bại'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }
                final vnPayRequestDto = VnPayRequestDto(
                  vnpOrderInfo:
                      "Thanh toan hoa don ${widget.invoice.invoiceCode}",
                  invoiceCode: widget.invoice.invoiceCode,
                  price: widget.invoice.totalAmount,
                  ipClient: ipClient!,
                );
                context.read<RedirectVnpayBloc>().add(
                  RedirectVnpayStarted(vnPayRequestDto),
                );
              },
              icon: Icon(Icons.payment),
              label: Text('Thanh toán'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: TColor.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<String?> getPublicIpAddress() async {
    try {
      final response = await dio.get('https://api.ipify.org');
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy IP: $e');
      return null;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
