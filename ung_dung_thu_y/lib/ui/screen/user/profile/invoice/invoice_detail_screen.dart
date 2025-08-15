import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice/invoice_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_event.dart';
import 'package:ung_dung_thu_y/bloc/invoice_deposit/invoice_deposit_state.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_bloc.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_event.dart';
import 'package:ung_dung_thu_y/bloc/user_credit/user_credit_state.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_bloc.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_event.dart';
import 'package:ung_dung_thu_y/bloc/vnpay/redirect_vnpay_state.dart';
import 'package:ung_dung_thu_y/core/route/router.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_appoint.dart';
import 'package:ung_dung_thu_y/dto/invoice_deposit/invoice_deposit_kennel.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/service/services_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/dto/vnpay/vnpay_request_dto.dart';
import 'package:ung_dung_thu_y/core/http/http_client.dart';
import 'package:ung_dung_thu_y/ui/common/color_extension.dart';
import 'package:ung_dung_thu_y/ui/common/format_date.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/alert_dialog.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/button_back_screen.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/my_app_bar.dart';
import 'package:ung_dung_thu_y/ui/common_widgets/round_button.dart';

class InvoiceDepositDetailScreen extends StatefulWidget {
  final int type;
  final int idInvoice;
  const InvoiceDepositDetailScreen({
    super.key,
    required this.idInvoice,
    required this.type,
  });

  @override
  State<InvoiceDepositDetailScreen> createState() =>
      _InvoiceDepositDetailScreen();
}

