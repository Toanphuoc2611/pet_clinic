import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';

class CardDisplayPet extends StatelessWidget {
  final PetGetDto petGetDto;
  const CardDisplayPet({super.key, required this.petGetDto});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: ListTile(
          onTap: () {
            context.push(RouteName.petDetail, extra: petGetDto);
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/image/pet_default.jpg",
              image:
                  petGetDto.avatar ??
                  "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678351/pet_default_vg54u5.jpg",
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, _) {
                return Image.asset(
                  "assets/image/pet_default.jpg",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          title: Text(
            "Tên: ${petGetDto.name}" ?? "Không có tên",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month, color: TColor.secondText),
                  SizedBox(width: 5),
                  Text(
                    petGetDto.birthday != null
                        ? _birthdayToAge(petGetDto.birthday!)
                        : "Chưa cập nhật",

                    style: TextStyle(color: TColor.secondText, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.male, color: TColor.secondText),
                  SizedBox(width: 5),
                  Text(
                    petGetDto.gender != null
                        ? (petGetDto.gender == 0 ? "Đực" : "Cái")
                        : "Chưa xác định",
                    style: TextStyle(color: TColor.secondText, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This is function to calculation age of pet from birthday
  String _birthdayToAge(String birthday) {
    DateTime birthDate = DateTime.parse(birthday);
    DateTime today = DateTime.now();

    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months -= 1;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years == 0) {
      return '$months tháng';
    }
    return '$years năm $months tháng';
  }
}
