import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_state.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/alert_dialog.dart';
import 'package:ung_dung_thu_y/utils/datetime_utils.dart';

class KennelDetailScreen extends StatefulWidget {
  late KennelDetailDto kennelDetailDto;
  KennelDetailScreen({super.key, required this.kennelDetailDto});

  @override
  State<KennelDetailScreen> createState() => _KennelDetailScreenState();
}

class _KennelDetailScreenState extends State<KennelDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Chi tiết đặt chuồng",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: TColor.primaryText),
      ),
      body: BlocListener<KennelDetailBloc, KennelDetailState>(
        listener: (context, state) {
          if (state is KennelDetailCancelSuccess) {
            showDialog(
              context: context,
              builder: (_) {
                return MyAlertDialog(
                  title: "Hủy đặt chuồng thành công",
                  message: "",
                  onPress: () {
                    Navigator.pop(context, true);
                    setState(() {
                      widget.kennelDetailDto = state.kennelDetailDto;
                    });
                  },
                );
              },
            );
          } else if (state is KennelDetailCancelFailure) {
            showDialog(
              context: context,
              builder: (_) {
                return MyAlertDialog(
                  title: "Hủy đặt chuồng thất bại",
                  message: "Vui lòng thử lại sau",
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

              // Doctor Information Card
              _buildDoctorInfoCard(),
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

              // Deposit Information Card (only for status 0 and 1)
              if (widget.kennelDetailDto.status == 0 ||
                  widget.kennelDetailDto.status == 1) ...[
                _buildDepositInfoCard(),
                const SizedBox(height: 24),
              ],

              // Cancel button (only for status 1 - confirmed)
              if (widget.kennelDetailDto.status == 1) ...[_buildCancelButton()],
            ],
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

  Widget _buildDoctorInfoCard() {
    final doctor = widget.kennelDetailDto.doctor;
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
              Icons.login_outlined,
              "Giờ vào dự kiến",
              _formatDateTime(widget.kennelDetailDto.inTime),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.logout_outlined,
              "Giờ ra dự kiến",
              _formatDateTime(widget.kennelDetailDto.outTime),
            ),
            if (widget.kennelDetailDto.actualCheckin != null &&
                widget.kennelDetailDto.actualCheckin!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.login,
                "Giờ vào thực tế",
                _formatDateTime(widget.kennelDetailDto.actualCheckin),
              ),
            ],
            if (widget.kennelDetailDto.actualCheckout != null &&
                widget.kennelDetailDto.actualCheckout!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.logout,
                "Giờ ra thực tế",
                _formatDateTime(widget.kennelDetailDto.actualCheckout),
              ),
            ],
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
                border: Border.all(color: Colors.grey[200]!),
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
    final bool isWithin24Hours = _isCancellationWithin24Hours();

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
                  Icons.account_balance_wallet_outlined,
                  color: TColor.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Thông tin đặt cọc",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.attach_money_outlined,
              "Số tiền đặt cọc",
              '${widget.kennelDetailDto.invoiceDepositDto.deposit ~/ 1000} K',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isWithin24Hours ? Colors.orange[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isWithin24Hours ? Colors.orange[200]! : Colors.blue[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isWithin24Hours
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline,
                        color:
                            isWithin24Hours
                                ? Colors.orange[600]
                                : Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Chính sách hủy đặt",
                        style: TextStyle(
                          color:
                              isWithin24Hours
                                  ? Colors.orange[800]
                                  : Colors.blue[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• Hủy trước 24h: Hoàn lại 100% tiền cọc\n• Hủy trong vòng 24h: Mất toàn bộ tiền cọc",
                    style: TextStyle(
                      color:
                          isWithin24Hours
                              ? Colors.orange[700]
                              : Colors.blue[700],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    final bool isWithin24Hours = _isCancellationWithin24Hours();

    return BlocBuilder<KennelDetailBloc, KennelDetailState>(
      builder: (context, state) {
        final isLoading = state is KennelDetailCancelInProgress;

        return Column(
          children: [
            // Warning message if within 24 hours
            if (isWithin24Hours) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cảnh báo về tiền cọc",
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Hủy trong vòng 24h trước giờ vào sẽ mất tiền đặt cọc",
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Cancel button
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _showCancelConfirmDialog,
                icon:
                    isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(
                          isWithin24Hours
                              ? Icons.warning_outlined
                              : Icons.cancel_outlined,
                        ),
                label: Text(
                  isLoading
                      ? "Đang hủy..."
                      : isWithin24Hours
                      ? "Hủy đặt (mất cọc)"
                      : "Hủy đặt chuồng",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isWithin24Hours ? Colors.orange[600] : Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(int status) {
    String statusText;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 0:
        statusText = "Chờ xác nhận";
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case 1:
        statusText = "Đã xác nhận";
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case 2:
        statusText = "Đang lưu chuồng";
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case 3:
        statusText = "Hoàn thành";
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 4:
        statusText = "Đã hủy";
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        statusText = "Không xác định";
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: TColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: TColor.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetAvatar(String? avatarUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: FadeInImage.assetNetwork(
        placeholder: "assets/image/pet_default.jpg",
        image:
            avatarUrl ??
            "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678351/pet_default_vg54u5.jpg",
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, _) {
          return Image.asset(
            "assets/image/pet_default.jpg",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    return DateTimeUtils.formatDateTime(dateTimeString);
  }

  void _showCancelConfirmDialog() {
    final bool isWithin24Hours = _isCancellationWithin24Hours();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isWithin24Hours
                    ? Icons.warning_amber_rounded
                    : Icons.info_outline,
                color: isWithin24Hours ? Colors.orange[600] : TColor.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                "Xác nhận hủy",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bạn có chắc chắn muốn hủy đặt chuồng này không?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (isWithin24Hours) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Hủy trong vòng 24h trước giờ vào sẽ mất tiền đặt cọc",
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                "Hành động này không thể hoàn tác.",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Không", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleBtnCancelBooking();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isWithin24Hours ? "Hủy và mất cọc" : "Hủy đặt"),
            ),
          ],
        );
      },
    );
  }

  bool _isCancellationWithin24Hours() {
    try {
      if (widget.kennelDetailDto.inTime == null ||
          widget.kennelDetailDto.inTime!.isEmpty) {
        return false;
      }

      DateTime inTime = DateTime.parse(widget.kennelDetailDto.inTime!);
      DateTime now = DateTime.now();

      // Calculate the difference between now and the check-in time
      Duration difference = inTime.difference(now);

      // If the check-in time is within 24 hours (1440 minutes)
      return difference.inHours <= 24 && difference.inHours >= 0;
    } catch (e) {
      // If there's an error parsing the date, assume it's not within 24 hours
      return false;
    }
  }

  void _handleBtnCancelBooking() {
    context.read<KennelDetailBloc>().add(
      KennelDetailCancelStarted(widget.kennelDetailDto.id.toString()),
    );
  }
}
