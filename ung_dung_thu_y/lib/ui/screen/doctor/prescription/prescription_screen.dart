import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/appointment/doctor_appointment_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_state.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_state.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_detail_req.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/medication/medication_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/medication/medication_repository.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';

class PrescriptionScreen extends StatefulWidget {
  final AppointmentGetDto appointment;
  const PrescriptionScreen({super.key, required this.appointment});
  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _reExamDate;
  PetGetDto? _selectedPet;
  List<PetGetDto> _pets = [];
  bool isNonePet = false;
  List<Map<String, dynamic>> _medications = [{}];

  @override
  void initState() {
    super.initState();
    context.read<PetBloc>().add(
      PetGetByUserIdStarted(widget.appointment.user.id),
    );
  }

  // Helper methods for quantity validation
  Color _getQuantityBorderColor(Map<String, dynamic> medication) {
    if (_isQuantityExceedsStock(medication)) {
      return Colors.red;
    } else if (medication['quantity'] != null &&
        medication['quantity']!.isNotEmpty) {
      return Colors.green.shade300;
    }
    return Colors.grey.shade300;
  }

  Color _getQuantityIconColor(Map<String, dynamic> medication) {
    if (_isQuantityExceedsStock(medication)) {
      return Colors.red;
    } else if (medication['quantity'] != null &&
        medication['quantity']!.isNotEmpty) {
      return Colors.green.shade600;
    }
    return Colors.grey.shade400;
  }

