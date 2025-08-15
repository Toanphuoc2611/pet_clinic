import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctoc_kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_state.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_state.dart';

import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';

import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:intl/intl.dart';

class PetMedicalRecordScreen extends StatefulWidget {
  final PetGetDto pet;
  const PetMedicalRecordScreen({super.key, required this.pet});

  @override
  State<PetMedicalRecordScreen> createState() =>
      _MedicalRecordDetailScreenState();
}

class _MedicalRecordDetailScreenState extends State<PetMedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Trigger event to get medical records by petId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordBloc>().add(
        MedicalRecordGetByPetStarted(widget.pet.id),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết hồ sơ bệnh án'),
        backgroundColor: TColor.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Pet information header
          _buildPetInfoHeader(),
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
                Tab(icon: Icon(Icons.medical_services), text: 'Hồ sơ bệnh án'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildKennelsTab(), _buildMedicalRecordsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoHeader() {
    final pet = widget.pet;

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
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                pet.avatar != null ? NetworkImage(pet.avatar!) : null,
            child:
                pet.avatar == null
                    ? Icon(Icons.pets, size: 40, color: Colors.grey[600])
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.type ?? 'Không xác định'} - ${pet.breed ?? 'Không xác định'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cân nặng: ${pet.weight}kg',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tuổi: ${_calculateAge(pet.birthday)} - ${pet.gender == 0 ? "Cái" : "Đực"}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsTab() {
    return BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
      builder: (context, state) {
        if (state is MedicalRecordGetByPetInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MedicalRecordGetByPetSuccess) {
          if (state.medicalRecords.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có hồ sơ bệnh án nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.medicalRecords.length,
            itemBuilder: (context, index) {
              final medicalRecord = state.medicalRecords[index];
              return _buildMedicalRecordCard(medicalRecord);
            },
          );
        } else if (state is MedicalRecordGetByPetFailure) {
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<MedicalRecordBloc>().add(
                      MedicalRecordGetByPetStarted(widget.pet.id),
                    );
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecordDto medicalRecord) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push(
            RouteName.doctorDetailMedicalRecord,
            extra: medicalRecord,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày tạo: ${_formatDate(medicalRecord.createdAt)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Bác sĩ: ${medicalRecord.doctor.fullname ?? 'Không có tên'}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'SĐT: ${medicalRecord.doctor.phoneNumber}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Nhấn để xem chi tiết',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKennelsTab() {
    return BlocProvider(
      create:
          (context) =>
              DoctorKennelDetailBloc(context.read<KennelDetailRepository>())
                ..add(DoctorKennelDetailGetByPetStarted(widget.pet.id)),
      child: BlocBuilder<DoctorKennelDetailBloc, DoctorKennelDetailState>(
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
      ),
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

  String _calculateAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) {
      return 'Không xác định';
    }

    try {
      final birthDate = DateTime.parse(birthday);
      final now = DateTime.now();

      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (now.day < birthDate.day) {
        months -= 1;
      }
      if (months < 0) {
        years -= 1;
        months += 12;
      }

      if (years == 0) {
        return "$months tháng tuổi";
      } else if (months == 0) {
        return "$years tuổi";
      } else {
        return "$years tuổi $months tháng";
      }
    } catch (e) {
      return 'Không xác định';
    }
  }
}
