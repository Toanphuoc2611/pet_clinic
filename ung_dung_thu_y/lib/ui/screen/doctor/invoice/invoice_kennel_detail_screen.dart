import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_state.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_bloc.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_event.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/invoice/kennel_pdf_preview_screen.dart';

class InvoiceKennelDetailScreen extends StatefulWidget {
  final InvoiceKennelDto invoiceKennelDto;
  const InvoiceKennelDetailScreen({super.key, required this.invoiceKennelDto});

  @override
  State<InvoiceKennelDetailScreen> createState() =>
      _InvoiceKennelDetailScreenState();
}

class _InvoiceKennelDetailScreenState extends State<InvoiceKennelDetailScreen> {
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
              'invoiceCode': widget.invoiceKennelDto.invoiceCode,
            },
          );

          if (result == true) {
            context.read<InvoiceBloc>().add(
              PaymentInvoiceKennel(widget.invoiceKennelDto.id),
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
          if (state is PaymentInvoiceKennelSuccess) {
            // Hiển thị thông báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Thanh toán thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            context.push(RouteName.doctorKennel);
          } else if (state is PaymentInvoiceKennelFailure) {
            // Hiển thị thông báo lỗi
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
              "Hóa đơn lưu chuồng",
              style: TextStyle(
                color: TColor.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: TColor.primaryText),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                context.read<DoctorKennelDetailBloc>().add(
                  DoctorKennelDetailGetStarted(),
                );
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(RouteName.doctorKennel),
                );
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice Header Card
                _buildInvoiceHeader(),
                const SizedBox(height: 16),

                // Customer Information Card
                _buildCustomerInfoCard(),
                const SizedBox(height: 16),

                // Doctor Information Card
                _buildDoctorInfoCard(),
                const SizedBox(height: 16),

                // Pet Information Card
                _buildPetInfoCard(),
                const SizedBox(height: 16),

                // Kennel Information Card
                _buildKennelInfoCard(),
                const SizedBox(height: 16),

                // Service Details Card
                _buildServiceDetailsCard(),
                const SizedBox(height: 16),
                // Total payment
                _buildTotalSection(),
                const SizedBox(height: 16),
                // Payment Button
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
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
                _formatCurrency(widget.invoiceKennelDto.totalAmount),
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

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
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
                      (context) => KennelPdfPreviewScreen(
                        invoice: widget.invoiceKennelDto,
                      ),
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
        if (widget.invoiceKennelDto.status == 0) ...[
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
                      "Thanh toan hoa don ${widget.invoiceKennelDto.invoiceCode}",
                  invoiceCode: widget.invoiceKennelDto.invoiceCode,
                  price: widget.invoiceKennelDto.totalAmount,
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
                foregroundColor: Colors.white,
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
                    widget.invoiceKennelDto.status,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(widget.invoiceKennelDto.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(widget.invoiceKennelDto.status),
                  style: TextStyle(
                    color: _getStatusColor(widget.invoiceKennelDto.status),
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
                widget.invoiceKennelDto.invoiceCode,
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
                _formatDate(widget.invoiceKennelDto.createdAt),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
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

  Widget _buildCustomerInfoCard() {
    final customer = widget.invoiceKennelDto.user;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: TColor.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin khách hàng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              "Họ tên",
              customer.fullname?.isEmpty == true
                  ? "Chưa cập nhật"
                  : customer.fullname ?? "Chưa cập nhật",
            ),
            if (customer.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone_outlined,
                "Số điện thoại",
                customer.phoneNumber,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    final doctor = widget.invoiceKennelDto.doctor;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Bác sĩ phụ trách",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              "Họ tên",
              doctor.fullname?.isEmpty == true
                  ? "Chưa cập nhật"
                  : doctor.fullname ?? "Chưa cập nhật",
            ),
            if (doctor.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone_outlined,
                "Số điện thoại",
                doctor.phoneNumber,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoCard() {
    final pet = widget.invoiceKennelDto.kennelDetail.pet;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: TColor.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin thú cưng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPetAvatar(pet.avatar),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name.isEmpty ? "Chưa cập nhật" : pet.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.breed?.isEmpty == true
                            ? "Chưa cập nhật"
                            : pet.breed ?? "Chưa cập nhật",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.gender == 0 ? "Cái" : "Đực",
                        style: TextStyle(
                          color:
                              pet.gender == 0
                                  ? Colors.pink[700]
                                  : Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKennelInfoCard() {
    final kennel = widget.invoiceKennelDto.kennelDetail.kennel;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_outlined, color: TColor.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin chuồng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.home,
              "Tên chuồng",
              kennel.name.isEmpty ? "Chưa cập nhật" : kennel.name,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category_outlined,
              "Loại chuồng",
              kennel.type == "NORMAL"
                  ? "Bình thường"
                  : kennel.type == "SPECIAL"
                  ? "Đặc biệt"
                  : "Chưa cập nhật",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    final kennelDetail = widget.invoiceKennelDto.kennelDetail;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Chi tiết dịch vụ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.schedule,
              "Thời gian vào",
              _formatDateTime(kennelDetail.inTime),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule,
              "Thời gian ra",
              _formatDateTime(kennelDetail.outTime),
            ),
            if (kennelDetail.actualCheckin != null &&
                kennelDetail.actualCheckin!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.login,
                "Vào thực tế",
                _formatDateTime(kennelDetail.actualCheckin),
              ),
            ],
            if (kennelDetail.actualCheckout != null &&
                kennelDetail.actualCheckout!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.logout,
                "Ra thực tế",
                _formatDateTime(kennelDetail.actualCheckout),
              ),
            ],
            if (kennelDetail.note != null && kennelDetail.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ghi chú:",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kennelDetail.note!,
                      style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetAvatar(String? avatar) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child:
          avatar != null && avatar.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  avatar,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.pets, color: Colors.grey[600], size: 30);
                  },
                ),
              )
              : Icon(Icons.pets, color: Colors.grey[600], size: 30),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
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

  String _formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Chưa cập nhật";
    try {
      DateTime dateTime = DateTime.parse(dateString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