  Widget? _buildStockInfo(Map<String, dynamic> medication) {
    if (_isQuantityExceedsStock(medication)) {
      return Icon(Icons.error, color: Colors.red, size: 20);
    } else if (medication['quantity'] != null &&
        medication['quantity']!.isNotEmpty &&
        medication['selectedMedication'] != null) {
      return Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    return null;
  }

  String? _getQuantityErrorText(Map<String, dynamic> medication) {
    if (_isQuantityExceedsStock(medication)) {
      return 'Vượt quá tồn kho';
    }
    return null;
  }

  Color _getStockTextColor(Map<String, dynamic> medication) {
    if (_isQuantityExceedsStock(medication)) {
      return Colors.red;
    } else if (medication['selectedMedication'] != null) {
      final stock = medication['selectedMedication'].stockQuantity;
      final quantity = int.tryParse(medication['quantity'] ?? '0') ?? 0;
      if (quantity > stock * 0.8) {
        // Warning when using more than 80% of stock
        return Colors.orange;
      }
    }
    return Colors.grey.shade600;
  }

  bool _isQuantityExceedsStock(Map<String, dynamic> medication) {
    if (medication['selectedMedication'] == null ||
        medication['quantity'] == null ||
        medication['quantity']!.isEmpty) {
      return false;
    }

    final quantity = int.tryParse(medication['quantity']) ?? 0;
    final stockQuantity = medication['selectedMedication'].stockQuantity;

    return quantity > stockQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create:
          (context) => MedicationRepository(
            MedicationApiClient(ApiService(dio)),
            context.read<AuthRepository>(),
          ),
      child: BlocProvider(
        create:
            (context) =>
                MedicationBloc(context.read<MedicationRepository>())
                  ..add(MedicationAndCategoriesGetStarted()),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Đơn thuốc',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: TColor.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  // Show prescription info or help
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Thông tin đơn thuốc'),
                          content: Text(
                            'Vui lòng điền đầy đủ thông tin để tạo đơn thuốc cho thú cưng.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Đóng'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildCustomerInfo(),
                SizedBox(height: 20),
                _buildPetSelection(),
                SizedBox(height: 20),
                _buildDiagnosisInput(),
                SizedBox(height: 20),
                _buildMedicationsList(),
                SizedBox(height: 20),
                _buildReExamDateSelector(),
                SizedBox(height: 20),
                _buildNoteSection(),
                SizedBox(height: 30),
                _buildSubmitButton(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TColor.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: TColor.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Thông tin khách hàng',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.account_circle,
            label: 'Tên khách hàng',
            value: widget.appointment.user.fullname ?? 'Chưa có thông tin',
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Số điện thoại',
            value: widget.appointment.user.phoneNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetSelection() {
    return BlocBuilder<PetBloc, PetState>(
      builder: (context, state) {
        if (state is PetGetByUserIdInProgress) {
          return Center(child: CircularProgressIndicator());
        } else if (state is PetGetByUserIdSuccess) {
          _pets = state.list;
          if (_pets.isEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Không có thú cưng"),
                TextButton(
                  onPressed: () {
                    _showAddPetBottomSheet();
                  },
                  child: Text("Thêm thú cưng"),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chọn thú cưng:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<PetGetDto>(
                  value: _selectedPet,
                  decoration: InputDecoration(
                    labelText: 'Thú cưng',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      _pets.map((pet) {
                        return DropdownMenuItem<PetGetDto>(
                          value: pet,
                          child: Text(
                            "${pet.name} - ${pet.breed ?? 'Không rõ giống'}",
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPet = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _showAddPetBottomSheet();
                  },
                  child: Text("+ Thêm thú cưng mới"),
                ),
              ],
            );
          }
        } else if (state is PetGetByUserIdFailure) {
          return Column(
            children: [
              Text("Lỗi tải danh sách thú cưng: ${state.message}"),
              TextButton(
                onPressed: () {
                  context.read<PetBloc>().add(
                    PetGetByUserIdStarted(widget.appointment.user.id),
                  );
                },
                child: Text("Thử lại"),
              ),
            ],
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  void _showAddPetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _AddPetForm(
                onPetAdded: (pet) {
                  setState(() {
                    _pets.add(pet);
                    _selectedPet = pet;
                  });
                },
                owner: widget.appointment.user,
              ),
            ),
          ),
    );
  }

  Widget _buildDiagnosisInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chẩn đoán',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _diagnosisController,
          decoration: InputDecoration(
            labelText: 'Nhập chẩn đoán',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    return BlocBuilder<MedicationBloc, MedicationState>(
      builder: (context, state) {
        if (state is MedicationGetInProgress) {
          return Center(child: CircularProgressIndicator());
        } else if (state is MedicationAndCategoriesGetSuccess) {
          final medications = state.medications;
          final categories = state.categories;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thuốc',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              ..._medications.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> medication = entry.value;

                // Check if medication is complete and valid
                bool isComplete =
                    medication['category'] != null &&
                    medication['name'] != null &&
                    medication['name']!.isNotEmpty &&
                    medication['dosage'] != null &&
                    medication['dosage']!.isNotEmpty &&
                    medication['quantity'] != null &&
                    medication['quantity']!.isNotEmpty &&
                    !_isQuantityExceedsStock(medication);

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isComplete
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                    border: Border.all(
                      color:
                          isComplete
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with medication number and remove button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isComplete
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.medication,
                                      size: 16,
                                      color:
                                          isComplete
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Thuốc ${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color:
                                            isComplete
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isComplete) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 12,
                                        color: Colors.green.shade600,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'Hoàn thành',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_medications.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red.shade400,
                              ),
                              onPressed: () {
                                setState(() {
                                  _medications.removeAt(index);
                                });
                              },
                              tooltip: 'Xóa thuốc này',
                            ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Category dropdown (full width)
                      DropdownButtonFormField<String>(
                        value: medication['category'],
                        decoration: InputDecoration(
                          labelText: 'Loại thuốc',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: TColor.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.category,
                            color:
                                medication['category'] != null
                                    ? TColor.primary
                                    : Colors.grey.shade400,
                          ),
                        ),
                        items:
                            categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.name,
                                child: Text(category.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _medications[index]['category'] = value;
                            // Clear drug selection when category changes
                            _medications[index]['name'] = null;
                          });
                        },
                      ),
                      SizedBox(height: 12),

                      // Drug autocomplete (full width)
                      Autocomplete<String>(
                        initialValue: TextEditingValue(
                          text: medication['name'] ?? '',
                        ),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          // Filter medications by selected category
                          var filteredMeds = medications.where((med) {
                            bool matchesCategory =
                                medication['category'] == null ||
                                med.category.name == medication['category'];
                            bool matchesText = med.name.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                            return matchesCategory && matchesText;
                          });

                          return filteredMeds.map((med) => med.name).toList();
                        },
                        onSelected: (value) {
                          setState(() {
                            _medications[index]['name'] = value;
                            // Find and store the selected medication object
                            final selectedMed = medications.firstWhere(
                              (med) => med.name == value,
                              orElse: () => medications.first,
                            );
                            _medications[index]['selectedMedication'] =
                                selectedMed;
                            _medications[index]['unit'] = selectedMed.unit;
                          });
                        },
                        fieldViewBuilder: (
                          context,
                          controller,
                          focusNode,
                          onEditingComplete,
                        ) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Tên thuốc',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: TColor.primary,
                                  width: 2,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              filled: true,
                              fillColor:
                                  medication['category'] != null
                                      ? Colors.white
                                      : Colors.grey.shade50,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              enabled: medication['category'] != null,
                              hintText:
                                  medication['category'] == null
                                      ? 'Vui lòng chọn loại thuốc trước'
                                      : 'Nhập tên thuốc...',
                              prefixIcon: Icon(
                                Icons.medical_services,
                                color:
                                    medication['category'] != null
                                        ? (medication['name'] != null &&
                                                medication['name']!.isNotEmpty
                                            ? TColor.primary
                                            : Colors.grey.shade400)
                                        : Colors.grey.shade300,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),

                      // Dosage and Quantity in a row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: medication['dosage'] ?? '',
                              decoration: InputDecoration(
                                labelText:
                                    'Liều dùng (${medication['unit'] ?? 'đơn vị'})',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: TColor.primary,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                hintText: 'VD: 2 viên/lần',
                                prefixIcon: Icon(
                                  Icons.schedule,
                                  color:
                                      medication['dosage'] != null &&
                                              medication['dosage']!.isNotEmpty
                                          ? TColor.primary
                                          : Colors.grey.shade400,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _medications[index]['dosage'] = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  initialValue: medication['quantity'] ?? '',
                                  decoration: InputDecoration(
                                    labelText: 'Số lượng',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _getQuantityBorderColor(
                                          medication,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: _getQuantityBorderColor(
                                          medication,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    hintText: 'VD: 20 viên',
                                    prefixIcon: Icon(
                                      Icons.inventory,
                                      color: _getQuantityIconColor(medication),
                                    ),
                                    suffixIcon: _buildStockInfo(medication),
                                    errorText: _getQuantityErrorText(
                                      medication,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _medications[index]['quantity'] = value;
                                    });
                                  },
                                ),
                                if (medication['selectedMedication'] != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Tồn kho: ${medication['selectedMedication'].stockQuantity} ${medication['selectedMedication'].unit}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getStockTextColor(medication),
                                        fontWeight: FontWeight.w500,
                                      ),
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
              }).toList(),

              // Add medication button
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _medications.add({});
                    });
                  },
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Thêm thuốc mới'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    side: BorderSide(
                      color: TColor.primary.withOpacity(0.5),
                      width: 1.5,
                    ),
                    foregroundColor: TColor.primary,
                    backgroundColor: TColor.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text(
                  'Không thể tải danh sách thuốc',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<MedicationBloc>().add(
                      MedicationAndCategoriesGetStarted(),
                    );
                  },
                  child: Text('Thử lại'),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildReExamDateSelector() {
    bool hasDate = _reExamDate != null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasDate ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDate ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: hasDate ? Colors.green.shade600 : Colors.grey.shade600,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Ngày tái khám',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: hasDate ? Colors.green.shade800 : Colors.grey.shade800,
                ),
              ),
              if (hasDate) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Đã chọn',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate:
                    _reExamDate ?? DateTime.now().add(Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: TColor.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  _reExamDate = pickedDate;
                });
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: hasDate ? Colors.green.shade300 : Colors.grey.shade400,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasDate
                              ? DateFormat(
                                'EEEE, dd/MM/yyyy',
                              ).format(_reExamDate!)
                              : 'Chọn ngày tái khám',
                          style: TextStyle(
                            color:
                                hasDate ? Colors.black87 : Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight:
                                hasDate ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (hasDate) ...[
                          SizedBox(height: 4),
                          Text(
                            _getRelativeDate(_reExamDate!),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    hasDate ? Icons.edit_calendar : Icons.calendar_today,
                    color:
                        hasDate ? Colors.green.shade600 : Colors.grey.shade600,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (hasDate) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _reExamDate = null;
                    });
                  },
                  icon: Icon(Icons.clear, size: 16),
                  label: Text('Xóa ngày'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Ngày mai';
    } else if (difference < 7) {
      return 'Trong $difference ngày tới';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Trong $weeks tuần tới';
    } else {
      final months = (difference / 30).floor();
      return 'Trong $months tháng tới';
    }
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: 'Nhập ghi chú thêm (tùy chọn)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<PrescriptionBloc, PrescriptionState>(
      listener: (context, state) {
        if (state is PrescriptionCreatedSuccess) {
          context.pushReplacement(
            RouteName.doctorInvoiceDetail,
            extra: state.invoice,
          );
        } else if (state is PrescriptionCreatedFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tạo đơn thuốc: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PrescriptionCreatedInProgress;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : () {
                      // Implement submission logic
                      _submitPrescription();
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoading ? Colors.grey : TColor.primary,
              foregroundColor: TColor.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Đang tạo đơn thuốc...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      'Tạo đơn thuốc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        );
      },
    );
  }

  void _submitPrescription() {
    // Validate form
    if (_selectedPet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn thú cưng')));
      return;
    }

    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng nhập chẩn đoán')));
      return;
    }

    // Validate medication quantities against stock
    for (int i = 0; i < _medications.length; i++) {
      var medication = _medications[i];
      if (_isQuantityExceedsStock(medication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thuốc ${i + 1}: Số lượng vượt quá tồn kho (${medication['selectedMedication']?.stockQuantity ?? 0} ${medication['selectedMedication']?.unit ?? ''})',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Check if medication has all required fields
      if (medication['selectedMedication'] == null ||
          medication['dosage'] == null ||
          medication['dosage']!.isEmpty ||
          medication['quantity'] == null ||
          medication['quantity']!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thuốc ${i + 1}: Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Format reExamDate to yyyy-MM-dd format if exists, otherwise empty string
    String formattedReExamDate = "";
    if (_reExamDate != null) {
      formattedReExamDate =
          "${_reExamDate!.year.toString().padLeft(4, '0')}-${_reExamDate!.month.toString().padLeft(2, '0')}-${_reExamDate!.day.toString().padLeft(2, '0')}";
    }

    // Build prescription details from medications list
    List<PrescriptionDetailReq> prescriptionDetails = [];
    for (var medication in _medications) {
      if (medication['selectedMedication'] != null &&
          medication['dosage'] != null &&
          medication['quantity'] != null) {
        prescriptionDetails.add(
          PrescriptionDetailReq(
            dosage: medication['dosage'].toString(),
            quantity: int.tryParse(medication['quantity'].toString()) ?? 1,
            medication: medication['selectedMedication'],
          ),
        );
      }
    }

    // Create prescription request
    CreationPrescriptionReq creationPrescriptionReq = CreationPrescriptionReq(
      diagnose: _diagnosisController.text.trim(),
      note: _noteController.text.trim(),
      petId: _selectedPet!.id.toString(),
      idAppointment: widget.appointment.id!,
      reExamDate: formattedReExamDate.isEmpty ? null : formattedReExamDate,
      prescriptionDetail:
          prescriptionDetails.isEmpty ? null : prescriptionDetails,
    );

    // Dispatch event to create prescription
    context.read<PrescriptionBloc>().add(
      PrescriptionCreated(creationPrescriptionReq),
    );
    context.read<DoctorAppointmentBloc>().add(
      DoctorAppointmentGetStarted(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
  }
}

class _AddPetForm extends StatefulWidget {
  final Function(PetGetDto) onPetAdded;
  final UserGetDto owner;

  const _AddPetForm({required this.onPetAdded, required this.owner});

  @override
  State<_AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<_AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  final _birthdayController = TextEditingController();

  final Map<int, String> species = {1: "Chó", 2: "Mèo", 3: "Khác"};
  String? _selectedSpecies;
  int? _selectedSpeciesId;
  List<String> _breeds = [];
  int? _gender;
  int? _isNeutered;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header
          Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm thú cưng mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: BlocListener<PetBloc, PetState>(
                listener: (context, state) {
                  if (state is PetAddSuccess) {
                    // Create a PetGetDto from the added pet data
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thêm thú cưng thành công!')),
                    );
                    context.read<PetBloc>().add(
                      PetGetByUserIdStarted(widget.owner.id),
                    );
                  } else if (state is PetAddFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${state.message}')),
                    );
                  }
                },
                child: BlocBuilder<PetBloc, PetState>(
                  builder: (context, state) {
                    if (state is PetAddInProgress) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet name
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              "Tên thú cưng *",
                              icon: Icons.pets,
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Vui lòng nhập tên thú cưng"
                                        : null,
                          ),
                          SizedBox(height: 16),

                          // Birthday
                          TextFormField(
                            controller: _birthdayController,
                            readOnly: true,
                            decoration: _inputDecoration(
                              "Ngày sinh",
                              icon: Icons.cake,
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                _birthdayController.text =
                                    FormatDate.formatDatePicker(pickedDate);
                              }
                            },
                          ),
                          SizedBox(height: 16),

                          // Gender
                          DropdownButtonFormField<int>(
                            value: _gender,
                            decoration: _inputDecoration(
                              "Giới tính",
                              icon: Icons.wc,
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text("Đực")),
                              DropdownMenuItem(value: 0, child: Text("Cái")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),

                          // Species
                          DropdownButtonFormField<int>(
                            value:
                                _selectedSpeciesId, // phải là int, ví dụ 1, 2, 3
                            decoration: _inputDecoration("Loài"),
                            isExpanded: true,
                            itemHeight: 70,
                            items:
                                species.entries.map((entry) {
                                  return DropdownMenuItem<int>(
                                    value: entry.key,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 70,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _selectedSpecies = species[value];
                                setState(() {
                                  _selectedSpeciesId = value;
                                  _breeds = [];
                                  _breedController.clear();
                                });
                                _loadBreedsBySpecies(value.toString());
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // breed
                          _autocompleteBreeds(),
                          const SizedBox(height: 16),

                          // Breed
                          TextFormField(
                            controller: _breedController,
                            decoration: _inputDecoration(
                              "Giống",
                              icon: Icons.pets_outlined,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Color
                          TextFormField(
                            controller: _colorController,
                            decoration: _inputDecoration(
                              "Màu sắc",
                              icon: Icons.palette,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Weight
                          TextFormField(
                            controller: _weightController,
                            decoration: _inputDecoration(
                              "Cân nặng (kg)",
                              icon: Icons.monitor_weight,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),

                          // Is Neutered
                          DropdownButtonFormField<int>(
                            value: _isNeutered,
                            onChanged:
                                (val) => setState(() => _isNeutered = val),
                            decoration: _inputDecoration(
                              "Đã triệt sản?",
                              icon: Icons.medical_services,
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text("Rồi")),
                              DropdownMenuItem(value: 0, child: Text("Chưa")),
                            ],
                          ),
                          SizedBox(height: 16),

                          // Note
                          TextFormField(
                            controller: _noteController,
                            decoration: _inputDecoration(
                              "Ghi chú",
                              icon: Icons.note_alt,
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 24),

                          // Extra space at bottom for better scrolling
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Fixed submit button at bottom
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: BlocBuilder<PetBloc, PetState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is PetAddInProgress ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: TColor.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                        state is PetAddInProgress
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Đang thêm...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                            : Text(
                              'Thêm thú cưng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _loadBreedsBySpecies(String species_id) async {
    PetRepository petRepository = context.read<PetRepository>();
    Result<List<String>> result = await petRepository.getBreedsBySpecies(
      species_id,
    );
    if (result is Success<List<String>>) {
      setState(() {
        _breeds = result.data;
      });
    } else if (result is Failure<List<String>>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi không xác định")));
    }
  }

  Widget _autocompleteBreeds() {
    return Autocomplete<String>(
      fieldViewBuilder: (
        context,
        textEditingController,
        focusNode,
        onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: _inputDecoration(
            "Giống thú cưng",
            icon: _breeds.isNotEmpty ? (Icons.arrow_drop_down) : null,
          ),
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? "Vui lòng nhập giống"
                      : null,
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (_selectedSpeciesId == null) {
          return const Iterable<String>.empty();
        }
        if (textEditingValue.text.isEmpty) {
          return _breeds;
        }
        return _breeds.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        setState(() {
          _breedController.text = selection;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Text(option, style: TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade600) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      isDense: true,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String? _nullIfEmpty(String text) =>
          text.trim().isEmpty ? null : text.trim();

      final petAddDto = PetAddDto(
        name: _nameController.text,
        type: _nullIfEmpty(_selectedSpecies ?? ''),
        breed: _nullIfEmpty(_breedController.text),
        color: _nullIfEmpty(_colorController.text),
        weight:
            _weightController.text.isEmpty
                ? 0.0
                : double.parse(_weightController.text),
        note: _nullIfEmpty(_noteController.text),
        birthday: _nullIfEmpty(
          FormatDate.formatRequest(_birthdayController.text),
        ),
        gender: _gender ?? 0,
        isNeutered: _isNeutered ?? 0,
        userId: widget.owner.id,
      );

      context.read<PetBloc>().add(PetAddStarted(petAddDto));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }
}
