import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_state.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_api_client.dart';
import 'package:ung_dung_thu_y/repository/appointment/appointment_repository.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/header_home.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final WebSocketService _webSocketService = WebSocketService.instance;
  void _loadData() {
    context.read<DoctorAppointmentBloc>().add(
      DoctorAppointmentGetStarted(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
    context.read<DoctorKennelDetailBloc>().add(DoctorKennelDetailGetStarted());
    context.read<KennelBloc>().add(KennelGetStarted());
  }

  @override
  void initState() {
    super.initState();
    print("DoctorHomeScreen initState - adding listeners");
    _webSocketService.addAppointmentListener(_webSocketUpdateAppointment);
    _webSocketService.addKennelListener(_webSocketUpdateKennel);

    // Load initial data using global blocs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _webSocketUpdateAppointment() {
    if (mounted) {
      try {
        context.read<DoctorAppointmentBloc>().add(
          DoctorAppointmentGetStarted(
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
          ),
        );
        print("DoctorHomeScreen: Successfully triggered appointment refresh");
      } catch (e) {
        print("DoctorHomeScreen: Error accessing DoctorAppointmentBloc: $e");
      }
    }
  }

  void _webSocketUpdateKennel() {
    if (mounted) {
      try {
        context.read<DoctorKennelDetailBloc>().add(
          DoctorKennelDetailGetStarted(),
        );
        context.read<KennelBloc>().add(KennelGetStarted());
        print("DoctorHomeScreen: Successfully triggered kennel refresh");
      } catch (e) {
        print("DoctorHomeScreen: Error accessing kennel blocs: $e");
      }
    }
  }

  @override
  void dispose() {
    print("DoctorHomeScreen dispose - removing listeners");
    _webSocketService.removeAppointmentListener(_webSocketUpdateAppointment);
    _webSocketService.removeKennelListener(_webSocketUpdateKennel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and notifications
                HeaderHome(title: "Một ngày làm việc tốt lành!"),
                const SizedBox(height: 24),

                // Quick stats cards
                _buildQuickStats(),
                const SizedBox(height: 24),

                // Today's schedule section
                _buildTodaySchedule(),
                const SizedBox(height: 24),

                // Recent activities
                _buildRecentActivities(context),
                const SizedBox(height: 24),

                // Quick actions
                _buildQuickActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê hôm nay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<
                  DoctorAppointmentBloc,
                  DoctorAppointmentState
                >(
                  builder: (context, state) {
                    String appointmentCount = '0';
                    if (state is DoctorAppointmentGetTodaySuccess) {
                      appointmentCount = state.appointments.length.toString();
                    } else if (state is DoctorAppointmentGetTodayInProgress) {
                      appointmentCount = '...';
                    }
                    return _buildStatCard(
                      'Lịch hẹn',
                      appointmentCount,
                      Icons.calendar_today_outlined,
                      Colors.blue,
                      'Hôm nay',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RepositoryProvider(
                  create:
                      (context) => KennelRepository(
                        KennelApiClient(ApiService(dio)),
                        context.read<AuthRepository>(),
                      ),
                  child: BlocProvider(
                    create:
                        (context) =>
                            KennelBloc(context.read<KennelRepository>())
                              ..add(KennelGetStarted()),
                    child: BlocBuilder<KennelBloc, KennelState>(
                      builder: (context, state) {
                        String kennelCount = '0';
                        if (state is KennelGetSuccess) {
                          // Count available kennels (assuming empty kennels are available)
                          kennelCount = state.kennels.length.toString();
                        } else if (state is KennelGetInProgress) {
                          kennelCount = '...';
                        }
                        return _buildStatCard(
                          'Chuồng trống',
                          kennelCount,
                          Icons.home_outlined,
                          Colors.green,
                          'Hiện tại',
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Đang điều trị',
                  '8',
                  Icons.pets_outlined,
                  Colors.orange,
                  'Thú cưng',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BlocBuilder<
                  DoctorKennelDetailBloc,
                  DoctorKennelDetailState
                >(
                  builder: (context, state) {
                    String kennelDetailCount = '0';
                    if (state is DoctorKennelDetailGetSuccess) {
                      kennelDetailCount = state.kennels.length.toString();
                    } else if (state is DoctorKennelDetailStartedInProgress) {
                      kennelDetailCount = '...';
                    }
                    return _buildStatCard(
                      'Lưu chuồng',
                      kennelDetailCount,
                      Icons.add_alarm_outlined,
                      Colors.red,
                      'Chăm sóc',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch khám hôm nay',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TColor.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
            builder: (context, state) {
              if (state is DoctorAppointmentGetTodayInProgress) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              } else if (state is DoctorAppointmentGetTodaySuccess) {
                if (state.appointments.isEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có lịch hẹn nào hôm nay',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return _buildAppointmentsList(state.appointments);
              } else if (state is DoctorAppointmentGetTodayFailure) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi tải dữ liệu: ${state.message}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<DoctorAppointmentBloc>().add(
                                DoctorAppointmentGetStarted(
                                  DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(DateTime.now()),
                                ),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentGetDto> appointments) {
    // Filter appointments to show only future appointments (time > now)
    final now = DateTime.now();
    final futureAppointments =
        appointments
            .where((appointment) {
              try {
                // Parse appointment time - assuming format is "HH:mm"
                final timeParts = appointment.appointmentTime.split(':');
                if (timeParts.length == 2) {
                  final appointmentDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    int.parse(timeParts[0]),
                    int.parse(timeParts[1]),
                  );
                  return appointmentDateTime.isAfter(now);
                }
                return true;
              } catch (e) {
                return true;
              }
            })
            .take(3)
            .toList();

    if (futureAppointments.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có lịch hẹn sắp tới',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            futureAppointments.asMap().entries.map((entry) {
              int index = entry.key;
              AppointmentGetDto appointment = entry.value;
              bool isLast = index == futureAppointments.length - 1;

              return Column(
                children: [
                  _buildSimpleAppointmentItem(appointment),
                  if (!isLast) _buildDivider(),
                ],
              );
            }).toList(),
      ),
    );
  }
}

Widget _buildSimpleAppointmentItem(AppointmentGetDto appointment) {
  // Format the appointment time to dd/mm/yyyy hh:mm
  final dateTime =
      DateTime.parse(
        appointment.appointmentTime,
      ).toLocal(); // Change to local time

  final weekday = DateFormat.EEEE('vi').format(dateTime); // format to Thứ
  final date = DateFormat(
    'dd/MM/yyyy',
  ).format(dateTime); // format to dd/MM/yyyy
  final timeStart = DateFormat('HH:mm').format(dateTime); // Time start
  final formattedTime = '$weekday, $date $timeStart';

  return Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child:
              appointment.avatar != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      appointment.avatar!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.grey[600],
                          size: 24,
                        );
                      },
                    ),
                  )
                  : Icon(Icons.person, color: Colors.grey[600], size: 24),
        ),
        const SizedBox(width: 16),
        // User info and details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full name
              Text(
                appointment.user.fullname!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Phone number
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.user.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Formatted time
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSimpleKennelsList(List<KennelDetailDto> kennels) {
  // Filter kennels with status = 2 and take only first 2 kennels for home screen
  final filteredKennels =
      kennels.where((kennel) => kennel.status == 2).toList();
  final displayKennels = filteredKennels.take(2).toList();

  if (displayKennels.isEmpty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.pets_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Không có thú cưng nào đang lưu chuồng',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children:
          displayKennels.asMap().entries.map((entry) {
            int index = entry.key;
            KennelDetailDto kennel = entry.value;
            bool isLast = index == displayKennels.length - 1;

            return Column(
              children: [
                _buildSimpleKennelItem(kennel),
                if (!isLast) _buildDivider(),
              ],
            );
          }).toList(),
    ),
  );
}

Widget _buildSimpleKennelItem(KennelDetailDto kennel) {
  String plannedDateDisplay = 'N/A';
  if (kennel.inTime != null) {
    try {
      DateTime dateTime = DateTime.parse(kennel.inTime!);
      plannedDateDisplay = DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      plannedDateDisplay = kennel.inTime!;
    }
  }

  String actualTimeDisplay = 'Chưa có';
  if (kennel.actualCheckin != null) {
    try {
      DateTime dateTime = DateTime.parse(kennel.actualCheckin!);
      actualTimeDisplay = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      actualTimeDisplay = kennel.actualCheckin!;
    }
  }

  return Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        // Pet Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child:
              kennel.pet.avatar != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      kennel.pet.avatar!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.pets,
                          color: Colors.grey[600],
                          size: 24,
                        );
                      },
                    ),
                  )
                  : Icon(Icons.pets, color: Colors.grey[600], size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tên: ${kennel.pet.name}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ngày dự kiến: $plannedDateDisplay",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Thực tế: $actualTimeDisplay",
                style: TextStyle(
                  fontSize: 13,
                  color:
                      kennel.actualCheckin != null
                          ? Colors.green[600]
                          : Colors.orange[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Divider(color: Colors.grey[200], height: 1),
  );
}

Widget _buildRecentActivities(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thú cưng lưu chuồng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push(RouteName.doctorKennel);
              },
              child: Text(
                'Xem tất cả',
                style: TextStyle(color: TColor.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<DoctorKennelDetailBloc, DoctorKennelDetailState>(
          builder: (context, state) {
            if (state is DoctorKennelDetailStartedInProgress) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (state is DoctorKennelDetailGetSuccess) {
              if (state.kennels.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.pets_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có thú cưng nào đang lưu chuồng',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return _buildSimpleKennelsList(state.kennels);
            } else if (state is DoctorKennelDetailGetFailure) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi tải dữ liệu: ${state.message}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DoctorKennelDetailBloc>().add(
                              DoctorKennelDetailGetStarted(),
                            );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    ),
  );
}

Widget _buildQuickActions() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: TColor.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Quản lý chuồng',
                Icons.home_outlined,
                Colors.blue,
                () {
                  // Navigate to kennel management
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Lịch hẹn',
                Icons.calendar_today_outlined,
                Colors.green,
                () {
                  // Navigate to appointments
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Hồ sơ y tế',
                Icons.medical_services_outlined,
                Colors.orange,
                () {
                  // Navigate to medical records
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Báo cáo',
                Icons.analytics_outlined,
                Colors.purple,
                () {
                  // Navigate to reports
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildActionCard(
  String title,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
