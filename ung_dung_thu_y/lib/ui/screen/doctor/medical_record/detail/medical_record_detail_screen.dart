import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_state.dart';

import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_dto.dart';

import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:intl/intl.dart';

class MedicalRecordDetailScreen extends StatefulWidget {
  final MedicalRecordDto medicalRecordDto;
  const MedicalRecordDetailScreen({super.key, required this.medicalRecordDto});

  @override
  State<MedicalRecordDetailScreen> createState() =>
      _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<MedicalRecordDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrescriptionBloc>().add(
        PrescriptionGetByPetStarted(widget.medicalRecordDto.id),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => DoctorKennelDetailBloc(
            context.read<KennelDetailRepository>(),
          )..add(
            DoctorKennelDetailGetByPetStarted(widget.medicalRecordDto.pet.id),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết hồ sơ bệnh án'),
          backgroundColor: TColor.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // header display detail medical record
            _buildMedicalRecordHeader(),
            // Tab bar
            Container(
              color: TColor.primary,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.home), text: 'Lưu chuồng'),
                  Tab(icon: Icon(Icons.medical_services), text: 'Đơn thuốc'),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildKennelsTab(), _buildPrescriptionsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRecordHeader() {
    final medicalRecord = widget.medicalRecordDto;
    final pet = medicalRecord.pet;
    final owner = medicalRecord.user;
    final doctor = medicalRecord.doctor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // infor pet
          Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    pet.avatar != null ? NetworkImage(pet.avatar!) : null,
                child:
                    pet.avatar == null
                        ? Icon(Icons.pets, size: 50, color: Colors.grey[600])
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tên: ${pet.name}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${pet.type ?? 'Không xác định'} - ${pet.breed ?? 'Không xác định'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      'Cân nặng: ${pet.weight}kg',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chủ sở hữu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      owner.fullname ?? 'Không có tên',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      owner.phoneNumber,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bác sĩ phụ trách',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.fullname ?? 'Không có tên',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      doctor.phoneNumber,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ngày tạo: ${_formatDate(medicalRecord.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(medicalRecord.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(medicalRecord.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKennelsTab() {
    return BlocBuilder<DoctorKennelDetailBloc, DoctorKennelDetailState>(
      builder: (context, state) {
        if (state is DoctorKennelDetailGetByPetStartedInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DoctorKennelDetailGetByPetSuccess) {
          if (state.kennels.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có thông tin lưu chuồng',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.kennels.length,
            itemBuilder: (context, index) {
              final kennel = state.kennels[index];
              return _buildKennelCard(kennel);
            },
          );
        } else if (state is DoctorKennelDetailGetByPetFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPrescriptionsTab() {
    return BlocBuilder<PrescriptionBloc, PrescriptionState>(
      builder: (context, state) {
        if (state is PrescriptionGetByPetInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PrescriptionGetByPetSuccess) {
          if (state.prescriptions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có đơn thuốc nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = state.prescriptions[index];
              return _buildPrescriptionCard(prescription);
            },
          );
        } else if (state is PrescriptionGetByPetFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildKennelCard(KennelDetailDto kennel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chuồng #${kennel.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Đã lưu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (kennel.inTime != null) ...[
              Text(
                'Thời gian vào: ${_formatDate(kennel.inTime!)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
            ],
            if (kennel.outTime != null) ...[
              Text(
                'Thời gian ra: ${_formatDate(kennel.outTime!)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              'Chuồng số: ${kennel.kennel.name}',
              style: const TextStyle(fontSize: 14),
            ),
            if (kennel.note != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ghi chú: ${kennel.note}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionDto prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn thuốc #${prescription.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(prescription.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Chẩn đoán: ${prescription.diagnose}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Bác sĩ: ${prescription.doctor.fullname ?? 'Không có tên'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Ghi chú: ${prescription.note}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (prescription.reExamDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Ngày tái khám: ${_formatDate(prescription.reExamDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: TColor.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (prescription.prescriptionDetails.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Chi tiết thuốc:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...prescription.prescriptionDetails
                  .map((detail) => _buildMedicationDetail(detail))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationDetail(dynamic detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detail.medication.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail.medication.category.name,
                  style: TextStyle(
                    color: TColor.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail.medication.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liều lượng:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      detail.dosage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số lượng:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${detail.quantity} ${detail.medication.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn giá:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(detail.medication.price)} VNĐ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: TColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return TColor.primary;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Đang điều trị';
      case 1:
        return 'Hoàn thành';
      case 2:
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }
}
