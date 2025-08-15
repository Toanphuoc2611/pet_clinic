import 'package:admin/bloc/appointment/appointment_bloc.dart';
import 'package:admin/bloc/appointment/appointment_event.dart';
import 'package:admin/bloc/appointment/appointment_state.dart';
import 'package:admin/core/service/websocket_service.dart';
import 'package:admin/dto/appointment/appointment_get_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  State<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends State<AppointmentManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  List<AppointmentGetDto> _appointments = [];
  final WebSocketService _webSocketService = WebSocketService.instance;
  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _webSocketService.addAppointmentListener(_refreshAppointment);
  }

  void _loadAppointments() {
    final startDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<AppointmentBloc>().add(AppointmentGetWeeklyStarted(startDate));
  }

  void _refreshAppointment() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      _loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          _buildDatePicker(),
          const SizedBox(height: 16),

          // Calendar view
          Expanded(
            child: BlocBuilder<AppointmentBloc, AppointmentState>(
              builder: (context, state) {
                if (state is AppointmentGetInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AppointmentGetWeeklySuccess) {
                  _appointments = state.appointments;
                  return _buildCalendarView();
                } else if (state is AppointmentGetFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${state.message}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAppointments,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Chưa có dữ liệu'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Chọn ngày bắt đầu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: _selectDate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      child: Column(
        children: [
          // Header với các ngày trong tuần
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(children: _buildWeekHeaders()),
          ),

          // Nội dung lịch
          Expanded(child: Row(children: _buildWeekColumns())),
        ],
      ),
    );
  }

  List<Widget> _buildWeekHeaders() {
    return List.generate(7, (index) {
      final date = _selectedDate.add(Duration(days: index));
      return Expanded(
        child: Column(
          children: [
            Text(
              DateFormat('dd/MM').format(date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildWeekColumns() {
    return List.generate(7, (index) {
      final date = _selectedDate.add(Duration(days: index));
      final dayAppointments = _getAppointmentsForDate(date);

      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right:
                  index < 6
                      ? BorderSide(color: Colors.grey[300]!)
                      : BorderSide.none,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: dayAppointments.length,
                  itemBuilder: (context, appointmentIndex) {
                    final appointment = dayAppointments[appointmentIndex];
                    return _buildAppointmentCard(appointment);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<AppointmentGetDto> _getAppointmentsForDate(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return _appointments.where((appointment) {
      final appointmentDate =
          DateTime.parse(appointment.appointmentTime).toLocal();
      final appointmentDateString = DateFormat(
        'yyyy-MM-dd',
      ).format(appointmentDate);
      return appointmentDateString == dateString;
    }).toList();
  }

  Widget _buildAppointmentCard(AppointmentGetDto appointment) {
    final appointmentTime =
        DateTime.parse(appointment.appointmentTime).toLocal();
    final timeString = DateFormat('HH:mm').format(appointmentTime);

    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case 0:
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        break;
      case 1:
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        break;
      case 2:
        statusColor = Colors.green;
        statusText = 'Hoàn thành';
        break;
      case 3:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      case 10:
        statusColor = Colors.purple;
        statusText = 'Tái khám';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            border: Border.all(color: statusColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'BS. ${appointment.fullname}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                appointment.user.fullname ?? 'Khách hàng',
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAppointments();
    }
  }

  void _showAppointmentDetails(AppointmentGetDto appointment) {
    final appointmentTime =
        DateTime.parse(appointment.appointmentTime).toLocal();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chi tiết lịch hẹn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  _buildDetailRow('Mã lịch hẹn', '#${appointment.id}'),
                  _buildDetailRow('Bác sĩ', 'BS. ${appointment.fullname}'),
                  _buildDetailRow('SĐT bác sĩ', appointment.phoneNumberDoctor),
                  _buildDetailRow(
                    'Khách hàng',
                    appointment.user.fullname ?? 'Chưa có tên',
                  ),
                  _buildDetailRow(
                    'SĐT khách hàng',
                    appointment.user.phoneNumber,
                  ),
                  _buildDetailRow(
                    'Thời gian',
                    DateFormat('dd/MM/yyyy HH:mm').format(appointmentTime),
                  ),
                  _buildDetailRow(
                    'Trạng thái',
                    _getStatusText(appointment.status),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'Dịch vụ:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  ...appointment.services
                      .map(
                        (service) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###', 'vi_VN').format(service.price)} VND',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Chờ xác nhận';
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Đã hủy';
      case 10:
        return 'Tái khám';
      default:
        return 'Không xác định';
    }
  }
}
