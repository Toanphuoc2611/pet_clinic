import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/medical_record/medical_record_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/medical_record/medical_record_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class DoctorMedicalRecordScreen extends StatefulWidget {
  const DoctorMedicalRecordScreen({super.key});

  @override
  State<DoctorMedicalRecordScreen> createState() =>
      _DoctorMedicalRecordScreenState();
}

class _DoctorMedicalRecordScreenState extends State<DoctorMedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<MedicalRecordDto> _allRecords = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Hồ sơ y tế',
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: TColor.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: TColor.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang điều trị'),
            Tab(text: 'Đã hoàn thành'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Tab content
          Expanded(
            child: RepositoryProvider(
              create:
                  (context) => MedicalRecordRepository(
                    MedicalRecordApiClient(ApiService(dio)),
                    context.read<AuthRepository>(),
                  ),
              child: BlocProvider(
                create:
                    (context) => MedicalRecordBloc(
                      context.read<MedicalRecordRepository>(),
                    ),
                child: BlocConsumer<MedicalRecordBloc, MedicalRecordState>(
                  listener: (context, state) {
                    // Handle any side effects here if needed
                  },
                  builder: (context, state) {
                    // Trigger data loading on first build
                    if (state is MedicalRecordInitial) {
                      context.read<MedicalRecordBloc>().add(
                        MedicalRecordGetStarted(),
                      );
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MedicalRecordGetInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is MedicalRecordGetFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Có lỗi xảy ra khi tải dữ liệu',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<MedicalRecordBloc>().add(
                                  MedicalRecordGetStarted(),
                                );
                              },
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      );
                    }

                    List<MedicalRecordDto> allRecords = [];
                    if (state is MedicalRecordGetSuccess) {
                      allRecords = state.medicalRecords;
                    }

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllRecords(allRecords),
                        _buildCompletedRecords(allRecords),
                        _buildActiveRecords(allRecords),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên thú cưng hoặc chủ...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                  )
                  : null,
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
    );
  }

  Widget _buildAllRecords(List<MedicalRecordDto> records) {
    // Filter records based on search
    List<MedicalRecordDto> filteredRecords =
        records.where((record) {
          if (_searchController.text.isEmpty) return true;

          String searchText = _searchController.text.toLowerCase();
          String petName = record.pet.name.toLowerCase();
          String ownerName = (record.user.fullname ?? '').toLowerCase();

          return petName.contains(searchText) || ownerName.contains(searchText);
        }).toList();

    if (filteredRecords.isEmpty) {
      return const Center(
        child: Text(
          'Không có hồ sơ y tế nào',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return _buildMedicalRecordCard(record: record);
      },
    );
  }

  Widget _buildCompletedRecords(List<MedicalRecordDto> records) {
    List<MedicalRecordDto> activeRecords =
        records.where((record) {
          bool isActive = record.status == 0; // Đang điều trị // Đang điều trị

          if (_searchController.text.isEmpty) return isActive;

          String searchText = _searchController.text.toLowerCase();
          String petName = record.pet.name.toLowerCase();
          String ownerName = (record.user.fullname ?? '').toLowerCase();

          return isActive &&
              (petName.contains(searchText) || ownerName.contains(searchText));
        }).toList();

    if (activeRecords.isEmpty) {
      return const Center(
        child: Text(
          'Không có hồ sơ đang điều trị',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeRecords.length,
      itemBuilder: (context, index) {
        final record = activeRecords[index];
        return _buildMedicalRecordCard(record: record);
      },
    );
  }

  Widget _buildActiveRecords(List<MedicalRecordDto> records) {
    List<MedicalRecordDto> completedRecords =
        records.where((record) {
          bool isCompleted =
              record.status == 1; // Đã hoàn thành // Đã hoàn thành

          if (_searchController.text.isEmpty) return isCompleted;

          String searchText = _searchController.text.toLowerCase();
          String petName = record.pet.name.toLowerCase();
          String ownerName = (record.user.fullname ?? '').toLowerCase();

          return isCompleted &&
              (petName.contains(searchText) || ownerName.contains(searchText));
        }).toList();

    if (completedRecords.isEmpty) {
      return const Center(
        child: Text(
          'Không có hồ sơ đã hoàn thành',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedRecords.length,
      itemBuilder: (context, index) {
        final record = completedRecords[index];
        return _buildMedicalRecordCard(record: record);
      },
    );
  }

  Widget _buildMedicalRecordCard({required MedicalRecordDto record}) {
    // Extract data from the record
    String petName = record.pet.name;
    String ownerName = record.user.fullname ?? 'Không có tên';
    String breed = record.pet.breed ?? 'Không rõ';
    String petType = record.pet.type ?? 'Không rõ';
    String createdAt = record.createdAt;
    int status = record.status;

    // Format date (assuming createdAt is in ISO format)
    String formattedDate = _formatDate(createdAt);

    // Determine status display
    Color statusColor = status == 0 ? Colors.orange : TColor.primary;
    String statusText = status == 0 ? 'điều trị' : 'hoàn thành';

    // Pet icon based on type
    IconData petIcon =
        petType.toLowerCase().contains('chó') ? Icons.pets : Icons.pets;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header with pet info and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(petIcon, color: TColor.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '$petType - $breed',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Owner info
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Chủ: $ownerName',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Created date
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Ngày tạo: $formattedDate',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to medical record details
                _viewMedicalRecordDetails(record);
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Xem chi tiết'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  void _viewMedicalRecordDetails(MedicalRecordDto record) {
    context.push(RouteName.doctorDetailMedicalRecord, extra: record);
  }
}
