import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_bloc.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_event.dart';
import 'package:admin/bloc/medical_record_management/medical_record_management_state.dart';
import 'package:admin/dto/medical_record/medical_record_dto.dart';
import 'package:admin/dto/prescription/prescription_dto.dart';

class MedicalRecordManagementScreen extends StatefulWidget {
  const MedicalRecordManagementScreen({super.key});

  @override
  State<MedicalRecordManagementScreen> createState() =>
      _MedicalRecordManagementScreenState();
}

class _MedicalRecordManagementScreenState
    extends State<MedicalRecordManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MedicalRecordManagementBloc>().add(LoadMedicalRecordsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersAndSearch(),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<
                MedicalRecordManagementBloc,
                MedicalRecordManagementState
              >(
                builder: (context, state) {
                  if (state is MedicalRecordManagementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MedicalRecordManagementError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MedicalRecordManagementBloc>().add(
                                LoadMedicalRecordsEvent(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is MedicalRecordManagementLoaded) {
                    return Column(
                      children: [
                        _buildStatsCards(state),
                        const SizedBox(height: 16),
                        Expanded(child: _buildMedicalRecordList(state)),
                        const SizedBox(height: 16),
                        _buildPagination(state),
                      ],
                    );
                  } else if (state is PrescriptionDetailsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PrescriptionDetailsLoaded) {
                    return _buildPrescriptionDetailsView(state);
                  } else if (state is PrescriptionDetailsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: TextStyle(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<MedicalRecordManagementBloc>().add(
                                LoadMedicalRecordsEvent(),
                              );
                            },
                            child: const Text('Quay lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.medical_services,
            color: Colors.green[600],
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quản lý hồ sơ bệnh án',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Quản lý hồ sơ khám bệnh và đơn thuốc của thú cưng',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return BlocBuilder<
      MedicalRecordManagementBloc,
      MedicalRecordManagementState
    >(
      builder: (context, state) {
        if (state is! MedicalRecordManagementLoaded) return const SizedBox();

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        'Tìm kiếm theo tên thú cưng, chủ sở hữu, bác sĩ...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<MedicalRecordManagementBloc>().add(
                      SearchMedicalRecordsEvent(value),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: state.selectedStatus,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Lọc theo trạng thái'),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Tất cả trạng thái'),
                      ),
                    ),
                    ...List.generate(2, (index) {
                      return DropdownMenuItem<int?>(
                        value: index,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(_getStatusText(index)),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    context.read<MedicalRecordManagementBloc>().add(
                      FilterMedicalRecordsByStatusEvent(value),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards(MedicalRecordManagementLoaded state) {
    final totalRecords = state.totalItems;
    final activeRecords =
        state.filteredMedicalRecords
            .where((record) => record.status == 0)
            .length;
    final completedRecords =
        state.filteredMedicalRecords
            .where((record) => record.status == 1)
            .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng hồ sơ',
            totalRecords.toString(),
            Icons.folder_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Đang điều trị',
            activeRecords.toString(),
            Icons.healing,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hoàn thành',
            completedRecords.toString(),
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Hiển thị',
            '${state.currentMedicalRecords.length}/${state.totalItems}',
            Icons.visibility,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordList(MedicalRecordManagementLoaded state) {
    if (state.currentMedicalRecords.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Không có hồ sơ bệnh án nào',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử thay đổi bộ lọc hoặc tìm kiếm',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: state.currentMedicalRecords.length,
              itemBuilder: (context, index) {
                final record = state.currentMedicalRecords[index];
                return _buildMedicalRecordRow(record);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'ID',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Tên thú cưng',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Chủ sở hữu',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Bác sĩ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Trạng thái',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Ngày tạo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordRow(MedicalRecordDto record) {
    final isEven = (record.id % 2) == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[25] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '#${record.id}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 2, child: Text(record.pet.name)),
          Expanded(flex: 2, child: Text(record.user.fullname ?? 'N/A')),
          Expanded(flex: 2, child: Text(record.doctor.fullname ?? 'N/A')),
          Expanded(flex: 1, child: _buildStatusChip(record.status)),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(DateTime.parse(record.createdAt)),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: () => _showMedicalRecordDetails(record),
              icon: Icon(Icons.visibility, color: Colors.green[600]),
              tooltip: 'Xem chi tiết',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color color;
    String text;

    switch (status) {
      case 0:
        color = Colors.orange;
        text = 'Đang điều trị';
        break;
      case 1:
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPagination(MedicalRecordManagementLoaded state) {
    if (state.totalPages <= 1) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Trang ${state.currentPage + 1} / ${state.totalPages}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    state.currentPage > 0
                        ? () => context.read<MedicalRecordManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage - 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(state.totalPages.clamp(0, 5), (index) {
                final page = index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap:
                        () => context.read<MedicalRecordManagementBloc>().add(
                          ChangePaginationEvent(page),
                        ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            state.currentPage == page
                                ? Colors.green[600]
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${page + 1}',
                        style: TextStyle(
                          color:
                              state.currentPage == page
                                  ? Colors.white
                                  : Colors.grey[600],
                          fontWeight:
                              state.currentPage == page
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed:
                    state.currentPage < state.totalPages - 1
                        ? () => context.read<MedicalRecordManagementBloc>().add(
                          ChangePaginationEvent(state.currentPage + 1),
                        )
                        : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetailsView(PrescriptionDetailsLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header với nút quay lại
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<MedicalRecordManagementBloc>().add(
                      LoadMedicalRecordsEvent(),
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.medical_services,
                  color: Colors.green[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chi tiết hồ sơ bệnh án #${state.medicalRecord.id}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Thú cưng: ${state.medicalRecord.pet.name}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Thông tin hồ sơ
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Tên thú cưng', state.medicalRecord.pet.name),
                _buildInfoRow(
                  'Chủ sở hữu',
                  state.medicalRecord.user.fullname ?? 'N/A',
                ),
                _buildInfoRow(
                  'Bác sĩ',
                  state.medicalRecord.doctor.fullname ?? 'N/A',
                ),
                _buildInfoRow(
                  'Trạng thái',
                  _getStatusText(state.medicalRecord.status),
                ),
                _buildInfoRow(
                  'Ngày tạo',
                  DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(state.medicalRecord.createdAt)),
                ),
              ],
            ),
          ),
          const Divider(),
          // Danh sách đơn thuốc
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đơn thuốc (${state.prescriptions.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (state.prescriptions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medication_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có đơn thuốc nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.prescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription = state.prescriptions[index];
                          return _buildPrescriptionCard(prescription);
                        },
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionDto prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Đơn thuốc #${prescription.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(prescription.createdAt)),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPrescriptionInfoRow(
              'Bác sĩ',
              prescription.doctor.fullname ?? 'N/A',
            ),
            _buildPrescriptionInfoRow('Chẩn đoán', prescription.diagnose),
            if (prescription.reExamDate != null)
              _buildPrescriptionInfoRow(
                'Ngày tái khám',
                DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(prescription.reExamDate!)),
              ),
            _buildPrescriptionInfoRow(
              'Ghi chú',
              prescription.note.isNotEmpty ? prescription.note : 'Không có',
            ),
            if (prescription.prescriptionDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Chi tiết thuốc:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              ...prescription.prescriptionDetails
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text(
                        '• ${detail.medication.name} - SL: ${detail.quantity} - ${detail.dosage}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Đang điều trị';
      case 1:
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

  void _showMedicalRecordDetails(MedicalRecordDto record) {
    context.read<MedicalRecordManagementBloc>().add(
      LoadPrescriptionDetailsEvent(record.id),
    );
  }
}
