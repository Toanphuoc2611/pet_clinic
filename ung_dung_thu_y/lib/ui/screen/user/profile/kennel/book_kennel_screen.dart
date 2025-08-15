import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_detail/kennel_detail_state.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_event.dart';
import 'package:ung_dung_thu_y/bloc/kennel/kennel_state.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_event.dart';
import 'package:ung_dung_thu_y/bloc/user/doctor/doctor_list_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/kennel/book_kennel_request.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/kennel/kennel_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_repository.dart';
import 'package:ung_dung_thu_y/repository/user/user_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_input_decoration.dart';

class BookKennelScreen extends StatefulWidget {
  const BookKennelScreen({super.key});

  @override
  State<BookKennelScreen> createState() => _BookKennelScreenState();
}

class _BookKennelScreenState extends State<BookKennelScreen> {
  DateTime inTime = DateTime.now();
  late DateTime outTime = inTime.add(const Duration(days: 1));
  KennelDto? _selectedKennel;
  final TextEditingController _noteController = TextEditingController();
  UserGetDto? doctorSelected;
  late List<UserGetDto> doctors = [];
  late List<PetGetDto> pets = [];
  PetGetDto? petSelected;
  List<KennelDto> listKennels = [];
  double _calculatedPrice = 0.0;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Add these variables to preserve kennel data

  void backScreen() {
    context.go(RouteName.main);
  }

