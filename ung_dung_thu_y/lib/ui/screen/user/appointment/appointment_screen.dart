import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/appointment/appointment_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/card_display_appointment.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with SingleTickerProviderStateMixin {
  final List<AppointmentTab> tabs = [
    AppointmentTab("Tất cả", "-1", Icons.list_alt_outlined),
    AppointmentTab("Chờ thanh toán", "0", Icons.access_time_filled),
    AppointmentTab("Đã xác nhận", "1", Icons.check_circle_outline),
    AppointmentTab("Hoàn thành", "2", Icons.done_all_outlined),
    AppointmentTab("Đã hủy", "3", Icons.cancel_outlined),
    AppointmentTab("Hẹn tái khám", "10", Icons.schedule),
  ];
  final WebSocketService webSocketService = WebSocketService.instance;
  String currentStatus = "-1";
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final newStatus = tabs[_tabController.index].status;
      setState(() {
        currentStatus = newStatus;
      });
      context.read<AppointmentBloc>().add(AppointmentGetStarted(newStatus));
    });
    context.read<AppointmentBloc>().add(AppointmentGetStarted('-1'));
    webSocketService.addAppointmentListener(_websocke);
  }

  void _websocke() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      context.read<AppointmentBloc>().add(AppointmentGetStarted(currentStatus));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Lịch hẹn của tôi',
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.calendar_today_outlined, color: TColor.primary),
          ),
          IconButton(
            onPressed: () => context.push(RouteName.bookAppointment),
            icon: Icon(Icons.add, color: TColor.primary),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(children: [_buildTabBar()]),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) => _buildAppointmentList(tab.status)).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteName.bookAppointment),
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Đặt lịch hẹn'),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: TColor.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: TColor.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs:
            tabs
                .map(
                  (tab) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(tab.title),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentBloc>().add(AppointmentGetStarted(status));
      },
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          return switch (state) {
            AppointmentGetInProgress() => const Center(
              child: CircularProgressIndicator(),
            ),
            AppointmentGetSuccess() => _buildAppointmentsList(
              state.appointments,
            ),
            AppointmentFailure() => _buildErrorState(state.message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentGetDto> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: CardDisplayAppointment(appointmentGetDto: appointments[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    String description;
    IconData icon;

    switch (currentStatus) {
      case "0":
        message = "Không có lịch hẹn chờ thanh toán";
        description = "Các lịch hẹn mới sẽ xuất hiện ở đây";
        icon = Icons.pending_outlined;
        break;
      case "1":
        message = "Không có lịch hẹn đã xác nhận";
        description = "Lịch hẹn đã được bác sĩ xác nhận sẽ hiển thị ở đây";
        icon = Icons.check_circle_outline;
        break;
      case "2":
        message = "Chưa có lịch hẹn hoàn thành";
        description = "Lịch sử các lịch hẹn đã hoàn thành sẽ xuất hiện ở đây";
        icon = Icons.done_all_outlined;
        break;
      case "3":
        message = "Không có lịch hẹn đã hủy";
        description = "Các lịch hẹn đã hủy sẽ hiển thị ở đây";
        icon = Icons.cancel_outlined;
        break;
      default:
        message = "Chưa có lịch hẹn nào";
        description = "Hãy đặt lịch hẹn đầu tiên của bạn";
        icon = Icons.calendar_today_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          if (currentStatus == "-1" || currentStatus == "0") ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(RouteName.bookAppointment),
              icon: const Icon(Icons.add),
              label: const Text('Đặt lịch hẹn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AppointmentBloc>().add(
                AppointmentGetStarted(currentStatus),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    webSocketService.removeAppointmentListener(_websocke);
    _tabController.dispose();
    super.dispose();
  }
}

class AppointmentTab {
  final String title;
  final String status;
  final IconData icon;

  AppointmentTab(this.title, this.status, this.icon);
}
