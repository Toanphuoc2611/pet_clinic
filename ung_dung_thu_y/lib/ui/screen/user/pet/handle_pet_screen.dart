import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_bloc.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_event.dart';
import 'package:ung_dung_thu_y/bloc/pet/pet_state.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_add_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/result_file.dart';
import 'package:ung_dung_thu_y/repository/pet/pet_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/button_back_screen.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_app_bar.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';

class HandlePetScreen extends StatefulWidget {
  final PetGetDto? pet;
  const HandlePetScreen({super.key, this.pet});

  @override
  State<HandlePetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<HandlePetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(
          "Thêm thú cưng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: ButtonBackScreen(onPress: backScreen),
      ),
      body: _FormAddPet(key: _formKey),
    );
  }

  void backScreen() {
    context.read<PetBloc>().add(PetGetStarted());
    Navigator.of(context).pop();
  }
}

class FormUpdatePet extends StatefulWidget {
  const FormUpdatePet({super.key});

  @override
  State<FormUpdatePet> createState() => _FormUpdatePetState();
}

class _FormUpdatePetState extends State<FormUpdatePet> {
  @override
  Widget build(BuildContext context) {
    return const Text("Hello Form Update Pet");
  }
}

class _FormAddPet extends StatefulWidget {
  const _FormAddPet({super.key});

  @override
  State<_FormAddPet> createState() => __FormAddPetState();
}

class __FormAddPetState extends State<_FormAddPet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final Map<int, String> species = {1: "Chó", 2: "Mèo", 3: "Khác"};
  String? _selectedSpecies;
  int? _selectedSpeciesId;
  final _breedController = TextEditingController();
  List<String> _breeds = [];
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  final _birthdayController = TextEditingController();

  int? _gender;
  int? _isNeutered;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String? _nullIfEmpty(String text) =>
          text.trim().isEmpty ? null : text.trim();
      final petAddDto = PetAddDto(
        name: _nameController.text,
        type: _nullIfEmpty(_selectedSpecies!),
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
      );
      _handleAddPet(petAddDto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: BlocListener<PetBloc, PetState>(
        listener: (context, state) {
          if (state is PetAddSuccess) {
            _showSuccessDialog();
          }
        },
        child: BlocBuilder<PetBloc, PetState>(
          builder: (context, state) {
            return (switch (state) {
              PetAddInititial() => _diplayForm(),
              PetAddInProgress() => Center(child: CircularProgressIndicator()),
              PetAddSuccess() => _diplayForm(),
              PetAddFailure() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Có lỗi xảy ra khi thêm thú cưng. Vui lòng thử lại.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Reload form
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              _ => Container(),
            });
          },
        ),
      ),
    );
  }

  Widget _diplayForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // name pet
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration("Tên thú cưng"),
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? "Vui lòng nhập tên thú cưng"
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
            value: _gender,
            decoration: _inputDecoration("Giới tính"),
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
          const SizedBox(height: 16),

          // species
          DropdownButtonFormField<int>(
            value: _selectedSpeciesId, // phải là int, ví dụ 1, 2, 3
            decoration: _inputDecoration("Loài"),
            isExpanded: true,
            itemHeight: 70,
            items:
                species.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 70),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        entry.value,
                        style: TextStyle(fontSize: 16, height: 1.2),
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

          // isNeutered
          DropdownButtonFormField<int>(
            value: _isNeutered,
            onChanged: (val) => setState(() => _isNeutered = val),
            decoration: _inputDecoration("Đã triệt sản?"),
            items: const [
              DropdownMenuItem(value: 1, child: Text("Rồi")),
              DropdownMenuItem(value: 0, child: Text("Chưa")),
            ],
          ),
          const SizedBox(height: 16),

          // street
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: "Ghi chú"),
            maxLines: 2,
          ),

          const SizedBox(height: 32),
          Align(
            alignment: Alignment.bottomCenter,
            child: RoundButton(
              onPressed: _submitForm,
              title: "Thêm thú cưng",
              bgColor: Colors.blue,
              textColor: TColor.white,
            ),
          ),
        ],
      ),
    );
  }

  // load breeds by species
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
      _showErrorSnackBar(
        'Không thể tải danh sách giống thú cưng. Vui lòng thử lại.',
      );
    } else {
      _showErrorSnackBar('Có lỗi xảy ra. Vui lòng thử lại sau.');
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

  void _handleAddPet(PetAddDto petAddDto) {
    context.read<PetBloc>().add(PetAddStarted(petAddDto));
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
                  'Thêm thú cưng thành công',
                  style: TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Thú cưng đã được thêm thành công!',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