  @override
  void initState() {
    super.initState();
    context.read<PetBloc>().add(PetGetKennelValidStarted());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Đặt lịch lưu chuồng",
          style: TextStyle(
            color: TColor.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: backScreen,
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
      ),
      body: RepositoryProvider(
        create:
            (context) => KennelRepository(
              KennelApiClient(ApiService(dio)),
              context.read<AuthRepository>(),
            ),
        child: BlocProvider(
          create: (context) {
            final bloc = KennelBloc(context.read<KennelRepository>());
            bloc.add(KennelGetStarted());
            return bloc;
          },
          child: BlocListener<KennelDetailBloc, KennelDetailState>(
            listener: (context, state) {
              if (state is BookKennelDetailSuccess) {
                _showSuccessDialog();
              } else if (state is BookKennelDetailFailure) {
                _showErrorDialog(state.message);
              }
            },
            child: Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: BlocBuilder<KennelDetailBloc, KennelDetailState>(
                    builder: (context, state) {
                      if (state is BookKennelDetailInProgress) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildContent();
                    },
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy');

  Widget _buildStepIndicator() {
    final steps = [
      StepData('Chọn thú cưng', Icons.pets_outlined),
      StepData('Chọn bác sĩ', Icons.person_outline),
      StepData('Thời gian & Chuồng', Icons.schedule_outlined),
      StepData('Xác nhận', Icons.check_circle_outline),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ), // Increased padding to fix overflow
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = _currentStep >= index;
          final isCompleted = _currentStep > index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ), // Add padding to prevent overflow
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isCompleted
                                    ? Colors.green
                                    : isActive
                                    ? TColor.primary
                                    : Colors.grey[300],
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : steps[index].icon,
                            color:
                                isActive || isCompleted
                                    ? Colors.white
                                    : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          steps[index].title,
                          style: TextStyle(
                            fontSize:
                                11, // Slightly smaller font to prevent overflow
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isActive ? TColor.primary : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 16, // Reduced width to save space
                    height: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildPetSelection(),
        _buildDoctorSelection(),
        _buildTimeAndKennelSelection(),
        _buildConfirmation(),
      ],
    );
  }

  Widget _buildPetSelection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        20,
      ), // Reduce right padding to fix overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn thú cưng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng chọn thú cưng cần lưu chuồng',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocListener<PetBloc, PetState>(
              listener: (context, state) {
                if (state is PetGetKennelValidSuccess) {
                  setState(() {
                    pets = state.list;
                    if (state.list.isNotEmpty && petSelected == null) {
                      petSelected = state.list.first;
                    }
                  });
                }
              },
              child: BlocBuilder<PetBloc, PetState>(
                builder: (context, state) {
                  return switch (state) {
                    PetGetKennelValidInProgress() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    PetGetKennelValidSuccess() => _buildPetList(state.list),
                    PetGetKennelValidFailure() => _buildErrorState(
                      state.message,
                    ),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(List<PetGetDto> pets) {
    if (pets.isEmpty) {
      return _buildEmptyPetState();
    }

    return ListView.builder(
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isSelected = petSelected?.id == pet.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? TColor.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? TColor.primary : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/image/pet_default.jpg",
                  image:
                      pet.avatar ??
                      "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678351/pet_default_vg54u5.jpg",
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, _) {
                    return Image.asset(
                      "assets/image/pet_default.jpg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            title: Text(
              pet.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  getPetAge(pet.birthday),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.gender != null
                      ? (pet.gender == 0 ? "Đực" : "Cái")
                      : "Chưa xác định giới tính",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing:
                isSelected
                    ? Icon(Icons.check_circle, color: TColor.primary, size: 24)
                    : Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.grey[400],
                      size: 24,
                    ),
            onTap: () {
              setState(() {
                petSelected = pet;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyPetState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có thú cưng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng thêm thú cưng trước khi đặt lịch',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        20,
      ), // Reduce right padding to fix overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn bác sĩ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng chọn bác sĩ chăm sóc thú cưng',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocProvider(
              create:
                  (context) =>
                      DoctorListBloc(context.read<UserRepository>())
                        ..add(DoctorListGetStarted()),
              child: BlocBuilder<DoctorListBloc, DoctorListState>(
                builder: (context, state) {
                  return switch (state) {
                    DoctorListGetInProgress() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    DoctorListGetSuccess() => _buildDoctorList(state.doctors),
                    DoctorListGetFailure() => _buildErrorState(state.message),
                    _ => const SizedBox.shrink(),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<UserGetDto> doctors) {
    this.doctors = doctors;

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final isSelected = doctorSelected?.id == doctor.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? TColor.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                doctorSelected = doctor;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: TColor.primary.withOpacity(0.1),
                    backgroundImage:
                        doctor.avatar != null
                            ? NetworkImage(doctor.avatar!)
                            : null,
                    child:
                        doctor.avatar == null
                            ? Icon(
                              Icons.person,
                              color: TColor.primary,
                              size: 30,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BS. ${doctor.fullname ?? "Không có tên"}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  isSelected
                      ? Icon(
                        Icons.check_circle,
                        color: TColor.primary,
                        size: 24,
                      )
                      : Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeAndKennelSelection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        20,
      ), // Reduce right padding to fix overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thời gian & Loại chuồng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn thời gian và loại chuồng phù hợp',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateTimeSelection(),
                  const SizedBox(height: 24),
                  _buildKennelSelection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thời gian lưu chuồng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    'Ngày bắt đầu',
                    inTime,
                    Icons.calendar_today,
                    () => _pickInTime(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelector(
                    'Ngày kết thúc',
                    outTime,
                    Icons.calendar_today,
                    () => _pickOutTime(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: TColor.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Thời gian lưu chuồng: ${_calculateDays()} ngày',
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    String label,
    DateTime date,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: TColor.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _dateTimeFormat.format(date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKennelSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loại chuồng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            RepositoryProvider(
              create:
                  (context) => KennelRepository(
                    KennelApiClient(ApiService(dio)),
                    context.read<AuthRepository>(),
                  ),
              child: BlocProvider(
                create: (context) {
                  final bloc = KennelBloc(context.read<KennelRepository>());
                  bloc.add(KennelGetStarted());
                  return bloc;
                },
                child: BlocBuilder<KennelBloc, KennelState>(
                  builder: (context, state) {
                    if (state is KennelGetSuccess) {
                      return _buildKennelDropdown(state.kennels);
                    } else if (state is KennelGetInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return _buildKennelDropdown(listKennels);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi chú cho bác sĩ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TColor.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Nhập ghi chú cho bác sĩ (ví dụ: Bé cần ăn vào lúc 9h sáng)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColor.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        16,
        20,
      ), // Reduce right padding to fix overflow
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xác nhận đặt lịch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng kiểm tra lại thông tin trước khi đặt lịch',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildConfirmationCard(
                    'Thú cưng',
                    Icons.pets_outlined,
                    petSelected != null
                        ? petSelected!.name ?? 'Không có tên'
                        : 'Chưa chọn thú cưng',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationCard(
                    'Bác sĩ chăm sóc',
                    Icons.person_outline,
                    doctorSelected != null
                        ? 'BS. ${doctorSelected!.fullname}'
                        : 'Chưa chọn bác sĩ',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationCard(
                    'Thời gian lưu chuồng',
                    Icons.schedule_outlined,
                    '${_dateTimeFormat.format(inTime)} - ${_dateTimeFormat.format(outTime)} (${_calculateDays()} ngày)',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationCard(
                    'Loại chuồng',
                    Icons.home_outlined,
                    _selectedKennel != null
                        ? '${_selectedKennel!.name} - ${_selectedKennel!.type == "NORMAL" ? "Bình thường" : "Đặc biệt"}'
                        : 'Chưa chọn loại chuồng',
                  ),
                  const SizedBox(height: 24),
                  _buildPriceCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard(String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // Add margin to prevent overflow
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: TColor.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 4,
              ), // Add right padding to fix overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15, // Slightly smaller font
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TColor.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng chi phí:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '${NumberFormat('#,###').format(_calculatedPrice)} VNĐ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: TColor.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Giá tính theo ${_calculateDays()} ngày lưu chuồng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: TColor.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Quay lại',
                  style: TextStyle(
                    color: TColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 3 ? _bookKennel : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                _currentStep == 3 ? 'Đặt lịch lưu chuồng' : 'Tiếp tục',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
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
        ],
      ),
    );
  }

  // This is widget to display doctor
  Widget displayListDoctor(List<UserGetDto> doctors) {
    return DropdownButtonFormField<UserGetDto>(
      value: doctorSelected,
      items:
          doctors.map((doctor) {
            return DropdownMenuItem<UserGetDto>(
              value: doctor,
              child: Text("BS. ${doctor.fullname}"),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          doctorSelected = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Chọn bác sĩ',
        border: OutlineInputBorder(),
      ),
    );
  }

  // This is function to pick date and time for in time booking kennel
  Future<void> _pickInTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: inTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != inTime) {
      setState(() {
        inTime = picked;
        if (outTime.isBefore(inTime)) {
          outTime = inTime.add(Duration(days: 1));
        }
        _updatePrice();
      });
    }
  }

  Future<void> _pickOutTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: outTime,
      firstDate: inTime.add(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != outTime) {
      setState(() {
        outTime = picked;
        _updatePrice();
      });
    }
  }

  void _updatePrice() {
    if (_selectedKennel != null) {
      final difference = outTime.difference(inTime);
      int days = difference.inDays;
      if (days == 0) {
        days = 1; // Minimum 1 day for same day bookings
      }
      const basePricePerDay = 50000;
      setState(() {
        _calculatedPrice =
            days * basePricePerDay * _selectedKennel!.priceMultiplier;
      });
    } else {
      setState(() {
        _calculatedPrice = 0.0;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (petSelected == null) {
          _showErrorSnackBar('Vui lòng chọn thú cưng');
          return false;
        }
        break;
      case 1:
        if (doctorSelected == null) {
          _showErrorSnackBar('Vui lòng chọn bác sĩ');
          return false;
        }
        break;
      case 2:
        if (_selectedKennel == null) {
          _showErrorSnackBar('Vui lòng chọn loại chuồng');
          return false;
        }
        break;
    }
    return true;
  }

  void _bookKennel() {
    if (!_validateCurrentStep()) return;

    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    BookKennelRequest bookKennelRequest = BookKennelRequest(
      formatter.format(inTime),
      formatter.format(outTime),
      _noteController.text,
      doctorSelected!.id,
      petSelected!.id,
      _selectedKennel!.id,
    );
    context.read<KennelDetailBloc>().add(
      BookKennelDetailStarted(bookKennelRequest),
    );
  }

  int _calculateDays() {
    final difference = outTime.difference(inTime);
    int days = difference.inDays;
    return days == 0 ? 1 : days;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Đặt lịch thành công',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Lịch lưu chuồng đã được đặt thành công!',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: backScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Đặt lịch thất bại',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(message, style: const TextStyle(fontSize: 16)),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildKennelDropdown(List<KennelDto> kennels) {
    // Reset selected kennel if it's not in the current list
    if (_selectedKennel != null && !kennels.contains(_selectedKennel)) {
      _selectedKennel = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<KennelDto>(
          decoration: MyInputDecoration.create("Chọn loại chuồng"),
          value: _selectedKennel,
          items:
              kennels.map((kennel) {
                return DropdownMenuItem(
                  value: kennel,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${kennel.name} - Loại chuồng: ${kennel.type == "NORMAL" ? "Bình thường" : "Đặc biệt"}',
                      maxLines: 2,
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (KennelDto? newValue) {
            setState(() {
              _selectedKennel = newValue;
              _updatePrice();
            });
          },
        ),
      ],
    );
  }

  String getPetAge(String? birthday) {
    if (birthday == null || birthday.isEmpty) {
      return "Đang cập nhật";
    }

    try {
      DateTime birthDate;

      if (birthday.contains("/")) {
        // "01/06/2020"
        birthDate = DateFormat("dd/MM/yyyy").parse(birthday);
      } else {
        // "2020-06-01"
        birthDate = DateTime.parse(birthday);
      }

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
      return "Đang cập nhật";
    }
  }
}

class StepData {
  final String title;
  final IconData icon;

  StepData(this.title, this.icon);
}
