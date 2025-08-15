import 'package:flutter/material.dart';

class CardDisplayUser extends StatelessWidget {
  final String? userId;
  final String fullName;
  final String? avatar;
  final String phoneNumber;
  final VoidCallback pressed;
  const CardDisplayUser({
    super.key,
    this.userId,
    required this.fullName,
    this.avatar,
    required this.phoneNumber,
    required this.pressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pressed,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child:
                    avatar != null && avatar!.startsWith('http')
                        ? FadeInImage.assetNetwork(
                          placeholder: "assets/image/avatar_default.jpg",
                          image:
                              avatar ??
                              "http://res.cloudinary.com/dgyg2m4ay/image/upload/v1748678194/avatar_default_a1gudv.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/image/avatar_default.jpg",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                        : Image.asset(
                          "assets/image/avatar_default.jpg",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    phoneNumber,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
