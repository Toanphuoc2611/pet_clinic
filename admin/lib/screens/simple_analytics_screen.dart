import 'package:admin/dto/user/user_get_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/invoice/invoice_bloc.dart';
import 'package:admin/bloc/invoice/invoice_event.dart';
import 'package:admin/bloc/invoice/invoice_state.dart';
import 'package:admin/bloc/user/doctor/doctor_list_bloc.dart';
import 'package:admin/bloc/user/doctor/doctor_list_event.dart';
import 'package:admin/bloc/user/doctor/doctor_list_state.dart';
import 'package:admin/bloc/doctor_revenue/doctor_revenue_bloc.dart';
import 'package:admin/bloc/doctor_revenue/doctor_revenue_event.dart';
import 'package:admin/bloc/doctor_revenue/doctor_revenue_state.dart';

class DoctorRevenue {
  final UserGetDto doctor;
  final int revenue;

  DoctorRevenue({required this.doctor, required this.revenue});
}

class SimpleAnalyticsScreen extends StatefulWidget {
  const SimpleAnalyticsScreen({super.key});

  @override
  State<SimpleAnalyticsScreen> createState() => _SimpleAnalyticsScreenState();
}

class _SimpleAnalyticsScreenState extends State<SimpleAnalyticsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<UserGetDto> listDoctor = [];
  List<DoctorRevenue> revenueByDoctor = [];
  bool isLoadingDoctorRevenue = false;

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
    _loadDoctors();
  }

  void _loadRevenueData() {
    // Format ngày để phù hợp với timestamp trong database
    final startStr = DateFormat('yyyy-MM-dd 00:00:00').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd 23:59:59').format(_endDate);

    context.read<InvoiceBloc>().add(InvoiceGetRevenueStarted(startStr, endStr));
  }

  void _loadDoctors() {
    context.read<DoctorListBloc>().add(DoctorListGetStarted());
  }

  void _loadRevenueByDoctor() async {
    if (listDoctor.isEmpty) return;

    setState(() {
      isLoadingDoctorRevenue = true;
      revenueByDoctor = [];
    });

    final startStr = DateFormat('yyyy-MM-dd 00:00:00').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd 23:59:59').format(_endDate);

    // Đặt danh sách bác sĩ vào DoctorRevenueBloc
    final doctorRevenueBloc = context.read<DoctorRevenueBloc>();
    doctorRevenueBloc.setDoctors(listDoctor);

    // Reset trạng thái của bloc
    doctorRevenueBloc.add(DoctorRevenueResetEvent());

    // Gửi yêu cầu lấy doanh thu cho từng bác sĩ
    for (var doctor in listDoctor) {
      doctorRevenueBloc.add(
        DoctorRevenueGetStarted(startStr, endStr, doctor.id),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadRevenueData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildDoctorListListener(),

        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeSection(),
              const SizedBox(height: 24),

              _buildTotalRevenueCard(),
              const SizedBox(height: 24),

              _buildDoctorRevenueChart(),
              const SizedBox(height: 24),

              _buildQuickStats(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Khoảng thời gian:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                _loadRevenueData();
                _loadRevenueByDoctor();
              },
              child: const Text('Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorListListener() {
    return MultiBlocListener(
      listeners: [
        BlocListener<DoctorListBloc, DoctorListState>(
          listener: (context, state) {
            if (state is DoctorListGetSuccess) {
              setState(() {
                listDoctor = state.doctors;
              });
              _loadRevenueByDoctor();
            }
          },
        ),
        BlocListener<DoctorRevenueBloc, DoctorRevenueState>(
          listener: (context, state) {
            if (state is DoctorRevenueSuccess) {
              // Thêm doanh thu của bác sĩ vào danh sách
              setState(() {
                // Kiểm tra xem bác sĩ đã có trong danh sách chưa
                final existingIndex = revenueByDoctor.indexWhere(
                  (item) => item.doctor.id == state.doctor.id,
                );

                if (existingIndex >= 0) {
                  // Cập nhật doanh thu nếu bác sĩ đã có trong danh sách
                  revenueByDoctor[existingIndex] = DoctorRevenue(
                    doctor: state.doctor,
                    revenue: state.revenue,
                  );
                } else {
                  // Thêm mới nếu bác sĩ chưa có trong danh sách
                  revenueByDoctor.add(
                    DoctorRevenue(doctor: state.doctor, revenue: state.revenue),
                  );
                }

                // Nếu đã lấy đủ doanh thu cho tất cả bác sĩ
                if (revenueByDoctor.length == listDoctor.length) {
                  isLoadingDoctorRevenue = false;
                }
              });
            }
          },
        ),
      ],
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildTotalRevenueCard() {
    return BlocBuilder<InvoiceBloc, InvoiceState>(
      builder: (context, state) {
        int revenue = 0;
        bool isLoading = false;
        String? error;

        if (state is InvoiceGetRevenueSuccess) {
          revenue = state.revenue;
        } else if (state is InvoiceGetRevenueInProgress) {
          isLoading = true;
        } else if (state is InvoiceGetRevenueFailure) {
          error = state.message;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'Tổng doanh thu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (error != null)
                Text(
                  'Lỗi: $error',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                      ).format(revenue),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Từ ${DateFormat('dd/MM/yyyy').format(_startDate)} đến ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _calculateAverageDaily(revenue),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _calculateAverageDaily(int totalRevenue) {
    final days = _endDate.difference(_startDate).inDays + 1;
    final average = totalRevenue / days;
    return 'Trung bình: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(average)}/ngày';
  }

  Widget _buildDoctorRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doanh thu theo bác sĩ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 24),
            if (isLoadingDoctorRevenue)
              const Center(child: CircularProgressIndicator())
            else if (revenueByDoctor.isEmpty)
              const Center(
                child: Text('Không có dữ liệu doanh thu theo bác sĩ'),
              )
            else
              SizedBox(height: 300, child: _buildDoctorBarChart()),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorBarChart() {
    if (revenueByDoctor.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxRevenue = revenueByDoctor
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children:
          revenueByDoctor.map((data) {
            final height =
                maxRevenue > 0 ? (data.revenue / maxRevenue) * 250 : 0.0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: '₫',
                        decimalDigits: 0,
                      ).format(data.revenue),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.blue.shade600, Colors.blue.shade300],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.doctor.fullname ?? 'Bác sĩ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildQuickStats() {
    if (revenueByDoctor.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Bác sĩ cao nhất',
              'Chưa có dữ liệu',
              '',
              Icons.trending_up,
              Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Bác sĩ thấp nhất',
              'Chưa có dữ liệu',
              '',
              Icons.trending_down,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Trung bình/bác sĩ',
              'Chưa có dữ liệu',
              '',
              Icons.analytics,
              Colors.blue,
            ),
          ),
        ],
      );
    }

    final sortedRevenue = List<DoctorRevenue>.from(revenueByDoctor)
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final highestDoctor = sortedRevenue.first;
    final lowestDoctor = sortedRevenue.last;

    final totalRevenue = sortedRevenue.fold<int>(
      0,
      (sum, item) => sum + item.revenue,
    );
    final averageRevenue = totalRevenue / sortedRevenue.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Bác sĩ cao nhất',
            highestDoctor.doctor.fullname ?? 'Bác sĩ',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            ).format(highestDoctor.revenue),
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Bác sĩ thấp nhất',
            lowestDoctor.doctor.fullname ?? 'Bác sĩ',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            ).format(lowestDoctor.revenue),
            Icons.trending_down,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Trung bình/bác sĩ',
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            ).format(averageRevenue),
            '${sortedRevenue.length} bác sĩ',
            Icons.analytics,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
