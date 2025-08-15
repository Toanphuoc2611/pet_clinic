import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_detail_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/alert_dialog.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';

class DoctorKennelDetailScreen extends StatefulWidget {
  late KennelDetailDto kennelDetailDto;
  DoctorKennelDetailScreen({super.key, required this.kennelDetailDto});

  @override
  State<DoctorKennelDetailScreen> createState() =>
      _DoctorKennelDetailScreenState();
}

class _DoctorKennelDetailScreenState extends State<DoctorKennelDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Chi tiết lưu chuồng",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryText),
      ),
      body: BlocProvider(
        create:
            (context) => DoctorKennelDetailBloc(
              KennelDetailRepository(
                context.read<AuthRepository>(),
                KennelDetailApiClient(ApiService(dio)),
              ),
            ),
        child: BlocListener<DoctorKennelDetailBloc, DoctorKennelDetailState>(
          listener: (context, state) {
            if (state is DoctorKennelDetailUpdateSuccess) {
              showDialog(
                context: context,
                builder: (_) {
                  return MyAlertDialog(
                    title: "Cập nhật thành công",
                    message: "",
                    onPress: () {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                      setState(() {
                        widget.kennelDetailDto = state.kennel;
                      });
                    },
                  );
                },
              );
            } else if (state is DoctorKennelDetailUpdateFailure) {
              showDialog(
                context: context,
                builder: (_) {
                  return MyAlertDialog(
                    title: "Cập nhật thất bại",
                    message: state.message,
                    onPress: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            } else if (state is DoctorKennelDetailCompleteBookingSuccess) {
              // Navigate to invoice kennel detail screen
              context.push(
                RouteName.doctorInvoiceKennelDetail,
                extra: state.invoiceKennelDto,
              );
            } else if (state is DoctorKennelDetailCompleteBookingFailure) {
              showDialog(
                context: context,
                builder: (_) {
                  return MyAlertDialog(
                    title: "Xuất chuồng thất bại",
                    message: state.message,
                    onPress: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Pet Information Card
                _buildPetInfoCard(),
                const SizedBox(height: 16),

                // Kennel Information Card
                _buildKennelInfoCard(),
                const SizedBox(height: 16),

                // User Information Card
                _buildUserInfoCard(),
                const SizedBox(height: 16),

                // Time Information Card
                _buildTimeInfoCard(),
                const SizedBox(height: 16),

                // Note Card (if exists)
                if (widget.kennelDetailDto.note != null &&
                    widget.kennelDetailDto.note!.isNotEmpty) ...[
                  _buildNoteCard(),
                  const SizedBox(height: 16),
                ],

                // Deposit Information Card
                _buildDepositInfoCard(),
                const SizedBox(height: 24),

                // Action Button
                _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Mã đặt: #${widget.kennelDetailDto.id}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(widget.kennelDetailDto.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Ngày tạo: ${_formatDateTime(widget.kennelDetailDto.createdAt)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoCard() {
    final pet = widget.kennelDetailDto.pet;
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
                          fontSize: 18,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              pet.gender == 0
                                  ? Colors.pink.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                pet.gender == 0
                                    ? Colors.pink.withOpacity(0.3)
                                    : Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pet.weight > 0) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.monitor_weight_outlined,
                "Cân nặng",
                "${pet.weight} kg",
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKennelInfoCard() {
    final kennel = widget.kennelDetailDto.kennel;
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
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.attach_money_outlined,
              "Hệ số giá",
              "x${kennel.priceMultiplier}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    final user = widget.kennelDetailDto.pet.owner;
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
              user?.fullname?.isEmpty == true
                  ? "Chưa cập nhật"
                  : user?.fullname ?? "Chưa cập nhật",
            ),
            if (user!.phoneNumber.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.phone_outlined,
                "Số điện thoại",
                user.phoneNumber,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoCard() {
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
                Icon(Icons.schedule_outlined, color: TColor.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin thời gian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.schedule,
              "Ngày vào dự kiến",
              _formatDateOnly(widget.kennelDetailDto.inTime),
              color: Colors.blue[700],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.schedule,
              "Ngày ra dự kiến",
              _formatDateOnly(widget.kennelDetailDto.outTime),
              color: Colors.blue[700],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.login,
              "Thời gian vào thực tế",
              widget.kennelDetailDto.actualCheckin != null
                  ? _formatDateTime(widget.kennelDetailDto.actualCheckin!)
                  : "Chưa có",
              color:
                  widget.kennelDetailDto.actualCheckin != null
                      ? Colors.green[700]
                      : Colors.orange[700],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.logout,
              "Thời gian ra thực tế",
              widget.kennelDetailDto.actualCheckout != null
                  ? _formatDateTime(widget.kennelDetailDto.actualCheckout!)
                  : "Chưa có",
              color:
                  widget.kennelDetailDto.actualCheckout != null
                      ? Colors.red[700]
                      : Colors.orange[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard() {
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
                Icon(Icons.note_outlined, color: TColor.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Ghi chú",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                widget.kennelDetailDto.note!,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositInfoCard() {
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
                  Icons.attach_money_outlined,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin thanh toán",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.money_outlined,
              "Tiền cọc",
              "${NumberFormat('#,###').format(widget.kennelDetailDto.invoiceDepositDto.deposit)} VNĐ",
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.receipt_outlined,
              "Tổng tiền",
              "${NumberFormat('#,###').format(widget.kennelDetailDto.invoiceDepositDto.totalAmount)} VNĐ",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.kennelDetailDto.status != 1 &&
        widget.kennelDetailDto.status != 2) {
      return const SizedBox.shrink();
    }

    String buttonText;
    Color buttonColor;

    if (widget.kennelDetailDto.status == 1) {
      buttonText = "Xác nhận nhập chuồng";
      buttonColor = Colors.green;
    } else {
      buttonText = "Xác nhận xuất chuồng";
      buttonColor = Colors.red;
    }

    return BlocBuilder<DoctorKennelDetailBloc, DoctorKennelDetailState>(
      builder: (context, state) {
        bool isLoading = state is DoctorKennelDetailUpdateStartedInProgress;

        VoidCallback? onPressed;
        if (!isLoading) {
          if (widget.kennelDetailDto.status == 1) {
            onPressed = () => _confirmCheckin(context);
          } else {
            onPressed = () => _confirmCheckout(context);
          }
        }

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
          ),
        );
      },
    );
  }

  void _confirmCheckin(BuildContext context) {
    // Capture the bloc reference before showing the dialog
    final bloc = context.read<DoctorKennelDetailBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận nhập chuồng"),
          content: const Text(
            "Bạn có chắc chắn muốn xác nhận thú cưng đã nhập chuồng?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                bloc.add(
                  DoctorKennelDetailUpdateStatusStarted(
                    "${widget.kennelDetailDto.id}",
                    "2",
                  ),
                );
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                "Xác nhận",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmCheckout(BuildContext context) {
    // Capture the bloc reference before showing the dialog
    final bloc = context.read<DoctorKennelDetailBloc>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Xác nhận xuất chuồng"),
          content: const Text(
            "Bạn có chắc chắn muốn xác nhận thú cưng đã xuất chuồng?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                bloc.add(
                  DoctorKennelDetailCompleteBooking(
                    "${widget.kennelDetailDto.id}",
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Xác nhận",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(int status) {
    String text;
    Color color;
    switch (status) {
      case 0:
        text = "Chờ xác nhận";
        color = Colors.orange;
        break;
      case 1:
        text = "Đã xác nhận";
        color = Colors.blue;
        break;
      case 2:
        text = "Đang lưu chuồng";
        color = Colors.green;
        break;
      case 3:
        text = "Hoàn thành";
        color = Colors.purple;
        break;
      case 4:
        text = "Đã hủy";
        color = Colors.red;
        break;
      default:
        text = "Không xác định";
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPetAvatar(String? avatar) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(40),
      ),
      child:
          avatar != null && avatar.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  avatar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.pets, color: Colors.grey[600], size: 40);
                  },
                ),
              )
              : Icon(Icons.pets, color: Colors.grey[600], size: 40),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color ?? Colors.black87,
                  ),
                  maxLines: 2,

                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Format chỉ ngày cho thời gian dự kiến
  String _formatDateOnly(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "Chưa cập nhật";
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Format đầy đủ ngày giờ cho thời gian thực tế
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
