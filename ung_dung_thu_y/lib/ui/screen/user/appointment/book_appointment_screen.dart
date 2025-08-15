import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_state.dart';
import 'package:ung_dung_thu_y/bloc/service/service_bloc.dart';
import 'package:ung_dung_thu_y/bloc/service/service_event.dart';
import 'package:ung_dung_thu_y/bloc/service/service_state.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_event.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_state.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_creation.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  List<ServicesGetDto> selectedServices = <ServicesGetDto>[];
  UserGetDto? doctorSelected;
  List<UserGetDto> doctors = <UserGetDto>[];
  List<String> bookedTimesString = <String>[];
  DateTime selectedDate = DateTime.now();
  DateTime? selectedTime;
  int currentStep = 0;
  final WebSocketService _webSocketService = WebSocketService.instance;
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(ServiceGetStarted());
    _webSocketService.addAppointmentListener(_refreshSchedule);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _webSocketService.removeAppointmentListener(_refreshSchedule);
    super.dispose();
  }

  void _refreshSchedule() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (doctorSelected != null) {
        context.read<AppointmentBloc>().add(
          GetScheduleByDoctorStarted(doctorSelected!.id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Đặt lịch khám',
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
      ),
      body: BlocListener<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentCreationSuccess) {
            _showSuccessDialog();
          } else if (state is AppointmentFailure) {
            _showErrorDialog(state.message);
          } else if (state is GetScheduleByDoctorSuccess) {
            print(
              "Main BlocListener - GetScheduleByDoctorSuccess: ${state.schedules}",
            );
            setState(() {
              bookedTimesString = state.schedules;
            });
            print(
              "Main BlocListener - bookedTimesString updated: $bookedTimesString",
            );
          }
        },
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: BlocBuilder<AppointmentBloc, AppointmentState>(
                builder: (context, state) {
                  if (state is AppointmentCreationInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildContent();
                },
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepItem(0, 'Chọn bác sĩ', Icons.person_outline),
          _buildStepConnector(0),
          _buildStepItem(1, 'Chọn dịch vụ', Icons.medical_services_outlined),
          _buildStepConnector(1),
          _buildStepItem(2, 'Chọn thời gian', Icons.schedule_outlined),
          _buildStepConnector(2),
          _buildStepItem(3, 'Xác nhận', Icons.check_circle_outline),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isActive = currentStep >= step;
    final isCompleted = currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isCompleted
                      ? Colors.green
                      : isActive
                      ? TColor.primary
                      : Colors.grey[300],
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive || isCompleted ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? TColor.primary : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = currentStep > step;

    return Container(
      width: 20,
      height: 2,
      color: isCompleted ? Colors.green : Colors.grey[300],
    );
  }

  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildDoctorSelection(),
        _buildServiceSelection(),
        _buildTimeSelection(),
        _buildConfirmation(),
      ],
    );
  }

  Widget _buildDoctorSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn bác sĩ khám',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng chọn bác sĩ phù hợp cho thú cưng của bạn',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocProvider(
              create:
                  (context) =>
                      DoctorListBloc(context.read<UserRepository>())
                        ..add(DoctorListGetStarted()),
              child: BlocBuilder<DoctorListBloc, DoctorListState>(
                builder: (context, state) {
                  return switch (state) {
                    DoctorListGetInProgress() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    DoctorListGetSuccess() => _buildDoctorList(state.doctors),
                    DoctorListGetFailure() => _buildErrorState(state.message),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<UserGetDto> doctors) {
    this.doctors = doctors;

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final isSelected = doctorSelected?.id == doctor.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? TColor.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: TColor.primary.withOpacity(0.1),
              backgroundImage:
                  doctor.avatar != null ? NetworkImage(doctor.avatar!) : null,
              child:
                  doctor.avatar == null
                      ? Icon(Icons.person, color: TColor.primary, size: 30)
                      : null,
            ),
            title: Text(
              'BS. ${doctor.fullname ?? "Không có tên"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  doctor.phoneNumber ?? "Không có số điện thoại",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: TColor.primary, size: 24)
                    : Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey[400],
                      size: 24,
                    ),
            onTap: () {
              setState(() {
                doctorSelected = doctor;
              });
              context.read<AppointmentBloc>().add(
                GetScheduleByDoctorStarted(doctor.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildServiceSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn dịch vụ khám',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn các dịch vụ phù hợp cho thú cưng của bạn',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                print("ServiceBloc state: $state");
                return switch (state) {
                  ServiceGetInProgress() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ServiceGetSuccess() => _buildServiceList(state.services),
                  ServiceGetFailure() => _buildErrorState(state.message),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
          if (selectedServices.isNotEmpty) _buildSelectedServices(),
        ],
      ),
    );
  }

  Widget _buildServiceList(List<ServicesGetDto> services) {
    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected =
            selectedServices.isNotEmpty &&
            selectedServices.any((s) => s.id == service.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? TColor.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medical_services_outlined,
                color: TColor.primary,
                size: 24,
              ),
            ),
            title: Text(
              service.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(service.price)} VNĐ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.primary,
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedServices.add(service);
                  } else {
                    selectedServices.removeWhere((s) => s.id == service.id);
                  }
                });
              },
              activeColor: TColor.primary,
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedServices.removeWhere((s) => s.id == service.id);
                } else {
                  selectedServices.add(service);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedServices() {
    if (selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalPrice = selectedServices.fold<int>(
      0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dịch vụ đã chọn (${selectedServices.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TColor.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...selectedServices.map(
            (service) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,###').format(service.price)} VNĐ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${NumberFormat('#,###').format(totalPrice)} VNĐ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn thời gian khám',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn ngày và giờ phù hợp cho lịch khám',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelection(),
                  const SizedBox(height: 24),
                  _buildTimeSlots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ngày khám',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14, // Show 2 weeks
            itemBuilder: (context, index) {
              final date = now.add(Duration(days: index));
              final isSelected = _isSameDate(date, selectedDate);
              final isToday = _isSameDate(date, now);

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                      selectedTime = null; // Reset time when date changes
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? TColor.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isToday && !isSelected
                                ? TColor.primary
                                : isSelected
                                ? TColor.primary
                                : Colors.grey[300]!,
                        width: isToday || isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekdayName(date.weekday),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.white : TColor.primaryText,
                          ),
                        ),
                        Text(
                          'Th${date.month}',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isSelected ? Colors.white70 : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    final availableTimeSlots = List.generate(
      11,
      (index) => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        8 + index, // 8 AM to 6 PM
      ),
    );
    final bookedTimes =
        bookedTimesString
            .map((e) => DateTime.parse(e))
            .where((dt) => _isSameDate(dt, selectedDate))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn giờ khám',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              availableTimeSlots.map((timeSlot) {
                final isBooked = bookedTimes.any(
                  (t) => t.hour == timeSlot.hour,
                );
                final isSelected =
                    selectedTime != null &&
                    selectedTime!.hour == timeSlot.hour &&
                    _isSameDate(selectedTime!, selectedDate);
                final isPast = timeSlot.isBefore(DateTime.now());

                return GestureDetector(
                  onTap:
                      (isBooked || isPast)
                          ? null
                          : () {
                            setState(() {
                              selectedTime = timeSlot;
                            });
                          },
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isBooked || isPast
                              ? Colors.grey[200]
                              : isSelected
                              ? TColor.primary
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? TColor.primary
                                : isBooked || isPast
                                ? Colors.grey[300]!
                                : Colors.grey[400]!,
                      ),
                    ),
                    child: Text(
                      "${timeSlot.hour.toString().padLeft(2, '0')}:00",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isBooked || isPast
                                ? Colors.grey[500]
                                : isSelected
                                ? Colors.white
                                : TColor.primaryText,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem(Colors.grey[200]!, 'Đã đặt'),
            const SizedBox(width: 16),
            _buildLegendItem(TColor.primary, 'Đã chọn'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.white, 'Có thể đặt'),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[400]!),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  bool _isSameDate(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'T2';
      case 2:
        return 'T3';
      case 3:
        return 'T4';
      case 4:
        return 'T5';
      case 5:
        return 'T6';
      case 6:
        return 'T7';
      case 7:
        return 'CN';
      default:
        return '';
    }
  }

  Widget _buildConfirmation() {
    final totalPrice =
        selectedServices.isNotEmpty
            ? selectedServices.fold<int>(
              0,
              (sum, service) => sum + service.price,
            )
            : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xác nhận đặt lịch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng kiểm tra lại thông tin trước khi đặt lịch',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildConfirmationCard(
                    'Bác sĩ khám',
                    Icons.person_outline,
                    doctorSelected != null
                        ? 'BS. ${doctorSelected!.fullname}'
                        : 'Chưa chọn bác sĩ',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationCard(
                    'Dịch vụ (${selectedServices.length})',
                    Icons.medical_services_outlined,
                    selectedServices.isNotEmpty
                        ? selectedServices.length <= 2
                            ? selectedServices.map((s) => s.name).join(', ')
                            : '${selectedServices.take(2).map((s) => s.name).join(', ')} và ${selectedServices.length - 2} dịch vụ khác'
                        : 'Chưa chọn dịch vụ',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationCard(
                    'Thời gian khám',
                    Icons.schedule_outlined,
                    selectedTime != null
                        ? '${DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(selectedDate)} - ${selectedTime!.hour.toString().padLeft(2, '0')}:00'
                        : 'Chưa chọn thời gian',
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: TColor.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng chi phí:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(totalPrice)} VNĐ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: TColor.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cần thanh toán trước 20% (${NumberFormat('#,###').format(totalPrice * 0.2)} VNĐ) để xác nhận lịch hẹn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard(String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColor.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: TColor.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Quay lại',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TColor.primary,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _getNextButtonAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _getNextButtonText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  VoidCallback? _getNextButtonAction() {
    switch (currentStep) {
      case 0:
        return doctorSelected != null ? _nextStep : null;
      case 1:
        return selectedServices.isNotEmpty ? _nextStep : null;
      case 2:
        return selectedTime != null ? _nextStep : null;
      case 3:
        return _handleBookAppointment;
      default:
        return null;
    }
  }

  String _getNextButtonText() {
    switch (currentStep) {
      case 0:
        return 'Tiếp tục';
      case 1:
        return 'Tiếp tục';
      case 2:
        return 'Tiếp tục';
      case 3:
        return 'Đặt lịch khám';
      default:
        return 'Tiếp tục';
    }
  }

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleBookAppointment() {
    print("_handleBookAppointment called");
    print("doctorSelected: $doctorSelected");
    print("selectedServices: $selectedServices");
    print("selectedServices type: ${selectedServices.runtimeType}");
    print("selectedTime: $selectedTime");

    if (doctorSelected == null) {
      _showErrorSnackBar("Vui lòng chọn bác sĩ");
      return;
    }

    if (selectedServices.isEmpty) {
      _showErrorSnackBar("Vui lòng chọn ít nhất một dịch vụ");
      return;
    }

    if (selectedTime == null) {
      _showErrorSnackBar("Vui lòng chọn thời gian khám");
      return;
    }

    final appointmentCreation = AppointmentCreation(
      doctorId: doctorSelected!.id,
      services: selectedServices,
      appointmentTime: selectedTime!.toUtc().toIso8601String(),
    );

    context.read<AppointmentBloc>().add(
      AppointmentCreationStarted(appointmentCreation),
    );
  }

  void _showSuccessDialog() {
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
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Đặt lịch thành công!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          content: const Text(
            'Lịch khám đã được đặt thành công.\nVui lòng thanh toán 20% để xác nhận lịch hẹn.',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    // Chuyển đổi thông báo lỗi kỹ thuật thành thông báo thân thiện với người dùng
    String userFriendlyMessage = _getUserFriendlyErrorMessage(message);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Đặt lịch thất bại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            userFriendlyMessage,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Thử lại"),
            ),
          ],
        );
      },
    );
  }

  // Phương thức chuyển đổi thông báo lỗi kỹ thuật thành thông báo thân thiện
  String _getUserFriendlyErrorMessage(String originalMessage) {
    // Chuyển đổi các thông báo lỗi phổ biến
    String lowerMessage = originalMessage.toLowerCase();

    if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('timeout') ||
        lowerMessage.contains('failed to connect')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.';
    }

    if (lowerMessage.contains('unauthorized') || lowerMessage.contains('401')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    if (lowerMessage.contains('forbidden') || lowerMessage.contains('403')) {
      return 'Bạn không có quyền thực hiện thao tác này.';
    }

    if (lowerMessage.contains('not found') || lowerMessage.contains('404')) {
      return 'Không tìm thấy thông tin yêu cầu. Vui lòng thử lại sau.';
    }

    if (lowerMessage.contains('server error') ||
        lowerMessage.contains('500') ||
        lowerMessage.contains('internal server error')) {
      return 'Hệ thống đang bảo trì. Vui lòng thử lại sau ít phút.';
    }

    if (lowerMessage.contains('bad request') || lowerMessage.contains('400')) {
      return 'Thông tin đặt lịch không hợp lệ. Vui lòng kiểm tra lại thông tin.';
    }

    if (lowerMessage.contains('conflict') || lowerMessage.contains('409')) {
      return 'Thời gian này đã được đặt trước. Vui lòng chọn thời gian khác.';
    }

    if (lowerMessage.contains('validation') ||
        lowerMessage.contains('invalid')) {
      return 'Thông tin đặt lịch chưa đầy đủ hoặc không hợp lệ. Vui lòng kiểm tra lại.';
    }

    if (lowerMessage.contains('nosuchmethoderror') ||
        lowerMessage.contains('null')) {
      return 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.';
    }

    // Nếu không khớp với các lỗi phổ biến, trả về thông báo chung
    return 'Đã xảy ra lỗi khi đặt lịch khám. Vui lòng thử lại sau hoặc liên hệ hỗ trợ nếu vấn đề vẫn tiếp tục.';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "Đã thanh toán":
        color = Colors.green;
        break;
      case "Chưa thanh toán":
        color = Colors.orange;
        break;
      case "Đã hủy":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
