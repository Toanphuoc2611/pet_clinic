import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_event.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/data/auth/local_data/auth_local_data_source.dart';
import 'package:ung_dung_thu_y/dto/address/Province.dart';
import 'package:ung_dung_thu_y/dto/address/district.dart';
import 'package:ung_dung_thu_y/dto/address/ward.dart';
import 'package:ung_dung_thu_y/dto/auth/register_dto.dart';
import 'package:ung_dung_thu_y/remote/address/address_api_client.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/remote/auth/auth_api_client.dart';
import 'package:ung_dung_thu_y/repository/address/address_repository.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:ung_dung_thu_y/ui/screen/login/login_view.dart';
import 'package:ung_dung_thu_y/ui/screen/register/otp_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late TextEditingController txtPhone;
  late TextEditingController txtEmail;
  late TextEditingController txtPassword;
  late TextEditingController txtPasswordRepeat;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullnameController =
      TextEditingController();
  late final TextEditingController _birthdayController =
      TextEditingController();
  late final TextEditingController _streetController = TextEditingController();
  late String address;
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];
  int? _selectedGender;
  late final AddressRepository addressRepository;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    txtPhone = TextEditingController();
    txtEmail = TextEditingController();
    txtPassword = TextEditingController();
    txtPasswordRepeat = TextEditingController();
    addressRepository = AddressRepository(AddressApiClient(ApiService(dio)));
    loadInitialAddress();
  }

  @override
  void dispose() {
    txtPhone.dispose();
    txtEmail.dispose();
    txtPassword.dispose();
    txtPasswordRepeat.dispose();
    _fullnameController.dispose();
    _birthdayController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> loadInitialAddress() async {
    await loadProvinces();
  }

  Future<void> loadProvinces() async {
    final data = await addressRepository.getProvinces();
    setState(() {
      provinces = data..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> loadDistricts(int provinceId) async {
    final data = await addressRepository.getDistricts(provinceId);
    setState(() {
      districts = data..sort((a, b) => a.name.compareTo(b.name));
      selectedDistrict = null;
      selectedWard = null;
      wards = [];
    });
  }

  Future<void> loadWards(int districtId) async {
    final data = await addressRepository.getWards(districtId);
    setState(() {
      wards = data;
      selectedWard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create:
          (context) => AuthRepository(
            authApiClient: AuthApiClient(dio),
            authLocalDataSource: AuthLocalDataSource(storage),
          ),
      child: BlocProvider(
        create: (context) => AuthBloc(context.read<AuthRepository>()),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Đăng ký",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _displayFormInformation(context),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView()),
                      );
                    },
                    child: Text(
                      "Đã có tài khoản?",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSendOtpFailure) {
                        _showErrorDialog(
                          context,
                          _getErrorMessage(state.message),
                        );
                      }
                    },
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return (switch (state) {
                          AuthSendOtpInProgress() => Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Đang xử lý...",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _ => RoundButton(
                            onPressed: () {
                              _handleRegister(context);
                            },
                            title: "Đăng ký",
                            bgColor: Colors.blue,
                            textColor: TColor.white,
                          ),
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _displayFormInformation(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // fullname
          TextFormField(
            controller: _fullnameController,
            decoration: _inputDecoration("Họ và tên", icon: Icons.person),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập họ và tên";
              } else if (value.trim().length < 2) {
                return "Họ và tên phải có ít nhất 2 ký tự";
              } else if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value)) {
                return "Họ và tên chỉ được chứa chữ cái và khoảng trắng";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // birthday
          TextFormField(
            controller: _birthdayController,
            readOnly: true,
            decoration: _inputDecoration(
              "Ngày sinh",
              icon: Icons.calendar_today,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng chọn ngày sinh";
              }
              return null;
            },
            onTap: () async {
              FocusScope.of(context).unfocus();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now().subtract(Duration(days: 365 * 13)),
              );
              if (pickedDate != null) {
                _birthdayController.text = FormatDate.formatDatePicker(
                  pickedDate,
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // gender
          DropdownButtonFormField<int>(
            value: _selectedGender,
            decoration: _inputDecoration("Giới tính", icon: Icons.wc),
            validator: (value) {
              if (value == null) {
                return "Vui lòng chọn giới tính";
              }
              return null;
            },
            items: const [
              DropdownMenuItem(value: 1, child: Text("Nam")),
              DropdownMenuItem(value: 0, child: Text("Nữ")),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // province
          DropdownButtonFormField<Province>(
            value: selectedProvince,
            decoration: _inputDecoration(
              "Tỉnh/Thành phố",
              icon: Icons.location_city,
            ),
            isExpanded: true,
            itemHeight: 70,
            validator: (value) {
              if (value == null) {
                return "Vui lòng chọn tỉnh/thành phố";
              }
              return null;
            },
            items:
                provinces.map((province) {
                  return DropdownMenuItem(
                    value: province,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        province.name,
                        style: TextStyle(fontSize: 16, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedProvince = value;
                selectedDistrict = null;
                selectedWard = null;
                wards = [];
                if (value != null) loadDistricts(value.id);
              });
            },
          ),
          const SizedBox(height: 16),

          // district
          DropdownButtonFormField<District>(
            value: selectedDistrict,
            decoration: _inputDecoration("Quận/Huyện", icon: Icons.location_on),
            isExpanded: true,
            itemHeight: 70,
            validator: (value) {
              if (value == null) {
                return "Vui lòng chọn quận/huyện";
              }
              return null;
            },
            items:
                districts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        district.name,
                        style: TextStyle(fontSize: 16, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedDistrict = value;
                selectedWard = null;
                wards = [];
                if (value != null) loadWards(value.id);
              });
            },
          ),
          const SizedBox(height: 16),

          // ward
          DropdownButtonFormField<Ward>(
            value: selectedWard,
            decoration: _inputDecoration("Phường/Xã", icon: Icons.place),
            isExpanded: true,
            itemHeight: 70,
            validator: (value) {
              if (value == null) {
                return "Vui lòng chọn phường/xã";
              }
              return null;
            },
            items:
                wards.map((ward) {
                  return DropdownMenuItem(
                    value: ward,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        ward.name,
                        style: TextStyle(fontSize: 16, height: 1.2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                selectedWard = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // street
          TextFormField(
            controller: _streetController,
            decoration: _inputDecoration("Tên đường / số nhà"),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? "Vui lòng nhập tên đường"
                        : null,
          ),
          const SizedBox(height: 16),
          // phone number
          TextFormField(
            controller: txtPhone,
            decoration: _inputDecoration("Số điện thoại", icon: Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập số điện thoại";
              } else if (!_isValidPhoneNumber(value)) {
                return "Số điện thoại không đúng định dạng";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // email
          TextFormField(
            controller: txtEmail,
            decoration: _inputDecoration("Email", icon: Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập địa chỉ email";
              } else if (!_isValidEmail(value)) {
                return "Địa chỉ email không đúng định dạng";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // password
          TextFormField(
            controller: txtPassword,
            decoration: _inputDecoration("Mật khẩu", icon: Icons.lock),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập mật khẩu";
              } else if (!_isValidPassword(value)) {
                return "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa và ký tự đặc biệt";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // confirm password
          TextFormField(
            controller: txtPasswordRepeat,
            decoration: _inputDecoration("Nhập lại mật khẩu", icon: Icons.lock),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Vui lòng nhập lại mật khẩu";
              } else if (value != txtPassword.text) {
                return "Mật khẩu không khớp";
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Handle register logic
  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate() &&
        selectedProvince != null &&
        selectedDistrict != null &&
        selectedWard != null &&
        _selectedGender != null) {
      address =
          "${_streetController.text}, ${selectedWard!.name}, ${selectedDistrict!.name}, ${selectedProvince!.name}";

      RegisterDto registerDto = RegisterDto(
        email: txtEmail.text.trim(),
        phoneNumber: txtPhone.text.trim(),
        password: txtPassword.text.trim(),
        address: address,
        fullname: _fullnameController.text.trim(),
        birthday: FormatDate.formatRequest(_birthdayController.text),
        gender: _selectedGender ?? 1,
        otp: "", // OTP will be handled in OtpView
      );

      context.read<AuthBloc>().add(AuthsendOtpStarted(registerDto.email));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpView(registerDto: registerDto),
        ),
      );
    } else {
      _showValidationDialog(context, "Vui lòng điền đầy đủ thông tin bắt buộc");
    }
  }

  // Method hiển thị dialog validation
  void _showValidationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 10),
              const Text(
                "Thông báo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Đã hiểu"),
            ),
          ],
        );
      },
    );
  }

  // Method hiển thị dialog lỗi
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text(
                "Đăng ký thất bại",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Thử lại"),
            ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(String originalMessage) {
    if (originalMessage.toLowerCase().contains('network') ||
        originalMessage.toLowerCase().contains('connection')) {
      return "Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.";
    }

    if (originalMessage.toLowerCase().contains('phone number already exists') ||
        originalMessage.toLowerCase().contains('duplicate')) {
      return "Số điện thoại này đã được đăng ký. Vui lòng sử dụng số điện thoại khác.";
    }

    if (originalMessage.toLowerCase().contains('timeout')) {
      return "Kết nối bị gián đoạn. Vui lòng thử lại sau ít phút.";
    }

    if (originalMessage.toLowerCase().contains('server error') ||
        originalMessage.toLowerCase().contains('500')) {
      return "Hệ thống đang bảo trì. Vui lòng thử lại sau ít phút.";
    }

    if (originalMessage.toLowerCase().contains('invalid format')) {
      return "Thông tin không đúng định dạng. Vui lòng kiểm tra lại.";
    }

    return "Đã xảy ra lỗi trong quá trình đăng ký. Vui lòng thử lại sau ít phút.";
  }

  // Validation methods
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^0[0-9]{9,10}$').hasMatch(phone);
  }

  bool _isValidPassword(String password) {
    // Mật khẩu phải có ít nhất 8 ký tự, có chữ hoa và ký tự đặc biệt
    if (password.length < 8) return false;

    // Kiểm tra có chữ hoa
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;

    // Kiểm tra có ký tự đặc biệt
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;

    return true;
  }

  // design input decoration
  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
      isDense: true,
    );
  }
}
