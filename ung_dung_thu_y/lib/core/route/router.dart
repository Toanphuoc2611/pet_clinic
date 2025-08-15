import 'package:go_router/go_router.dart';
import 'package:ung_dung_thu_y/dto/appointment/appointment_get_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice/invoice_response.dart';
import 'package:ung_dung_thu_y/dto/kennel/get_kennel_detail_dto.dart';
import 'package:ung_dung_thu_y/dto/medical_record/medical_record_dto.dart';
import 'package:ung_dung_thu_y/dto/pet/pet_get_dto.dart';
import 'package:ung_dung_thu_y/dto/user/user_get_dto.dart';
import 'package:ung_dung_thu_y/dto/invoice_kennel/invoice_kennel_dto.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/appointment/create_appointment_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/appointment/doctor_appointment_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/invoice/invoice_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/invoice/invoice_kennel_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/kennel/doctor_kennel_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/kennel/doctor_kennel_list_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/main_doctor_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/medical_record/detail/medical_record_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/prescription/prescription_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/doctor/statistics/revenue_statistics_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/appointment/appointment_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/appointment/book_appointment_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/pet/handle_pet_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/appointment/appointment_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/home/home_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/login/login_view.dart';
import 'package:ung_dung_thu_y/ui/screen/main_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/pet/pet_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/invoice/invoice_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/invoice/invoice_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/kennel/book_kennel_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/kennel/history_kennel_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/kennel/kennel_detail_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/profile_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/qr_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/user/profile/update_info_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/register/register_view.dart';
import 'package:ung_dung_thu_y/ui/screen/user/pet/pet_screen.dart';
import 'package:ung_dung_thu_y/ui/screen/vnpay/vnpay_webview_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ung_dung_thu_y/bloc/doctor/kennel_detail/doctor_kennel_detail_bloc.dart';
import 'package:ung_dung_thu_y/repository/kennel/kennel_detail_repository.dart';

class RouteName {
  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String pet = '/pet';
  static const String appointment = '/appointment';
  static const String profile = '/profile';
  static const String home = '/home';
  static const String updateInfo = '/update-info';
  static const String qr = '/qr_screen';
  static const String handlePet = '/handle-pet';
  static const String petDetail = '/pet-detail';
  static const String bookAppointment = '/book-appointment';
  static const String appointmentDetail = '/appointment/detail';
  static const String invoice = '/invoice';
  static const String bookKennel = '/book-kennel';
  static const String invoiceDeposit = '/invoice-deposit';
  static const String historyKennel = '/history-kennel';
  static const String detailKennel = '/detail-kennel';
  static const String doctorAppointment = '/doctor/appointment';

  // doctor
  static const String doctorMain = '/doctor';
  static const String doctorPrescription = '/doctor/prescription';
  static const String doctorInvoiceDetail = '/doctor/invoice-detail';
  static const String doctorDetailMedicalRecord =
      '/doctor/medical-record/detail';
  static const String doctorKennel = '/doctor/kennel';
  static const String doctorKennelDetail = '/doctor/kennel-detail';
  static const String doctorInvoiceKennelDetail =
      '/doctor/invoice-kennel-detail';
  static const String doctorStatistics = '/doctor/statistics';
  static const String doctorCreateAppointment = '/doctor/create-appointment';
  static const String vnpayWebview = '/vnpay-webview';

  // admin
  static const String adminLogin = '/admin/login';
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminPets = '/admin/pets';
  static const String adminAppointments = '/admin/appointments';
  static const String adminInvoices = '/admin/invoices';
  static const String adminMedications = '/admin/medications';
  static const String adminServices = '/admin/services';
  static const String adminKennels = '/admin/kennels';

  static const publicRoutes = [login, register, adminLogin];
}

