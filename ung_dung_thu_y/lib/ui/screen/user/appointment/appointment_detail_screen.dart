import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/detail/appointment_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/detail/appointment_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/appointment/detail/appointment_detail_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/appointment/appointment_api_client.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/button_back_screen.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/card_display_user.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_app_bar.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final int appointmentId;
  final String address =
      "Phòng khám đa khoa ABC, 123 Đường XYZ, Quận 1, TP.HCM";
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text("Đặt lịch khám"),
        leading: ButtonBackScreen(onPress: backScreen),
      ),
      body: RepositoryProvider(
        create:
            (context) => AppointmentRepository(
              AppointmentApiClient(ApiService(dio)),
              context.read<AuthRepository>(),
            ),
        child: BlocProvider(
          create:
              (context) =>
                  AppointmentDetailBloc(context.read<AppointmentRepository>())
                    ..add(AppointmentDetailGetStarted(widget.appointmentId)),
          child: BlocListener<AppointmentDetailBloc, AppointmentDetailState>(
            listener: (context, state) {
              if (state is AppointmentDetailUpdateSuccess) {
                if (state.isSuccess) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Cập nhật lịch khám thành công!"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<AppointmentDetailBloc>().add(
                                AppointmentDetailGetStarted(
                                  widget.appointmentId,
                                ),
                              );
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              }
            },
            child: BlocBuilder<AppointmentDetailBloc, AppointmentDetailState>(
              builder: (context, state) {
                return (switch (state) {
                  AppointmentDetailGetInitial() => Center(
                    child: CircularProgressIndicator(),
                  ),
                  AppointmentDetailGetInProgress() => Center(
                    child: CircularProgressIndicator(),
                  ),
                  AppointmentDetailGetSuccess() => displayAppointmentDetail(
                    state.appointmentGetDto,
                    context,
                  ),
                  AppointmentDetailGetFailure() => Center(
                    child: Text(state.message),
                  ),
                  AppointmentDetailUpdateInProgress() => Center(
                    child: CircularProgressIndicator(),
                  ),
                  AppointmentDetailUpdateFailure() => Center(
                    child: Text(state.message),
                  ),
                  _ => Container(),
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget displayAppointmentDetail(
    AppointmentGetDto appointmentGetDto,
    BuildContext context,
  ) {
    // Replace with your widget to display appointment details
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardDisplayUser(
                    fullName: "BS. ${appointmentGetDto.fullname}",
                    avatar: appointmentGetDto.avatar,
                    phoneNumber: appointmentGetDto.phoneNumberDoctor,
                    pressed: () {},
                  ),
                  SizedBox(height: 10),
                  _displayCardTimeAppointment(
                    appointmentGetDto.appointmentTime,
                    widget.address,
                  ),
                  SizedBox(height: 10),
                  _displayCardServices(appointmentGetDto.services),
                  SizedBox(height: 10),
                  _displayCardStatus(appointmentGetDto.status),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        // Bottom buttons container
        if (appointmentGetDto.status == 1)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundButton(
                  title: "Huỷ lịch khám",
                  onPressed: () {
                    _showCancelConfirmationDialog(appointmentGetDto.id);
                  },
                  bgColor: TColor.appointmentStatusCanceledColor,
                  textColor: Colors.white,
                ),
                SizedBox(height: 12),
                RoundButton(
                  title: "Liên hệ bác sĩ",
                  onPressed: () async {
                    try {
                      await makePhoneCall(appointmentGetDto.phoneNumberDoctor);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Không thể thực hiện cuộc gọi: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  },
                  bgColor: Colors.blue,
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Function to make a phone call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  // Function to handle back navigation
  void backScreen() {
    Navigator.pop(context);
  }

  // Card to display appointment time and address
  Widget _displayCardTimeAppointment(String appointmentTime, String address) {
    // handle the appointmentTime to date and time
    final dateTime =
        DateTime.parse(appointmentTime).toLocal(); // Change to local time

    final weekday = DateFormat.EEEE('vi').format(dateTime); // format to Thứ
    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(dateTime); // format to dd/MM/yyyy
    final timeStart = DateFormat('HH:mm').format(dateTime); // Time start

    final timeEnd = DateFormat(
      'HH:mm',
    ).format(dateTime.add(const Duration(minutes: 60))); // Time end (1 hour)
    final formattedDate = '$weekday, $date';
    final formattedTime = '$timeStart - $timeEnd';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _displayDetailCardTimeAppointment(
              Icon(Icons.calendar_month_outlined, size: 30, color: Colors.blue),
              "Ngày khám",
              formattedDate,
            ),
            SizedBox(height: 10),
            _displayDetailCardTimeAppointment(
              Icon(
                Icons.access_time_filled_rounded,
                size: 30,
                color: Colors.blue,
              ),
              "Giờ khám",
              formattedTime,
            ),
            SizedBox(height: 10),
            _displayDetailCardTimeAppointment(
              Icon(Icons.location_on_sharp, size: 30, color: Colors.blue),
              "Địa chỉ",
              address,
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display information about appointment time
  Widget _displayDetailCardTimeAppointment(
    Icon icon,
    String title,
    String content,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                content,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card to display services of the appointment
  Widget _displayCardServices(List<ServicesGetDto> services) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "Dịch vụ khám",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...services.map((service) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  service.name,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Card to display status of the appointment
  Widget _displayCardStatus(int status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case 0:
        statusText = "Đang chờ";
        statusColor = TColor.appointmentStatusWaitingColor;
        break;
      case 1:
        statusText = "Đã tiếp nhận";
        statusColor = TColor.appointmentStatusAccessedColor;
        break;
      case 2:
        statusText = "Hoàn thành";
        statusColor = TColor.appointmentStatusCompletedColor;
        break;
      case 3:
        statusText = "Đã hủy";
        statusColor = TColor.appointmentStatusCanceledColor;
        break;
      case 10:
        statusText = "Hẹn tái khám";
        statusColor = Colors.purple;
        break;
      default:
        statusText = "Không xác định";
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: statusColor.withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: Column(
          children: [
            Text(
              "Trạng thái lịch khám",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to show cancel confirmation dialog
  void _showCancelConfirmationDialog(int appointmentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                "Xác nhận hủy lịch",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bạn có chắc chắn muốn hủy lịch khám này không?",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
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
                        "Lịch khám bị hủy trong vòng 24 giờ trước thời gian hẹn sẽ không được hoàn tiền",
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
                context.read<AppointmentDetailBloc>().add(
                  AppointmentDetailUpdateStarted(appointmentId),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Hủy lịch"),
            ),
          ],
        );
      },
    );
  }
}
