import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_bloc.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_event.dart';
import 'package:ung_dung_thu_y/bloc/auth/auth_state.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/data/auth/local_data/auth_local_data_source.dart';
import 'package:ung_dung_thu_y/dto/auth/register_dto.dart';
import 'package:ung_dung_thu_y/remote/auth/auth_api_client.dart';
import 'package:ung_dung_thu_y/repository/auth/auth_repository.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';
import 'package:ung_dung_thu_y/ui/screen/login/login_view.dart';

class OtpView extends StatefulWidget {
  final RegisterDto registerDto;
  const OtpView({super.key, required this.registerDto});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller5 = TextEditingController();
  final TextEditingController _controller6 = TextEditingController();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  bool isLoading = false;
  String _isOTPComplete() {
    if (_controller1.text.isNotEmpty &&
        _controller2.text.isNotEmpty &&
        _controller3.text.isNotEmpty &&
        _controller4.text.isNotEmpty &&
        _controller5.text.isNotEmpty &&
        _controller6.text.isNotEmpty) {
      return _controller1.text +
          _controller2.text +
          _controller3.text +
          _controller4.text +
          _controller5.text +
          _controller6.text;
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
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
        create:
            (context) =>
                AuthBloc(RepositoryProvider.of<AuthRepository>(context)),
        child: Scaffold(
          appBar: AppBar(
            foregroundColor: TColor.white,
            backgroundColor: TColor.primary,
            title: const Center(child: Text("Nhập mã xác nhận")),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Mã xác thực đã gửi đến địa chỉ email ${widget.registerDto.email}",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Mã sẽ hết hạn sau: $timerText",
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      if (_remainingSeconds == 0)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return (switch (state) {
                              AuthSendOtpInProgress() =>
                                const CircularProgressIndicator(),
                              _ => TextButton(
                                onPressed: () {
                                  _startCountdown();
                                  context.read<AuthBloc>().add(
                                    AuthsendOtpStarted(
                                      widget.registerDto.phoneNumber,
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Gửi lại",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOTPField(controller: _controller1),
                      _buildOTPField(controller: _controller2),
                      _buildOTPField(controller: _controller3),
                      _buildOTPField(controller: _controller4),
                      _buildOTPField(controller: _controller5),
                      _buildOTPField(controller: _controller6),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthRegisterSuccess) {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("Đăng ký thành công"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginView(),
                                      ),
                                    );
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      } else if (state is AuthRegisterFailure) {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("OTP không chính xác"),
                              content: Text(state.message),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Đóng"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return (switch (state) {
                          AuthRegisterInProgress() =>
                            const CircularProgressIndicator(),
                          _ => RoundButton(
                            title: "Xác nhận",
                            onPressed: () async {
                              if (_isOTPComplete().length < 6) {
                                showMessage("Vui lòng nhập đầy đủ mã OTP");
                                return;
                              }
                              widget.registerDto.otp = _isOTPComplete();
                              context.read<AuthBloc>().add(
                                AuthRegisterStarted(widget.registerDto),
                              );
                            },
                            bgColor: Colors.blue,
                            textColor: Colors.white,
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildOTPField({required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        width: 40,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 1,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            counterText: "",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }

  Timer? _countdownTimer;
  int _remainingSeconds = 300; // 5 phút

  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _startCountdown() {
    _countdownTimer?.cancel(); // tránh trùng timer
    _remainingSeconds = 300;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        showMessage("Mã OTP đã hết hạn, vui lòng yêu cầu lại.");
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    _controller6.dispose();
  }
}