final myRouter = GoRouter(
  // redirect: (context, state) {
  //   if (RouteName.publicRoutes.contains(state.fullPath)) {
  //     return null;
  //   }
  //   return RouteName.login;
  // },
  initialLocation: RouteName.login,
  routes: [
    GoRoute(path: RouteName.login, builder: (context, state) => LoginView()),
    GoRoute(
      path: RouteName.register,
      builder: (context, state) => RegisterView(),
    ),
    // User Begin:
    GoRoute(path: RouteName.home, builder: (context, state) => HomeScreen()),
    GoRoute(path: RouteName.main, builder: (context, state) => MainScreen()),
    GoRoute(
      path: RouteName.appointment,
      builder: (context, state) => AppointmentScreen(),
    ),
    GoRoute(path: RouteName.pet, builder: (context, state) => PetScreen()),
    GoRoute(
      path: RouteName.profile,
      builder: (context, state) => ProfileScreen(),
    ),
    GoRoute(
      path: RouteName.updateInfo,
      builder: (context, state) {
        final user = state.extra as UserGetDto;
        return UpdateInfoScreen(user: user);
      },
    ),
    GoRoute(path: RouteName.qr, builder: (context, state) => ScannerScreen()),
    GoRoute(
      path: RouteName.handlePet,
      builder: (context, state) {
        final pet = state.extra;
        return HandlePetScreen(pet: pet is PetGetDto ? pet : null);
      },
    ),
    GoRoute(
      path: RouteName.petDetail,
      builder: (context, state) {
        final pet = state.extra as PetGetDto;
        return PetDetailScreen(pet: pet);
      },
    ),
    GoRoute(
      path: RouteName.bookAppointment,
      builder: (context, state) {
        return BookAppointmentScreen();
      },
    ),
    GoRoute(
      path: RouteName.appointmentDetail,
      builder: (context, state) {
        final appointmentId = state.extra as int;
        return AppointmentDetailScreen(appointmentId: appointmentId);
      },
    ),
    GoRoute(
      path: RouteName.invoice,
      builder: (Context, state) {
        return InvoiceScreen();
      },
    ),
    GoRoute(
      path: RouteName.bookKennel,
      builder: (context, state) => BookKennelScreen(),
    ),
    GoRoute(
      path: RouteName.invoiceDeposit,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final int idInvoice = extra['idInvoice'];
        final int type = extra['type'];
        return InvoiceDepositDetailScreen(idInvoice: idInvoice, type: type);
      },
    ),
    GoRoute(
      path: RouteName.historyKennel,
      builder: (context, state) => HistoryKennelScreen(),
    ),
    GoRoute(
      path: RouteName.detailKennel,
      builder: (context, state) {
        final kennelDetail = state.extra as KennelDetailDto;
        return KennelDetailScreen(kennelDetailDto: kennelDetail);
      },
    ),

    // User End

    // Doctor Begin:
    GoRoute(
      path: RouteName.doctorMain,
      builder: (context, state) => MainDoctorScreen(),
    ),

    GoRoute(
      path: RouteName.doctorPrescription,
      builder: (context, state) {
        final appointment = state.extra as AppointmentGetDto;
        return PrescriptionScreen(appointment: appointment);
      },
    ),

    GoRoute(
      path: RouteName.doctorInvoiceDetail,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is InvoiceResponse) {
          return InvoiceDetailScreen(invoice: extra, isFromUser: false);
        } else if (extra is Map<String, dynamic>) {
          final invoice = extra['invoice'] as InvoiceResponse;
          final isFromUser = extra['isFromUser'] as bool? ?? false;
          return InvoiceDetailScreen(invoice: invoice, isFromUser: isFromUser);
        } else {
          throw Exception('Invalid extra type for doctorInvoiceDetail route');
        }
      },
    ),

    GoRoute(
      path: RouteName.doctorDetailMedicalRecord,
      builder: (context, state) {
        final medicalRecordDto = state.extra as MedicalRecordDto;
        return MedicalRecordDetailScreen(medicalRecordDto: medicalRecordDto);
      },
    ),

    GoRoute(
      path: RouteName.doctorKennel,
      builder: (context, state) => const DoctorKennelListScreen(),
    ),

    GoRoute(
      path: RouteName.doctorKennelDetail,
      builder: (context, state) {
        final kennelDetail = state.extra as KennelDetailDto;
        return DoctorKennelDetailScreen(kennelDetailDto: kennelDetail);
      },
    ),

    GoRoute(
      path: RouteName.doctorInvoiceKennelDetail,
      builder: (context, state) {
        final invoiceKennel = state.extra as InvoiceKennelDto;
        return InvoiceKennelDetailScreen(invoiceKennelDto: invoiceKennel);
      },
    ),
    GoRoute(
      path: RouteName.doctorStatistics,
      builder: (context, state) => RevenueStatisticsScreen(),
    ),
    GoRoute(
      path: RouteName.doctorCreateAppointment,
      builder: (context, state) => CreateAppointmentScreen(),
    ),
    GoRoute(
      path: RouteName.vnpayWebview,
      builder: (context, state) {
        final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
        return VnPayWebViewScreen(
          paymentUrl: extra['paymentUrl'] as String,
          invoiceCode: extra['invoiceCode'] as String,
        );
      },
    ),
    GoRoute(
      path: RouteName.doctorAppointment,
      builder: (context, state) => DoctorAppointmentScreen(),
    ),
    // Doctor End
  ],
);
