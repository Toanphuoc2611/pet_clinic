import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class DoctorKennelListScreen extends StatefulWidget {
  const DoctorKennelListScreen({super.key});

  @override
  State<DoctorKennelListScreen> createState() => _DoctorKennelListScreenState();
}

class _DoctorKennelListScreenState extends State<DoctorKennelListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final WebSocketService _webSocketService = WebSocketService.instance;
  @override
  void initState() {
    super.initState();
    context.read<DoctorKennelDetailBloc>().add(DoctorKennelDetailGetStarted());
    _tabController = TabController(length: 2, vsync: this);
    _webSocketService.addKennelListener(_refreshKennel);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _webSocketService.removeKennelListener(_refreshKennel);
    super.dispose();
  }

  void _refreshKennel() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      context.read<DoctorKennelDetailBloc>().add(
        DoctorKennelDetailGetStarted(),
      );
    });
  }

  void _loadData() {
    context.read<DoctorKennelDetailBloc>().add(DoctorKennelDetailGetStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Danh sách lưu chuồng'),
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: TColor.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.pets), text: 'Đang lưu chuồng'),
                Tab(icon: Icon(Icons.check_circle), text: 'Đã xác nhận'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên thú cưng hoặc chủ nhân...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primary),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Tab content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child:
                  BlocBuilder<DoctorKennelDetailBloc, DoctorKennelDetailState>(
                    builder: (context, state) {
                      if (state is DoctorKennelDetailStartedInProgress) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is DoctorKennelDetailGetSuccess) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildActiveKennels(state.kennels),
                            _buildConfirmedKennels(state.kennels),
                          ],
                        );
                      } else if (state is DoctorKennelDetailGetFailure) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Lỗi: ${state.message}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveKennels(List<KennelDetailDto> kennels) {
    List<KennelDetailDto> activeKennels =
        kennels.where((kennel) {
          bool isActive = kennel.status == 2; // Đang lưu chuồng

          if (_searchController.text.isEmpty) return isActive;

          String searchText = _searchController.text.toLowerCase();
          String petName = kennel.pet.name.toLowerCase();
          String ownerName = (kennel.pet.owner?.fullname ?? '').toLowerCase();

          return isActive &&
              (petName.contains(searchText) || ownerName.contains(searchText));
        }).toList();

    if (activeKennels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có thú cưng nào đang lưu chuồng',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeKennels.length,
      itemBuilder: (context, index) {
        final kennel = activeKennels[index];
        return _buildKennelCard(kennel);
      },
    );
  }

  Widget _buildConfirmedKennels(List<KennelDetailDto> kennels) {
    List<KennelDetailDto> confirmedKennels =
        kennels.where((kennel) {
          bool isConfirmed = kennel.status == 1; // Đã xác nhận

          if (_searchController.text.isEmpty) return isConfirmed;

          String searchText = _searchController.text.toLowerCase();
          String petName = kennel.pet.name.toLowerCase();
          String ownerName = (kennel.pet.owner?.fullname ?? '').toLowerCase();

          return isConfirmed &&
              (petName.contains(searchText) || ownerName.contains(searchText));
        }).toList();

    if (confirmedKennels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có lưu chuồng nào đã xác nhận',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: confirmedKennels.length,
      itemBuilder: (context, index) {
        final kennel = confirmedKennels[index];
        return _buildKennelCard(kennel);
      },
    );
  }

  Widget _buildKennelCard(KennelDetailDto kennel) {
    return InkWell(
      onTap: () {
        context.push(RouteName.doctorKennelDetail, extra: kennel).then((
          result,
        ) {
          if (result == true) {
            _loadData();
          }
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with kennel info and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chuồng ${kennel.kennel.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: #${kennel.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(kennel.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(kennel.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Pet information
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.pets, color: TColor.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kennel.pet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${kennel.pet.type} • ${kennel.pet.breed}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (kennel.pet.owner?.fullname != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Chủ: ${kennel.pet.owner?.fullname}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Time information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // Thời gian dự kiến vào
                    if (kennel.inTime != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ngày dự kiến vào: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDateOnly(kennel.inTime!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (kennel.inTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.login, size: 16, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Thời gian thực tế vào: ',
                                  ),
                                  TextSpan(
                                    text:
                                        kennel.actualCheckin != null
                                            ? _formatDateTime(
                                              kennel.actualCheckin!,
                                            )
                                            : 'Chưa có',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          kennel.actualCheckin != null
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Thời gian dự kiến ra
                    if (kennel.outTime != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ngày dự kiến ra: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDateOnly(kennel.outTime!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Thời gian thực tế ra
                    if (kennel.outTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.logout, size: 16, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Thời gian thực tế ra: ',
                                  ),
                                  TextSpan(
                                    text:
                                        kennel.actualCheckout != null
                                            ? _formatDateTime(
                                              kennel.actualCheckout!,
                                            )
                                            : 'Chưa có',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color:
                                          kennel.actualCheckout != null
                                              ? Colors.red[700]
                                              : Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Note if available
              if (kennel.note != null && kennel.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Ghi chú:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kennel.note!,
                        style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green; // Đã xác nhận
      case 2:
        return Colors.orange; // Đang lưu chuồng
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Đã xác nhận';
      case 2:
        return 'Đang lưu chuồng';
      default:
        return 'Không xác định';
    }
  }

  // Format chỉ ngày cho thời gian dự kiến
  String _formatDateOnly(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  // Format đầy đủ ngày giờ cho thời gian thực tế
  String _formatDateTime(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}
