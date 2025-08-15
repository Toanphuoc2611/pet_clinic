import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class CardDisplayAppointment extends StatefulWidget {
  const CardDisplayAppointment({super.key, required this.appointmentGetDto});
  final AppointmentGetDto appointmentGetDto;

  @override
  State<CardDisplayAppointment> createState() => _CardDisplayAppointmentState();
}

class _CardDisplayAppointmentState extends State<CardDisplayAppointment> {
  late String time;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          RouteName.appointmentDetail,
          extra: widget.appointmentGetDto.id,
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage.assetNetwork(
                      placeholder: "assets/image/avatar_default.jpg",
                      image:
                          widget.appointmentGetDto.avatar ??
                          "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/image/avatar_default.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "BS. ${widget.appointmentGetDto.fullname ?? 'Không có tên'}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded),
                  Text(
                    formatAppointmentDateTime(
                      widget.appointmentGetDto.appointmentTime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(children: [Icon(Icons.access_time_filled), Text(time)]),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.medical_services, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          widget.appointmentGetDto.services.map((service) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                service.name ?? 'Dịch vụ không xác định',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _buildInvoiceStatus(widget.appointmentGetDto),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceStatus(AppointmentGetDto appointmentGetDto) {
    return displayByStatus(appointmentGetDto.status);
  }

  Color _getTypeColor(int type) {
    return type == 0 ? Colors.purple : Colors.blue;
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return TColor.appointmentStatusWaitingColor;
      case 1:
        return TColor.appointmentStatusAccessedColor;
      case 2:
        return TColor.appointmentStatusCanceledColor;
      case 10:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icon(
          Icons.access_time,
          size: 16,
          color: _getStatusColor(status),
        );
      case 1:
        return Icon(
          Icons.check_circle,
          size: 16,
          color: _getStatusColor(status),
        );
      case 2:
        return Icon(Icons.cancel, size: 16, color: _getStatusColor(status));
      case 10:
        return Icon(Icons.schedule, size: 16, color: _getStatusColor(status));
      default:
        return Icon(Icons.list, size: 16, color: Colors.grey);
    }
  }

  Widget displayByStatus(int status) {
    switch (status) {
      case 0:
        return _displayStatusItem(
          TColor.appointmentStatusWaitingColor,
          Icons.access_time_filled,
          "Chờ thanh toán",
        );
      case 1:
        return _displayStatusItem(
          TColor.appointmentStatusAccessedColor,
          Icons.check_circle,
          "Đã xác nhận",
        );
      case 2:
        return _displayStatusItem(
          TColor.appointmentStatusCompletedColor,
          Icons.done_all_outlined,
          "Hoàn thành",
        );
      case 3:
        return _displayStatusItem(
          TColor.appointmentStatusCanceledColor,
          Icons.cancel,
          "Đã hủy",
        );
      case 10:
        return _displayStatusItem(
          Colors.purple,
          Icons.schedule,
          "Hẹn tái khám",
        );
      default:
        return _displayStatusItem(
          Colors.grey,
          Icons.help_outline,
          "Không xác định",
        );
    }
  }

  Widget _displayStatusItem(Color color, IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String formatAppointmentDateTime(String isoString) {
    final dateTime =
        DateTime.parse(isoString).toLocal(); // Change to local time

    final weekday = DateFormat.EEEE('vi').format(dateTime); // format to Thứ
    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(dateTime); // format to dd/MM/yyyy
    final timeStart = DateFormat('HH:mm').format(dateTime); // Time start

    final timeEnd = DateFormat(
      'HH:mm',
    ).format(dateTime.add(const Duration(minutes: 60))); // Time end (1 hour)
    time = '$timeStart - $timeEnd';
    return '$weekday, $date';
  }
}
