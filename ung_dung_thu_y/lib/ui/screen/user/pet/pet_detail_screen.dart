import 'dart:async';
import 'dart:io';
import 'package:barcode/barcode.dart' as bc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ung_dung_thu_y/bloc/doctor/medical_record/medical_record_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_bloc.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_event.dart';
import 'package:ung_dung_thu_y/bloc/upload_avatar/upload_avatar_state.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_avatar.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_update_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/button_back_screen.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_app_bar.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:ung_dung_thu_y/ui/screen/user/pet/medical_record/pet_medical_record_screen.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class PetDetailScreen extends StatefulWidget {
  late PetGetDto pet;
  PetDetailScreen({required this.pet, super.key});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  bool isEditing = false;
  late TextEditingController _weightController;
  late TextEditingController _noteController;
  String? _selectedBreed;
  int? _isNeutered;

  List<String> _breeds = [];
  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.pet.weight.toString(),
    );
    _noteController = TextEditingController(text: widget.pet.note ?? "");
    _selectedBreed = widget.pet.breed;
    _isNeutered = widget.pet.isNeutered;
    if (widget.pet.type != null) {
      _loadBreedsBySpecies(widget.pet.type!);
    }
  }

  void _loadBreedsBySpecies(String species_id) async {
    if (species_id == "Mèo") {
      species_id = "2";
    } else if (species_id == "Chó") {
      species_id = "1";
    }
    PetRepository petRepository = context.read<PetRepository>();
    if (species_id.isEmpty) {
      setState(() {
        _breeds = [];
      });
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(widget.pet.id),
      appBar: MyAppBar(
        title: Text(
          "Chi tiết thú cưng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: ButtonBackScreen(onPress: backScreen),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: MultiBlocListener(
          listeners: [
            BlocListener<PetBloc, PetState>(
              listener: (context, state) {
                if (state is PetDeleteSuccess) {
                  if (state.isDeleted) {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("Thông báo"),
                          content: Text("Xóa thú cưng thành công"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                backScreen();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text("Thông báo"),
                          content: Text("Xóa thú cưng thất bại"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                backScreen();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else if (state is PetDeleteFailure) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Xóa thú cưng thất bại"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              backScreen();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
                if (state is PetUpdateSuccess) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Cập nhật thú cưng thành công"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                  setState(() {
                    widget.pet = state.petGetDto;
                    isEditing = false;
                  });
                } else if (state is PetUpdateFailure) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Thông báo"),
                        content: Text("Cập nhật thú cưng thất bại"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            BlocListener<UploadAvatarBloc, UploadAvatarState>(
              listener: (context, state) {
                if (state is UploadAvatarSuccess) {
                  setState(() {
                    widget.pet.avatar = state.url;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Cập nhật ảnh đại diện thành công'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state is UploadAvatarFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cập nhật ảnh đại diện thất bại: ${state.message}',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              children: [
                displayHeaderPetDetail(
                  widget.pet.avatar,
                  widget.pet.name,
                  widget.pet.updateAt,
                ),
                SizedBox(height: 10),
                displayInfor(),
                SizedBox(height: 10),
                // Display note of pet
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ghi chú",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          isEditing
                              ? TextFormField(
                                controller: _noteController,
                                decoration: InputDecoration(
                                  hintText: "Nhập ghi chú",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              )
                              : Text(
                                widget.pet.note ?? "Đang cập nhật",
                                style: TextStyle(fontSize: 18),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Button to view medical record
                if (!isEditing) ...[
                  RoundButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  PetMedicalRecordScreen(pet: widget.pet),
                        ),
                      );
                    },
                    title: "Xem hồ sơ bệnh án",
                    bgColor: TColor.primary,
                    textColor: TColor.white,
                  ),
                  SizedBox(height: 10),
                ],
                isEditing
                    ? RoundButton(
                      onPressed: () {
                        print("Weight: ${_weightController.text}");
                        PetUpdateDto petUpdateDto = PetUpdateDto(
                          breed: _selectedBreed ?? "",
                          weight:
                              double.tryParse(_weightController.text) ?? 0.0,
                          isNeutered: _isNeutered ?? 0,
                          note: _noteController.text,
                        );
                        context.read<PetBloc>().add(
                          PetUpdateStarted(widget.pet.id, petUpdateDto),
                        );
                      },
                      title: "Xác nhận chỉnh sửa",
                      bgColor: Colors.blue,
                      textColor: TColor.white,
                    )
                    : RoundButton(
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                      title: "Chỉnh sửa thông tin",
                      bgColor: Colors.blue,
                      textColor: TColor.white,
                    ),
                SizedBox(height: 10),
                BlocBuilder<PetBloc, PetState>(
                  builder: (context, state) {
                    return (switch (state) {
                      PetDeleteInProgress() => Center(
                        child: CircularProgressIndicator(),
                      ),
                      _ =>
                        isEditing
                            ? RoundButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                });
                              },
                              title: "Huy bỏ chỉnh sửa",
                              bgColor: Colors.red,
                              textColor: TColor.white,
                            )
                            : RoundButton(
                              onPressed: () {
                                context.read<PetBloc>().add(
                                  PetDeleteStarted(widget.pet.id),
                                );
                              },
                              title: "Xóa thú cưng",
                              bgColor: Colors.red,
                              textColor: TColor.white,
                            ),
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void backScreen() {
    context.read<PetBloc>().add(PetGetStarted());
    Navigator.of(context).pop();
  }

  Widget displayHeaderPetDetail(String? avatar, String name, String updateAt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Avatar
        BlocBuilder<UploadAvatarBloc, UploadAvatarState>(
          builder: (context, state) {
            return (switch (state) {
              UploadAvatarInProgree() => Stack(
                alignment: Alignment.center,
                children: [
                  // Hiển thị ảnh cũ mờ đi trong khi upload
                  Opacity(
                    opacity: 0.5,
                    child: displayAvatar(widget.pet.avatar),
                  ),
                  // Hiển thị loading indicator với text
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Đang tải...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              UploadAvatarSuccess() => displayAvatar(state.url),
              UploadAvatarFailure() => Stack(
                alignment: Alignment.center,
                children: [
                  displayAvatar(widget.pet.avatar),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.error, color: Colors.white, size: 16),
                  ),
                ],
              ),
              _ => displayAvatar(widget.pet.avatar),
            });
          },
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Ngày cập nhật: ${formatDate(widget.pet.updateAt)}",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // Display avatar
  Widget displayAvatar(String? avatar) {
    // Add cache-busting parameter to force reload when image changes
    String imageUrl =
        avatar ??
        "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678351/pet_default_vg54u5.jpg";
    if (avatar != null && avatar.isNotEmpty) {
      // Add timestamp parameter to bust cache for new images
      final separator = avatar.contains('?') ? '&' : '?';
      imageUrl =
          '$avatar${separator}t=${DateTime.now().millisecondsSinceEpoch}';
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: FadeInImage.assetNetwork(
            key: ValueKey('${widget.pet.id}_${avatar ?? 'default'}'),
            placeholder: "assets/image/pet_default.jpg",
            image: imageUrl,
            height: 120,
            width: 120,
            fit: BoxFit.cover,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                "assets/image/pet_default.jpg",
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Positioned(
          bottom: -10,
          right: -10,
          child: IconButton(
            onPressed: () => _showImageSourceDialog(),
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

  // format date to dd/mm/yyyy
  String formatDate(String date) {
    final updatedAt = DateTime.parse(date);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(updatedAt.day)}/${twoDigits(updatedAt.month)}/${updatedAt.year}";
  }

  // Show dialog to choose image source
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chọn nguồn ảnh',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.blue),
                title: Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImageAndPreview(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: Colors.green),
                title: Text('Chụp ảnh'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImageAndPreview(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Select image and show preview
  Future<void> _selectImageAndPreview(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (pickedFile != null) {
      final processedFile = await _processImage(File(pickedFile.path));
      if (processedFile != null) {
        // Show preview dialog
        _showImagePreviewDialog(processedFile);
      }
    }
  }

  // Show image preview with 5 second timer
  void _showImagePreviewDialog(File imageFile) {
    int countdown = 5;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start countdown timer
            timer ??= Timer.periodic(Duration(seconds: 1), (t) {
              setState(() {
                countdown--;
              });

              if (countdown <= 0) {
                t.cancel();
                Navigator.of(dialogContext).pop();
                _uploadImage(imageFile);
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with countdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Xem trước ảnh',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: countdown <= 2 ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${countdown}s',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Image preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        imageFile,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              timer?.cancel();
                              Navigator.of(dialogContext).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Hủy'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              timer?.cancel();
                              Navigator.of(dialogContext).pop();
                              _uploadImage(imageFile);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Xác nhận'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Auto upload info
                    Text(
                      'Ảnh sẽ tự động được tải lên sau ${countdown} giây',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Process image (compress and resize)
  Future<File?> _processImage(File imageFile) async {
    try {
      final rawImage = await imageFile.readAsBytes();
      int originalSize = rawImage.length;

      // If file is small enough, return as is
      if (originalSize <= 2 * 1024 * 1024) {
        // 2MB
        return imageFile;
      }

      // Read and decode the image
      final decodedImage = img.decodeImage(rawImage);
      if (decodedImage == null) {
        _showErrorDialog("Không thể đọc ảnh. Vui lòng chọn ảnh khác.");
        return null;
      }

      // Resize for avatar (400px is enough for avatar)
      final resized = img.copyResize(decodedImage, width: 400);
      final compressedBytes = img.encodeJpg(resized, quality: 85);

      // If still too large, compress more
      if (compressedBytes.length > 2 * 1024 * 1024) {
        final moreCompressed = img.encodeJpg(resized, quality: 60);
        if (moreCompressed.length > 2 * 1024 * 1024) {
          _showErrorDialog(
            "Ảnh có kích thước quá lớn. Vui lòng chọn ảnh khác.",
          );
          return null;
        }

        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final compressedFile = File(
          '${tempDir.path}/compressed_$timestamp.jpg',
        );
        await compressedFile.writeAsBytes(moreCompressed);
        return compressedFile;
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedFile = File('${tempDir.path}/compressed_$timestamp.jpg');
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      _showErrorDialog("Lỗi xử lý ảnh: $e");
      return null;
    }
  }

  // Upload image
  void _uploadImage(File imageFile) {
    context.read<UploadAvatarBloc>().add(
      UploadAvatarPetStarted(PetUpdateAvatar(imageFile, widget.pet.id)),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Thông báo"),
          content: Text(message),
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

  // Display information detail of pet
  Widget displayInfor() {
    return Stack(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: displayItem(
                        "Ngày sinh",
                        FormatDate.formatDate(widget.pet.birthday).isEmpty
                            ? "Đang cập nhật"
                            : FormatDate.formatDate(widget.pet.birthday),
                      ),
                    ),
                    Expanded(
                      child: displayItem(
                        "Loại",
                        widget.pet.type ?? "Đang cập nhật",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                          isEditing
                              ? DropdownButtonFormField<int>(
                                value: _isNeutered,
                                onChanged:
                                    (val) => setState(() => _isNeutered = val),
                                decoration: InputDecoration(
                                  labelText: "Triệt sản",
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text("Đã triệt sản"),
                                  ),
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text("Chưa triệt sản"),
                                  ),
                                ],
                              )
                              : displayItem(
                                "Triệt sản",
                                widget.pet.isNeutered == 0
                                    ? "Chưa triệt sản"
                                    : "Đã triệt sản",
                              ),
                    ),
                    Expanded(
                      child: displayItem(
                        "Màu lông",
                        widget.pet.color ?? "Đang cập nhật",
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: displayItem(
                        "giới tính",
                        widget.pet.gender == 0 ? "Đực" : "Cái",
                      ),
                    ),
                    Expanded(
                      child:
                          isEditing
                              ? TextFormField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: "Cân nặng",
                                ),
                                keyboardType: TextInputType.number,
                              )
                              : displayItem(
                                "Cân nặng",
                                widget.pet.weight.toString(),
                              ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                isEditing
                    ? DropdownButtonFormField<String>(
                      value: _selectedBreed,
                      decoration: InputDecoration(
                        labelText: "Giống",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      isExpanded: true,
                      itemHeight: null, // Allow items to wrap
                      items:
                          _breeds.map((breed) {
                            return DropdownMenuItem<String>(
                              value: breed,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                                child: Text(
                                  breed,
                                  style: TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBreed = value;
                        });
                      },
                    )
                    : displayItem("Giống", widget.pet.breed ?? "Đang cập nhật"),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: () {
              displayCode(widget.pet.id);
            },
            icon: Icon(Icons.qr_code, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget displayItem(String title, String content) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          content,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Creation barcode
  void displayCode(String data) {
    String svgCode = bc.Barcode.code128().toSvg(
      data,
      width: 250,
      height: 150,
      drawText: false,
    );
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SvgPicture.string(svgCode),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
