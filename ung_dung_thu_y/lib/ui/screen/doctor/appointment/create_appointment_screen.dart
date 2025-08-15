import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medication/medication_state.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_event.dart';
import 'package:ung_dung_thu_y/bloc/doctor/prescription/prescription_state.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/bloc/service/service_bloc.dart';
import 'package:ung_dung_thu_y/bloc/service/service_event.dart';
import 'package:ung_dung_thu_y/bloc/service/service_state.dart';
import 'package:ung_dung_thu_y/bloc/user/user_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/user_event.dart';
import 'package:ung_dung_thu_y/bloc/user/user_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_creation_by_doctor.dart';
import 'package:ung_dung_thu_y/dto/prescription/prescription_detail_req.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_creation_request.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/medication/medication_api_client.dart';
import 'package:ung_dung_thu_y/remote/pet/pet_api_client.dart';
import 'package:ung_dung_thu_y/remote/user/user_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/medication/medication_repository.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  _CreateAppointmentScreenState createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _reExamDate;
  UserGetDto? _selectedUser;
  PetGetDto? _selectedPet;
  List<UserGetDto> _users = [];
  List<PetGetDto> _pets = [];
  List<ServicesGetDto> _selectedServices = [];
  List<ServicesGetDto> _allServices = [];
  List<Map<String, dynamic>> _medications = [{}];
  bool _isCreatingNewPet = false;

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
  void initState() {
    super.initState();
    // Load services
    context.read<ServiceBloc>().add(ServiceGetStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PetBloc(
                PetRepository(
                  petApiClient: PetApiClient(ApiService(dio)),
                  authRepository: context.read<AuthRepository>(),
                ),
              ),
        ),
        BlocProvider(
          create:
              (context) => MedicationBloc(
                MedicationRepository(
                  MedicationApiClient(ApiService(dio)),
                  context.read<AuthRepository>(),
                ),
              )..add(MedicationAndCategoriesGetStarted()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Tạo lịch khám bệnh',
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
        ),
        body: BlocListener<PrescriptionBloc, PrescriptionState>(
          listener: (context, state) {
            if (state is PrescriptionCreatedByDoctorSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('khám bệnh thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pushReplacement(
                RouteName.doctorInvoiceDetail,
                extra: state.invoice,
              );
            } else if (state is PrescriptionCreatedByDoctorFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserSection(),
                SizedBox(height: 20),
                _buildServiceSection(),
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
                _buildCreateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn người dùng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showCreateUserDialog(context);
                  },
                  icon: Icon(Icons.person_add),
                  label: Text('Thêm mới'),
                ),
              ],
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: _userSearchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm người dùng',
                hintText: 'Nhập số điện thoại hoặc tên',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<UserBloc>().add(UserSearchStarted(value));
                }
              },
            ),
            SizedBox(height: 12),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserSearchInProgress) {
                  return Container(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is UserSearchSuccess) {
                  _users = state.users;
                  if (_users.isEmpty) {
                    return Container(
                      height: 100,
                      child: Center(
                        child: Text(
                          'Không tìm thấy người dùng nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                user.avatar != null
                                    ? NetworkImage(user.avatar!)
                                    : null,
                            child:
                                user.avatar == null ? Icon(Icons.person) : null,
                          ),
                          title: Text(user.fullname ?? 'Không có tên'),
                          subtitle: Text(user.phoneNumber),
                          onTap: () {
                            setState(() {
                              _selectedUser = user;
                              _userSearchController.text = user.fullname ?? '';
                            });
                            // Clear search results to hide the list
                            context.read<UserBloc>().add(UserSearchCleared());
                            // Load pets for this user
                            context.read<PetBloc>().add(
                              PetGetByUserIdStarted(user.id),
                            );
                          },
                          selected: _selectedUser?.id == user.id,
                        );
                      },
                    ),
                  );
                } else if (state is UserSearchFailure) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: Text(
                        'Lỗi: ${state.message}',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
            if (_selectedUser != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Đã chọn: ${_selectedUser!.fullname}',
                      style: TextStyle(color: Colors.green.shade700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelection() {
    if (_selectedUser == null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Vui lòng chọn người dùng trước',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ],
        ),
      );
    }

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
                    PetGetByUserIdStarted(_selectedUser!.id),
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

                owner: _selectedUser!,
              ),
            ),
          ),
    );
  }

  Widget _buildServiceSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn dịch vụ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceGetInProgress) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ServiceGetSuccess) {
                  _allServices = state.services;
                  return Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _allServices.length,
                      itemBuilder: (context, index) {
                        final service = _allServices[index];
                        final isSelected = _selectedServices.any(
                          (s) => s.id == service.id,
                        );
                        return CheckboxListTile(
                          title: Text(service.name),
                          subtitle: Text('${service.price.toString()} VNĐ'),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.removeWhere(
                                  (s) => s.id == service.id,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
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
                              prefixIcon: Icon(
                                Icons.medication_liquid,
                                color:
                                    medication['name'] != null &&
                                            medication['name']!.isNotEmpty
                                        ? TColor.primary
                                        : Colors.grey.shade400,
                              ),
                              hintText:
                                  medication['category'] != null
                                      ? 'Nhập tên thuốc...'
                                      : 'Chọn loại thuốc trước',
                            ),
                            enabled: medication['category'] != null,
                            onEditingComplete: onEditingComplete,
                          );
                        },
                      ),
                      SizedBox(height: 12),

                      // Dosage and Quantity row
                      Row(
                        children: [
                          // Dosage field
                          Expanded(
                            child: TextFormField(
                              initialValue: medication['dosage'] ?? '',
                              decoration: InputDecoration(
                                labelText: 'Liều dùng',
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
                                hintText: 'VD: 2 lần/ngày',
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

                          // Quantity field
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  initialValue: medication['quantity'] ?? '',
                                  decoration: InputDecoration(
                                    labelText:
                                        'Số lượng${medication['unit'] != null ? ' (${medication['unit']})' : ''}',
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
                                        color:
                                            _isQuantityExceedsStock(medication)
                                                ? Colors.red
                                                : TColor.primary,
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

  Widget _buildCreateButton() {
    return BlocBuilder<PrescriptionBloc, PrescriptionState>(
      builder: (context, state) {
        final isLoading = state is PrescriptionCreatedByDoctorInProgress;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _createAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      'Tạo lịch khám bệnh',
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

  void _createAppointment() {
    // Validate form
    if (_selectedUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn người dùng')));
      return;
    }

    if (_selectedPet == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn thú cưng')));
      return;
    }

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn ít nhất một dịch vụ')),
      );
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
      if (medication['selectedMedication'] != null &&
          (medication['dosage'] == null ||
              medication['dosage']!.isEmpty ||
              medication['quantity'] == null ||
              medication['quantity']!.isEmpty)) {
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
    final prescriptionCreation = PrescriptionCreationByDoctor(
      userId: _selectedUser!.id,
      petId: _selectedPet!.id,
      services: _selectedServices,
      diagnose: _diagnosisController.text.trim(),
      note: _noteController.text.trim(),
      reExamDate: formattedReExamDate.isEmpty ? "" : formattedReExamDate,
      prescriptionDetail:
          prescriptionDetails.isEmpty ? [] : prescriptionDetails,
    );

    // Dispatch event to create prescription
    context.read<PrescriptionBloc>().add(
      PrescriptionCreatedByDoctor(prescriptionCreation),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final TextEditingController fullnameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    DateTime? birthday;
    int gender = 0; // 0: Nam, 1: Nữ

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm người dùng mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: fullnameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Giới tính: '),
                        Radio<int>(
                          value: 0,
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                        Text('Nam'),
                        Radio<int>(
                          value: 1,
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                        ),
                        Text('Nữ'),
                      ],
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            Duration(days: 365 * 25),
                          ),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            birthday = date;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(width: 8),
                            Text(
                              birthday != null
                                  ? DateFormat('dd/MM/yyyy').format(birthday!)
                                  : 'Chọn ngày sinh',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Hủy'),
                ),
                BlocConsumer<UserBloc, UserState>(
                  listener: (context, state) {
                    if (state is UserCreateSuccess) {
                      this.setState(() {
                        _selectedUser = state.user;
                        _userSearchController.text = state.user.fullname ?? '';
                      });

                      Navigator.of(dialogContext).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm người dùng mới: ${state.user.fullname}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (state is UserCreateFailure) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          state is UserCreateInProgress
                              ? null
                              : () {
                                if (fullnameController.text.isNotEmpty &&
                                    phoneController.text.isNotEmpty &&
                                    birthday != null) {
                                  final userCreationRequest =
                                      UserCreationRequest(
                                        fullname: fullnameController.text,
                                        phoneNumber: phoneController.text,
                                        address:
                                            addressController.text.isNotEmpty
                                                ? addressController.text
                                                : '',
                                        gender: gender,
                                        birthday: DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(birthday!),
                                      );

                                  context.read<UserBloc>().add(
                                    UserCreateStarted(
                                      userCreationRequest: userCreationRequest,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Vui lòng nhập đầy đủ thông tin bắt buộc (bao gồm ngày sinh)',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                      child:
                          state is UserCreateInProgress
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Thêm'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
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
                            value: _selectedSpeciesId,
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
                            decoration: _inputDecoration(
                              "Triệt sản",
                              icon: Icons.healing,
                            ),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text("Chưa")),
                              DropdownMenuItem(value: 1, child: Text("Rồi")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _isNeutered = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),

                          // Note
                          TextFormField(
                            controller: _noteController,
                            decoration: _inputDecoration(
                              "Ghi chú",
                              icon: Icons.note,
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 24),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Thêm thú cưng',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: TColor.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _autocompleteBreeds() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _breeds;
        }
        return _breeds.where(
          (breed) =>
              breed.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      onSelected: (String selection) {
        _breedController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: _inputDecoration(
            "Giống (tự động hoàn thành)",
            icon: Icons.search,
          ),
        );
      },
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Vui lòng nhập tên thú cưng')));
        return;
      }

      final petAddDto = PetAddDto(
        name: _nameController.text,
        birthday:
            _birthdayController.text.isNotEmpty
                ? FormatDate.formatRequest(_birthdayController.text)
                : null,
        type: _selectedSpecies ?? "Khác",
        breed: _breedController.text.isNotEmpty ? _breedController.text : null,
        color: _colorController.text.isNotEmpty ? _colorController.text : null,
        gender: _gender ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        isNeutered: _isNeutered ?? 0,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        userId: widget.owner.id,
      );

      context.read<PetBloc>().add(PetAddStarted(petAddDto));
    }
  }
}
