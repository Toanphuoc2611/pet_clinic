import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_event.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/core/services/websocket_service.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_textfield.dart';
import 'package:ung_dung_thu_y/ui/screen/register/register_view.dart';

class LoginView extends StatefulWidget {
  final WebSocketService _webSocketService = WebSocketService.instance;
  LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController txtEmail;
  late TextEditingController txtPassword;

  @override
  void initState() {
    super.initState();
    txtEmail = TextEditingController();
    txtPassword = TextEditingController();
  }

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    super.dispose();
  }

  Future<void> initialWebSocket(String role, String userId) async {
    await widget._webSocketService.connect(role, userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Đăng nhập",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 80),
              RoundTitleTextfield(
                hintText: "Nhập email",
                title: "Email",
                controller: txtEmail,
              ),
              const SizedBox(height: 20),
              RoundTitleTextfield(
                hintText: "Nhập mật khẩu",
                title: "Mật khẩu",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              TextButton(
                onPressed: () {},
                child: Text(
                  "Quên mật khẩu?",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoginSuccess) {
                    final role = state.inforToken['role'];
                    final userId = state.inforToken['userId'];
                    initialWebSocket(role!, userId!);
                    OneSignal.login(userId);
                    Future.delayed(Duration(seconds: 5), () async {
                      final subscription =
                          await OneSignal.User.pushSubscription;

                      print("Is subscription in: ${subscription.toString()}");
                      print("Is subscription in: ${subscription.optedIn}");
                    });
                    if (role == "DOCTOR") {
                      context.go(RouteName.doctorMain);
                    } else if (role == "USER") {
                      context.go(RouteName.main);
                    }
                  } else if (state is AuthLoginFailure) {
                    _showErrorDialog(context, state.message);
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return (switch (state) {
                      AuthLoginInProgress() => Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: TColor.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: TColor.primary.withOpacity(0.3),
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
                                    TColor.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Đang đăng nhập...",
                                style: TextStyle(
                                  color: TColor.primary,
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
                          _handleLogin(context);
                        },
                        title: "Đăng nhập",
                        bgColor: TColor.primary,
                        textColor: TColor.white,
                      ),
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              RoundButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ),
                  );
                },
                title: "Tạo tài khoản",
                bgColor: const Color(0xffc2c2c2),
                textColor: TColor.primaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    // Validation cơ bản cho email
    if (txtEmail.text.isEmpty) {
      _showValidationDialog(context, "Vui lòng nhập địa chỉ email");
      return;
    }
    if (!_isValidEmail(txtEmail.text)) {
      _showValidationDialog(context, "Địa chỉ email không đúng định dạng");
      return;
    }

    // Validation cơ bản cho mật khẩu
    if (txtPassword.text.isEmpty) {
      _showValidationDialog(context, "Vui lòng nhập mật khẩu");
      return;
    }

    // Gửi request đăng nhập - API sẽ xử lý validation và trả về thông báo phù hợp
    context.read<AuthBloc>().add(
      AuthLoginStarted(
        phoneNumber: txtEmail.text, // Sử dụng email thay vì phoneNumber
        password: txtPassword.text,
      ),
    );
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
                backgroundColor: TColor.primary,
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

  // Method hiển thị dialog lỗi đăng nhập
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
                "Đăng nhập thất bại",
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

  // Validation methods
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }
}
