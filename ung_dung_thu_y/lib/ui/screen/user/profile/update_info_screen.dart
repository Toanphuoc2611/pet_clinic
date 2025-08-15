import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_bloc.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_event.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_state.dart';
import 'package:ung_dung_thu_y/bloc/user/user_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user/user_event.dart';
import 'package:ung_dung_thu_y/bloc/user/user_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/dto/address/Province.dart';
import 'package:ung_dung_thu_y/dto/address/district.dart';
import 'package:ung_dung_thu_y/dto/address/ward.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_avatar.dart';
import 'package:ung_dung_thu_y/dto/user/user_update_dto.dart';
import 'package:ung_dung_thu_y/remote/address/address_api_client.dart';
import 'package:ung_dung_thu_y/remote/api_service.dart';
import 'package:ung_dung_thu_y/repository/address/address_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class UpdateInfoScreen extends StatefulWidget {
  final UserGetDto user;
  const UpdateInfoScreen({super.key, required this.user});

  @override
  State<UpdateInfoScreen> createState() => _UpdateInfoScreenState();
}

class _UpdateInfoScreenState extends State<UpdateInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullnameController = TextEditingController(
    text: widget.user.fullname ?? "",
  );
  late final TextEditingController _birthdayController = TextEditingController(
    text: formatDate(widget.user.birthday),
  );
  late final TextEditingController _streetController = TextEditingController();
  late String address = widget.user.address ?? "";
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  List<Province> provinces = [];
  List<District> districts = [];
  List<Ward> wards = [];
  int? _selectedGender;
  late final AddressRepository addressRepository;
  File? _localAvatar;
  @override
  void initState() {
    super.initState();
    _selectedGender = widget.user.gender;
    addressRepository = AddressRepository(AddressApiClient(ApiService(dio)));
    loadInitialAddress();
  }

  Future<void> loadInitialAddress() async {
    await loadProvinces();
    splitAddress(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cập nhật thông tin"),
        backgroundColor: TColor.primary,
        foregroundColor: TColor.white,
        actions: [
          IconButton(icon: const Icon(Icons.qr_code), onPressed: _scanCCCD),
        ],
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            _showSuccessDialog();
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            return (switch (state) {
              UserUpdateInProgress() => Center(
                child: CircularProgressIndicator(),
              ),
              UserUpdateFailure() => Center(child: Text(state.message)),
              _ => _displayInformation(context),
            });
          },
        ),
      ),
    );
  }

  // Display screen details information of user
  Widget _displayInformation(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          displayHeaderUserDetail(widget.user.avatar),
          const SizedBox(height: 20),
          _displayFormInformation(context),
        ],
      ),
    );
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
                  'Cập nhật thông tin thành công',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Thông tin cá nhân đã được cập nhật thành công!',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  context.read<UserBloc>().add(
                    UserGetStarted(),
                  ); // Refresh user data
                  Navigator.pop(context); // Quay về màn hình trước
                },
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

  Future<void> loadWards(int districtId) async {
    final data = await addressRepository.getWards(districtId);
    setState(() {
      wards = data;
      selectedWard = null;
    });
  }

  // Display avatar user
  Widget displayHeaderUserDetail(String? avatar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar
        BlocBuilder<UploadAvatarBloc, UploadAvatarState>(
          builder: (context, state) {
            return (switch (state) {
              UploadAvatarInProgree() => Center(
                child: CircularProgressIndicator(),
              ),
              UploadAvatarSuccess() => displayAvatar(state.url),
              UploadAvatarFailure() => Text(state.message),
              _ => displayAvatar(widget.user.avatar),
            });
          },
        ),
      ],
    );
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }
    final updatedAt = DateTime.parse(date);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(updatedAt.day)}/${twoDigits(updatedAt.month)}/${updatedAt.year}";
  }

  Widget displayAvatar(String? avatar) {
    if (avatar != widget.user.avatar) {
      avatar = widget.user.avatar;
    }
    final image =
        _localAvatar != null
            ? Image.file(
              _localAvatar!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            )
            : FadeInImage.assetNetwork(
              placeholder: "assets/image/avatar_default.jpg",
              image:
                  avatar ??
                  "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/image/avatar_default.jpg",
                  width: 120,
                  height: 120,
                );
              },
            );
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(50), child: image),
        Positioned(
          bottom: -10,
          right: -10,
          child: IconButton(
            onPressed: () async {
              final file = await _handleUploadAvatar();
              if (file != null) {
                setState(() {
                  _localAvatar = file;
                });
                context.read<UploadAvatarBloc>().add(
                  UploadAvatarUserStarted(UserUpdateAvatar(file)),
                );
              }
            },
            icon: Icon(Icons.camera_alt_rounded, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Future<File> _handleUploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Thông báo"),
            content: Text("Bạn chưa chọn ảnh nào"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    final rawImage = await File(pickedFile!.path).readAsBytes();
    int originalSize = rawImage.length;

    // If the file is already less than or equal to 1MB, return it as is
    if (originalSize <= 1024 * 1024) {
      return File(pickedFile.path);
    }

    // Read and decode the image
    final decodedImage = img.decodeImage(rawImage);
    if (decodedImage == null) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Thông báo"),
            content: Text("Không thể đọc ảnh. Vui lòng chọn ảnh khác."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      throw Exception("Failed to decode image");
    }

    // Resize and compress the image with a maximum width
    // of 800 pixels and quality of 75%

    final resized = img.copyResize(decodedImage!, width: 800);
    final compressedBytes = img.encodeJpg(resized, quality: 75);

    if (compressedBytes.length > 1024 * 1024) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("Thông báo"),
            content: Text("Ảnh có kích thước quá lớn. Vui lòng chọn ảnh khác."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      throw Exception("Compressed image is still larger than 1MB");
    }
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');

    await compressedFile.writeAsBytes(compressedBytes);
    return compressedFile;
  }

  // display information form
  Widget _displayFormInformation(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Thông tin cá nhân",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // fullname
          TextFormField(
            controller: _fullnameController,
            decoration: _inputDecoration("Họ và tên"),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? "Vui lòng nhập họ và tên"
                        : null,
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
            onTap: () async {
              FocusScope.of(context).unfocus();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
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
            decoration: _inputDecoration("Giới tính"),
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
            decoration: _inputDecoration("Tỉnh/Thành phố"),
            isExpanded: true,
            itemHeight: 70,
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
            decoration: _inputDecoration("Quận/Huyện"),
            isExpanded: true,
            itemHeight: 70,
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
            decoration: _inputDecoration("Phường/Xã"),
            isExpanded: true,
            itemHeight: 70,
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

          const SizedBox(height: 32),
          RoundButton(
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  selectedProvince != null &&
                  selectedDistrict != null &&
                  selectedWard != null) {
                address =
                    "${_streetController.text}, ${selectedWard!.name}, ${selectedDistrict!.name}, ${selectedProvince!.name}";
                UserUpdateDto user = UserUpdateDto(
                  id: widget.user.id,
                  fullname: _fullnameController.text,
                  gender: _selectedGender,
                  birthday: FormatDate.formatRequest(_birthdayController.text),
                  address: address,
                );
                _handleUpdate(user);
              }
            },
            title: "Cập nhật thông tin",
            bgColor: Colors.blue,
            textColor: TColor.white,
          ),
        ],
      ),
    );
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

  void splitAddress(String? address) async {
    if (address == null || address.isEmpty) {
      return;
    } else {
      List<String> parts = address.split(',').map((e) => e.trim()).toList();
      if (parts.length >= 4) {
        String street = parts.sublist(0, parts.length - 3).join(', ');
        _streetController.text = street;
        String provinceName = parts[parts.length - 1];
        String districtName = parts[parts.length - 2];
        String wardName = parts[parts.length - 3];
        handleAddress(provinceName, districtName, wardName);
      }
    }
  }

  void handleAddress(
    String provinceName,
    String districtName,
    String wardName,
  ) async {
    if (provinces.isEmpty) {
      return;
    }
    final province = provinces.firstWhere(
      (province) => province.name == provinceName,
    );
    if (province != null) {
      await loadDistricts(province!.id);
      final district = districts.firstWhere(
        (district) => district.name == districtName,
      );
      if (district != null) {
        await loadWards(district!.id);
        final ward = wards.firstWhere((ward) => ward.name == wardName);
        setState(() {
          selectedProvince = province;
          selectedDistrict = district;
          selectedWard = ward;
        });
      }
    }
  }

  void _handleUpdate(UserUpdateDto user) {
    context.read<UserBloc>().add(
      UserUpdateStarted(
        id: user.id,
        address: user.address,
        fullname: user.fullname,
        gender: user.gender,
        birthday: user.birthday,
      ),
    );
  }

  Future<void> _scanCCCD() async {
    final scannedData = await context.push<String>('/qr_screen');
    if (scannedData != null) {
      _processScannedData(scannedData);
    }
  }

  void _processScannedData(String scannedData) {
    List<String> parts = scannedData.split('|');
    if (parts.length >= 4) {
      setState(() {
        _fullnameController.text = parts[2];
        String rawDate = parts[3];
        String day = rawDate.substring(0, 2);
        String month = rawDate.substring(2, 4);
        String year = rawDate.substring(4);
        String formattedDate = "$year-$month-$day";
        _birthdayController.text = formattedDate;
        _selectedGender = (parts[4] == "Nam") ? 1 : 0;
        splitAddress(parts[5]);
      });
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _birthdayController.dispose();
    _streetController.dispose();
    super.dispose();
  }
}