class _InvoiceDepositDetailScreen extends State<InvoiceDepositDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return _buildDisplayInvoiceDeposit();
  }

  @override
  void initState() {
    super.initState();
    // Load invoice detail and user credit
    context.read<InvoiceDepositBloc>().add(
      InvoiceDepositGetDetailStarted(
        type: widget.type,
        idInvoice: widget.idInvoice,
      ),
    );
    context.read<UserCreditBloc>().add(UserCreditGetStarted());
  }

  Widget _buildDisplayInvoiceDeposit() {
    return Scaffold(
      appBar: MyAppBar(
        title: Text("Hóa đơn tạm ứng"),
        leading: ButtonBackScreen(onPress: backScreen),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: BlocListener<RedirectVnpayBloc, RedirectVnpayState>(
            listener: (context, state) async {
              if (state is RedirectVnpaySuccess) {
                final result = await context.push(
                  RouteName.vnpayWebview,
                  extra: {
                    'paymentUrl': state.url,
                    'invoiceCode': 'INVOICE_${widget.idInvoice}',
                  },
                );

                // Handle the result from webview
                if (result == true) {
                  // Payment successful, trigger payment confirmation
                  context.read<InvoiceDepositBloc>().add(
                    InvoiceDepositPaymentStarted(widget.idInvoice),
                  );
                }
              } else if (state is RedirectVnpayFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi chuyển hướng: ${state.message}'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: BlocListener<InvoiceDepositBloc, InvoiceDepositState>(
              listener: (context, state) {
                if (state is InvoiceDepositPaymentSuccess) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return MyAlertDialog(
                        title: "Thanh toán thành công",
                        message: "",
                        onPress: () {
                          // Load invoice deposit data
                          context.read<InvoiceDepositBloc>().add(
                            InvoiceDepositGetStarted(),
                          );

                          // Load regular invoices data
                          context.read<InvoiceBloc>().add(
                            InvoiceGetByUserStarted(),
                          );
                          context.read<InvoiceBloc>().add(
                            InvoiceKennelGetByUserStarted(),
                          );
                          context.pop(context);
                          context.pop(context);
                        },
                      );
                    },
                  );
                } else if (state is InvoiceDepositPaymentFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thanh toán thất bại: ${state.message}'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: BlocBuilder<InvoiceDepositBloc, InvoiceDepositState>(
                builder: (context, state) {
                  return (switch (state) {
                    InvoiceDepositKennelSuccess() => _buildDisplayInvoiceKenel(
                      state.invoiceDepositKennel,
                    ),
                    InvoiceDepositAppointSuccess() => _buildInvoiceAppoint(
                      state.invoiceDepositAppoint,
                    ),
                    _ => Center(child: CircularProgressIndicator()),
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayInvoiceKenel(InvoiceDepositKennel invoiceDetail) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _displayUserInfo(invoiceDetail.user),
        SizedBox(height: 10),
        _displayPet(invoiceDetail.pet),
        SizedBox(height: 10),
        _displayInfoInvoice(
          invoiceDetail.createdAt,
          invoiceDetail.invoiceCode,
          invoiceDetail.totalAmount,
          invoiceDetail.status,
        ),
        _displayKennelInvoice(
          invoiceDetail.inTime,
          invoiceDetail.outTime,
          invoiceDetail.kennel,
          invoiceDetail.priceService,
        ),
        SizedBox(height: 10),
        BlocBuilder<UserCreditBloc, UserCreditState>(
          builder: (context, userCreditState) {
            return _displayDetailPayment(
              invoiceDetail.totalAmount,
              invoiceDetail.deposit,
              userCreditState,
            );
          },
        ),
        SizedBox(height: 20),
        invoiceDetail.status == 0
            ? BlocBuilder<UserCreditBloc, UserCreditState>(
              builder: (context, userCreditState) {
                return RoundButton(
                  onPressed:
                      () =>
                          _handleKennelPayment(invoiceDetail, userCreditState),
                  title: "Thanh toán",
                  bgColor: Colors.blue,
                  textColor: Colors.white,
                );
              },
            )
            : SizedBox(height: 10),
      ],
    );
  }

  void backScreen() {
    context.pop(context);
  }

  Widget _buildUserAvatar(String? avatarUrl) {
    // Check if avatarUrl is null, empty, or is an asset path
    if (avatarUrl == null ||
        avatarUrl.isEmpty ||
        avatarUrl.startsWith('assets/') ||
        !avatarUrl.startsWith('http')) {
      // Use default asset image
      return Image.asset(
        "assets/image/avatar_default.jpg",
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    // Use network image with fallback
    return FadeInImage.assetNetwork(
      placeholder: "assets/image/avatar_default.jpg",
      image: avatarUrl,
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
    );
  }

  Widget _buildPetAvatar(String? avatarUrl) {
    // Check if avatarUrl is null, empty, or is an asset path
    if (avatarUrl == null ||
        avatarUrl.isEmpty ||
        avatarUrl.startsWith('assets/') ||
        !avatarUrl.startsWith('http')) {
      // Use default asset image
      return Image.asset(
        "assets/image/pet_default.jpg",
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    // Use network image with fallback
    return FadeInImage.assetNetwork(
      placeholder: "assets/image/pet_default.jpg",
      image: avatarUrl,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "assets/image/pet_default.jpg",
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _displayUserInfo(UserGetDto user) {
    return Card(
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
              child: _buildUserAvatar(user.avatar),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Người thanh toán",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  user.fullname!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayByStatus(int status) {
    switch (status) {
      case 0:
        return _displayStatusItem(
          TColor.appointmentStatusWaitingColor,
          Icon(
            Icons.access_time_filled,
            color: TColor.appointmentStatusWaitingColor,
          ),
          "Chờ thanh toán",
        );
      case 1:
        return _displayStatusItem(
          TColor.appointmentStatusAccessedColor,
          Icon(
            Icons.check_circle_outline,
            color: TColor.appointmentStatusAccessedColor,
          ),
          "Đã thanh toán",
        );
      case 2:
        return _displayStatusItem(
          TColor.appointmentStatusCanceledColor,
          Icon(
            Icons.cancel_outlined,
            color: TColor.appointmentStatusCanceledColor,
          ),
          "Đã hủy",
        );
      case 3:
      default:
        return _displayStatusItem(
          TColor.appointmentStatusCompletedColor,
          Icon(Icons.warning, color: TColor.appointmentStatusCompletedColor),
          "Quá hạn",
        );
    }
  }

  Widget _displayStatusItem(Color color, Icon icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayInfoInvoice(
    String createdAt,
    String invoiceCode,
    int totalAmount,
    int status,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Mã hóa đơn",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(invoiceCode, style: TextStyle(fontSize: 14)),
                  ],
                ),
                displayByStatus(status),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("Ngày tạo"), Text(createdAt)],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Tổng tiền"),
                Text(
                  '${NumberFormat('#,###').format(totalAmount)} VNĐ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayKennelInvoice(
    String inTime,
    String outTime,
    KennelDto kennel,
    int priceService,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    DateTime inDate = dateFormat.parse(inTime);
    DateTime outDate = dateFormat.parse(outTime);
    int numDay = outDate.difference(inDate).inDays;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Thông tin dịch vụ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            _displayItem("Giờ vào", inTime),
            SizedBox(height: 5),
            _displayItem("Giờ ra", outTime),
            SizedBox(height: 5),
            _displayItem(
              "Loại chuồng",
              "${kennel.name} - ${kennel.type == "NORMAL" ? "Bình thường" : "Đặc biệt"}",
            ),
            SizedBox(height: 5),
            _displayItem(
              "Phí dịch vụ",
              '${NumberFormat('#,###').format(priceService * kennel.priceMultiplier)} VNĐ',
            ),
            SizedBox(height: 5),
            _displayItem("Số ngày", "$numDay ngày"),
          ],
        ),
      ),
    );
  }

  Widget _displayItem(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title),
        Text(content, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _displayDetailPayment(
    int totalAmount,
    int deposit,
    UserCreditState userCreditState,
  ) {
    // Tính toán số dư và số tiền thanh toán
    int userBalance = 0;
    int paymentAmount = deposit;

    if (userCreditState is UserCreditGetSuccess) {
      userBalance = userCreditState.userCredits.balance;
      // Nếu số dư còn lại > tiền đặt cọc thì số tiền thanh toán = 0
      // Ngược lại thì số tiền thanh toán = tiền đặt cọc - số dư còn lại
      if (userBalance >= deposit) {
        paymentAmount = 0;
      } else {
        paymentAmount = deposit - userBalance;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Chi tiết thanh toán",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Tổng tiền"),
                Text(
                  '${NumberFormat('#,###').format(totalAmount)} VNĐ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TColor.primary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Tiền đặt cọc"),
                Text(
                  '${NumberFormat('#,###').format(deposit)} VNĐ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Số dư còn lại"),
                Text(
                  userCreditState is UserCreditGetSuccess
                      ? '${NumberFormat('#,###').format(userBalance)} VNĐ'
                      : 'Đang tải...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(thickness: 1, color: Colors.grey[300]),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Số tiền thanh toán",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  userCreditState is UserCreditGetSuccess
                      ? '${NumberFormat('#,###').format(paymentAmount)} VNĐ'
                      : 'Đang tính...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: paymentAmount == 0 ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _displayPet(PetGetDto pet) {
    return Card(
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
              child: _buildPetAvatar(pet.avatar),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tên thú cưng: ${pet.name}",
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 5),
                Text(
                  "Tuổi: ${getPetAge(pet.birthday)} - ${pet.gender == 0 ? "Cái" : "Đực"}",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildInvoiceAppoint(InvoiceDepositAppoint invoiceDetail) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _displayUserInfo(invoiceDetail.user),
        SizedBox(height: 10),
        _displayInfoInvoice(
          invoiceDetail.createdAt,
          invoiceDetail.invoiceCode,
          invoiceDetail.totalAmount,
          invoiceDetail.status,
        ),
        SizedBox(height: 10),
        _displayAppointmentTime(invoiceDetail.appointmentTime),
        SizedBox(height: 10),
        _displayServiceAppointment(invoiceDetail.services),
        SizedBox(height: 10),
        BlocBuilder<UserCreditBloc, UserCreditState>(
          builder: (context, userCreditState) {
            return _displayDetailPayment(
              invoiceDetail.totalAmount,
              invoiceDetail.deposit,
              userCreditState,
            );
          },
        ),
        SizedBox(height: 20),
        invoiceDetail.status == 0
            ? BlocBuilder<UserCreditBloc, UserCreditState>(
              builder: (context, userCreditState) {
                return RoundButton(
                  onPressed:
                      () => _handleAppointmentPayment(
                        invoiceDetail,
                        userCreditState,
                      ),
                  title: "Thanh toán",
                  bgColor: Colors.blue,
                  textColor: Colors.white,
                );
              },
            )
            : SizedBox(height: 10),
      ],
    );
  }

  Widget _displayServiceAppointment(List<ServicesGetDto> services) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, size: 30, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "Dịch vụ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...services.map((service) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Text(
                      '${NumberFormat('#,###').format(service.price)} VNĐ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _displayAppointmentTime(String appointmentTime) {
    DateTime dateTime;
    String dateApp = "";
    String time = "";

    try {
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      dateTime = dateFormat.parse(appointmentTime);
      dateApp = DateFormat('dd/MM/yyyy').format(dateTime);
      time = DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      dateApp = "Không xác định";
      time = "Không xác định";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 30, color: TColor.primary),
                SizedBox(width: 10),
                Text(
                  "Thời gian khám",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  "Ngày khám:",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Text(
                  dateApp,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  "Giờ khám:",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TColor.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Handle payment for kennel invoice
  void _handleKennelPayment(
    InvoiceDepositKennel invoiceDetail,
    UserCreditState userCreditState,
  ) {
    if (userCreditState is UserCreditGetSuccess) {
      final userCredit = userCreditState.userCredits;
      int paymentAmount;

      if (userCredit.balance >= invoiceDetail.deposit) {
        paymentAmount = 0;
        context.read<InvoiceDepositBloc>().add(
          InvoiceDepositPaymentStarted(invoiceDetail.idInvoiceDepo),
        );
      } else {
        paymentAmount = invoiceDetail.deposit - userCredit.balance;
        _redirectToVnPay(invoiceDetail.invoiceCode, paymentAmount);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin tài khoản. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _handleAppointmentPayment(
    InvoiceDepositAppoint invoiceDetail,
    UserCreditState userCreditState,
  ) {
    if (userCreditState is UserCreditGetSuccess) {
      final userCredit = userCreditState.userCredits;
      int paymentAmount;

      if (userCredit.balance >= invoiceDetail.deposit) {
        paymentAmount = 0;
        context.read<InvoiceDepositBloc>().add(
          InvoiceDepositPaymentStarted(invoiceDetail.idInvoiceDepo),
        );
      } else {
        paymentAmount = invoiceDetail.deposit - userCredit.balance;
        _redirectToVnPay(invoiceDetail.invoiceCode, paymentAmount);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải thông tin tài khoản. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Redirect to VNPay for payment
  void _redirectToVnPay(String invoiceCode, int totalAmount) async {
    final ipClient = await getPublicIpAddress();
    if (ipClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chuyển hướng thất bại'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final vnPayRequestDto = VnPayRequestDto(
      vnpOrderInfo: "Thanh toan hoa don $invoiceCode",
      invoiceCode: invoiceCode,
      price: totalAmount,
      ipClient: ipClient!,
    );

    context.read<RedirectVnpayBloc>().add(
      RedirectVnpayStarted(vnPayRequestDto),
    );
  }

  Future<String?> getPublicIpAddress() async {
    try {
      final response = await dio.get('https://api.ipify.org');
      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy IP: $e');
      return null;
    }
  }
}
