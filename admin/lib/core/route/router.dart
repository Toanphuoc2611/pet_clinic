import 'package:admin/screens/login_screen.dart';
import 'package:admin/screens/simple_analytics_screen.dart';
import 'package:admin/screens/placeholder_screen.dart';
import 'package:admin/screens/user_management_screen.dart';
import 'package:admin/screens/appointment_management_screen.dart';
import 'package:admin/screens/invoice_management_screen.dart';
import 'package:admin/screens/medical_record_management_screen.dart';
import 'package:admin/screens/service_kennel_management_screen.dart';
import 'package:admin/screens/inventory_management_screen.dart';
import 'package:admin/screens/account_management_screen.dart';
import 'package:admin/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RouteName {
  static const String main = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String users = '/users';
  static const String accounts = '/accounts';
  static const String appointments = '/appointments';
  static const String invoices = '/invoices';
  static const String medicalRecords = '/medical-records';
  static const String kennels = '/kennels';
  static const String inventory = '/inventory';

  static const publicRoutes = [login];
}

final myRouter = GoRouter(
  redirect: (context, state) {
    // Nếu đang ở trang public thì cho phép truy cập
    if (RouteName.publicRoutes.contains(state.fullPath)) {
      return null;
    }

    return null;
  },
  initialLocation: RouteName.login, // Đặt login làm trang mặc định
  routes: [
    GoRoute(
      path: RouteName.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteName.analytics,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/analytics',
            child: SimpleAnalyticsScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.users,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/users',
            child: UserManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.accounts,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/accounts',
            child: AccountManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.appointments,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/appointments',
            child: AppointmentManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.invoices,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/invoices',
            child: InvoiceManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.medicalRecords,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/medical-records',
            child: MedicalRecordManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.kennels,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/kennels',
            child: ServiceKennelManagementScreen(),
          ),
    ),
    GoRoute(
      path: RouteName.inventory,
      builder:
          (context, state) => const MainLayout(
            currentRoute: '/inventory',
            child: InventoryManagementScreen(),
          ),
    ),
  ],
);
