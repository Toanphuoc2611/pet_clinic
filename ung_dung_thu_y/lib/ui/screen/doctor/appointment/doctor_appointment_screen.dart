import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() =>
      _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  final WebSocketService _webSocketService = WebSocketService.instance;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _webSocketService.addAppointmentListener(_refreshAppointments);
  }

  void _refreshAppointments() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.read<DoctorAppointmentBloc>().add(
        DoctorAppointmentGetStarted(
          DateFormat('yyyy-MM-dd').format(_selectedDate),
        ),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    WebSocketService.instance.removeAppointmentListener(_refreshAppointments);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quản lý lịch hẹn',
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push(RouteName.doctorCreateAppointment);
            },
            icon: Icon(Icons.add, color: TColor.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateSelector(),
          Expanded(
            child: BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
              builder: (context, state) {
                print(
                  "DoctorAppointmentScreen BlocBuilder: State changed to ${state.runtimeType}",
                );
                if (state is DoctorAppointmentGetTodaySuccess) {
                  print(
                    "DoctorAppointmentScreen: Received ${state.appointments.length} appointments",
                  );
                }
                if (state is DoctorAppointmentGetTodayInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DoctorAppointmentGetTodaySuccess) {
                  if (state.appointments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có lịch hẹn nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildTodayAppointments(state.appointments);
                } else if (state is DoctorAppointmentGetTodayFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Có lỗi xảy ra khi tải dữ liệu',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DoctorAppointmentBloc>().add(
                              DoctorAppointmentGetStarted(
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                              ),
                            );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    print("_buildDateSelector: Current _selectedDate = $_selectedDate");
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(_selectedDate),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = _selectedDate.add(Duration(days: index - 3));
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    // Trigger new appointment fetch for selected date
                    context.read<DoctorAppointmentBloc>().add(
                      DoctorAppointmentGetStarted(
                        DateFormat('yyyy-MM-dd').format(date),
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? TColor.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isToday && !isSelected
                              ? Border.all(color: TColor.primary, width: 2)
                              : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'vi_VN').format(date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.white : TColor.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments(List<AppointmentGetDto> appointments) {
    // Sort appointments by status and then by appointment time
    appointments.sort((a, b) {
      int statusComparison = (a.status ?? 0).compareTo(b.status ?? 0);
      if (statusComparison != 0) {
        return statusComparison;
      }
      DateTime aTime = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).parse(FormatDate.formatAppointmentDateTime(a.appointmentTime));
      DateTime bTime = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).parse(FormatDate.formatAppointmentDateTime(b.appointmentTime));

      return aTime.compareTo(bTime);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];

        final time = FormatDate.formatAppointmentDateTime(
          appointment.appointmentTime,
        );
        DateFormat format = DateFormat('dd/MM/yyyy HH:mm');
        DateTime parsedTime = format.parse(time);

        DateTime now = DateTime.now();

        bool isSameDay =
            parsedTime.year == now.year &&
            parsedTime.month == now.month &&
            parsedTime.day == now.day;
        final isFirst = index == 0;

        return _buildAppointmentCard(
          time: time ?? '',
          userName: appointment.user.fullname ?? 'Không có tên',
          userAvatar: appointment.avatar,
          services: appointment.services ?? [],
          status: appointment.status ?? 0,
          isNext: isFirst && isSameDay,
          showStartExamination:
              (appointment.status == 1 || appointment.status == 10) &&
              isSameDay,
          appointment: appointment,
        );
      },
    );
  }

  Widget _buildAppointmentCard({
    required String time,
    required String userName,
    String? userAvatar,
    required List<ServicesGetDto> services,
    required int status,
    bool isNext = false,
    bool showStartExamination = false,
    required AppointmentGetDto appointment,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 1:
        statusColor = TColor.appointmentStatusAccessedColor;
        statusText = 'Đã xác nhận';
        break;
      case 2:
        statusColor = TColor.appointmentStatusCompletedColor;
        statusText = 'Hoàn thành';
        break;
      case 3:
        statusColor = TColor.appointmentStatusCanceledColor;
        statusText = 'Đã hủy';
        break;
      case 10:
        statusColor = Colors.purple;
        statusText = 'Hẹn tái khám';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isNext ? Border.all(color: TColor.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    userAvatar != null && userAvatar!.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            userAvatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 20,
                              );
                            },
                          ),
                        )
                        : Icon(Icons.person, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Khách hàng',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Services detail section
          if (services.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 16,
                        color: TColor.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Dịch vụ đã đặt:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TColor.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...services
                      .map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: TColor.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service.name ?? 'Dịch vụ không xác định',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###').format(service.price)} VNĐ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  if (services.length > 1) ...[
                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${NumberFormat('#,###').format(services.fold<int>(0, (sum, service) => sum + service.price))} VNĐ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          if (showStartExamination) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    RouteName.doctorPrescription,
                    extra: appointment,
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Bắt đầu khám'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
